SET NOCOUNT ON;
USE master;

-- 1) Подготовка: очистка диалогов и удаление тестовых объектов
DECLARE @sid INT;
DECLARE @h UNIQUEIDENTIFIER;

SELECT @sid = service_id FROM sys.services WHERE name = 'sb_s16_min_i_service';
WHILE @sid IS NOT NULL AND EXISTS (SELECT 1 FROM sys.conversation_endpoints WHERE local_service_id = @sid)
BEGIN
    SELECT TOP (1) @h = conversation_handle
    FROM sys.conversation_endpoints
    WHERE local_service_id = @sid;

    END CONVERSATION @h WITH CLEANUP;
END

SELECT @sid = service_id FROM sys.services WHERE name = 'sb_s16_min_t_service';
WHILE @sid IS NOT NULL AND EXISTS (SELECT 1 FROM sys.conversation_endpoints WHERE local_service_id = @sid)
BEGIN
    SELECT TOP (1) @h = conversation_handle
    FROM sys.conversation_endpoints
    WHERE local_service_id = @sid;

    END CONVERSATION @h WITH CLEANUP;
END

IF EXISTS (SELECT 1 FROM sys.services WHERE name = 'sb_s16_min_i_service')
    DROP SERVICE [sb_s16_min_i_service];
IF EXISTS (SELECT 1 FROM sys.services WHERE name = 'sb_s16_min_t_service')
    DROP SERVICE [sb_s16_min_t_service];
IF EXISTS (SELECT 1 FROM sys.service_queues WHERE name = 'sb_s16_min_i_queue')
    DROP QUEUE [sb_s16_min_i_queue];
IF EXISTS (SELECT 1 FROM sys.service_queues WHERE name = 'sb_s16_min_t_queue')
    DROP QUEUE [sb_s16_min_t_queue];
IF EXISTS (SELECT 1 FROM sys.service_contracts WHERE name = 'sb_s16_min_contract')
    DROP CONTRACT [sb_s16_min_contract];
IF EXISTS (SELECT 1 FROM sys.service_message_types WHERE name = 'sb_s16_min_msg')
    DROP MESSAGE TYPE [sb_s16_min_msg];

-- 2) Создание минимального набора объектов
CREATE MESSAGE TYPE [sb_s16_min_msg] VALIDATION = NONE;
CREATE CONTRACT [sb_s16_min_contract] ([sb_s16_min_msg] SENT BY ANY);

CREATE QUEUE [sb_s16_min_i_queue];
CREATE SERVICE [sb_s16_min_i_service]
    ON QUEUE [sb_s16_min_i_queue] ([sb_s16_min_contract]);

CREATE QUEUE [sb_s16_min_t_queue];
CREATE SERVICE [sb_s16_min_t_service]
    ON QUEUE [sb_s16_min_t_queue] ([sb_s16_min_contract]);


-- 3) Диалог + передача сообщения туда и обратно
IF OBJECT_ID('tempdb..#sb_s16_min_state') IS NOT NULL
    DROP TABLE #sb_s16_min_state;

CREATE TABLE #sb_s16_min_state (
    init_handle UNIQUEIDENTIFIER NULL,
    target_handle UNIQUEIDENTIFIER NULL
);

INSERT INTO #sb_s16_min_state VALUES (NULL, NULL);

DECLARE @init_handle UNIQUEIDENTIFIER;
DECLARE @target_handle UNIQUEIDENTIFIER;
DECLARE @msg_body VARBINARY(MAX);
DECLARE @msg_type NVARCHAR(256);

BEGIN DIALOG CONVERSATION @init_handle
    FROM SERVICE [sb_s16_min_i_service]
    TO SERVICE N'sb_s16_min_t_service'
    ON CONTRACT [sb_s16_min_contract]
    WITH ENCRYPTION = OFF;

UPDATE #sb_s16_min_state
SET init_handle = @init_handle;

SEND ON CONVERSATION @init_handle
    MESSAGE TYPE [sb_s16_min_msg] (0x4D494E5F524551);

WAITFOR (
    RECEIVE TOP (1)
        @target_handle = conversation_handle,
        @msg_body = message_body,
        @msg_type = message_type_name
    FROM [sb_s16_min_t_queue]
), TIMEOUT 30000;

UPDATE #sb_s16_min_state
SET target_handle = @target_handle;

SEND ON CONVERSATION @target_handle
    MESSAGE TYPE [sb_s16_min_msg] (0x4D494E5F52455350);

WAITFOR (
    RECEIVE TOP (1)
        @init_handle = conversation_handle,
        @msg_body = message_body,
        @msg_type = message_type_name
    FROM [sb_s16_min_i_queue]
), TIMEOUT 30000;

-- 4) Корректное завершение диалога обеими сторонами
DECLARE @init_handle UNIQUEIDENTIFIER;
DECLARE @target_handle UNIQUEIDENTIFIER;
DECLARE @end_type NVARCHAR(256);

SELECT @init_handle = init_handle,
       @target_handle = target_handle
FROM #sb_s16_min_state;

END CONVERSATION @init_handle;

WAITFOR (
    RECEIVE TOP (1)
        @target_handle = conversation_handle,
        @end_type = message_type_name
    FROM [sb_s16_min_t_queue]
), TIMEOUT 30000;

END CONVERSATION @target_handle;
