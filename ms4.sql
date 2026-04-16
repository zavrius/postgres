-- Установка формата дат и получение id-соединения - все в стиле MS SQL
SET dateformat dmy
select @spid
go
-- никаких "точек с запятой", использование конструкции GO - это все также характерно для MS SQL

-- Функции из MS SQL, которые часто применяются в запросах и отсутствуют в обычном PostgreSQL
SELECT DATETIME('01.01.2025', '01.01.2025')
SELECT DATEADD(DAY, 5, '01.01.2025')

-- Удалим таблицу если она есть, заодно проверим функции работы с метаданными из MS SQL
IF OBJECT_ID ('AUTO_PK_SUPPORT', 'U') IS NOT NULL
    DROP TABLE AUTO_PK_SUPPORT

-- Создадим таблицу
CREATE TABLE AUTO_PK_SUPPORT (
    TABLE_NAME VARCHAR(18) NOT NULL,
    NEXT_ID INTEGER DEFAULT 0 NOT NULL
)

-- Удалим процедуру если она есть
IF OBJECT_ID ('AUTO_PK_GEN', 'P') IS NOT NULL
    DROP PROCEDURE AUTO_PK_GEN

-- Создадим хранимую процедуру используя "родной" для MS SQL синтаксис
-- Обычный PostgreSQL такое никогда исполнить не сможет!
GO
CREATE PROCEDURE AUTO_PK_GEN
    @TABLE_NAME VARCHAR(18),
    @BATCHSIZE INTEGER,
    @NEXT_ID INTEGER OUT
AS

BEGIN
    BEGIN TRANSACTION
    UPDATE AUTO_PK_SUPPORT SET NEXT_ID = NEXT_ID + @BATCHSIZE
    WHERE TABLE_NAME = @TABLE_NAME

    IF @@ROWCOUNT = 0
    INSERT INTO AUTO_PK_SUPPORT (TABLE_NAME, NEXT_ID)
    VALUES (@TABLE_NAME, 1000)

    SET @NEXT_ID = (SELECT NEXT_ID FROM AUTO_PK_SUPPORT WHERE TABLE_NAME = @TABLE_NAME)
    COMMIT
END
