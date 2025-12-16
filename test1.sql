/* ============================================================
   Run everything inside database: ms_test2
   - Creates stubs in ms_test2 (dbo.*)
   - Then runs your original script unchanged
   ============================================================ */

SET NOCOUNT ON;
GO

/* --- Ensure target DB exists --- */
IF DB_ID(N'ms_test2') IS NULL
BEGIN
    RAISERROR(N'Database "ms_test2" does not exist.', 16, 1);
    RETURN;
END
GO

USE [ms_test2];
GO

/* ============================================================
   STUBS for helper functions expected by the script
   ============================================================ */

/* --- dbo.Translate(msg, LangId) -> returns msg as-is --- */
IF OBJECT_ID(N'dbo.Translate', N'FN') IS NOT NULL
    DROP FUNCTION dbo.Translate;
GO
CREATE FUNCTION dbo.Translate
(
    @msg NVARCHAR(MAX),
    @LangId INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN @msg;
END;
GO

/* --- dbo.StrToIntDef(value, default) --- */
IF OBJECT_ID(N'dbo.StrToIntDef', N'FN') IS NOT NULL
    DROP FUNCTION dbo.StrToIntDef;
GO
CREATE FUNCTION dbo.StrToIntDef
(
    @value NVARCHAR(MAX),
    @default INT
)
RETURNS INT
AS
BEGIN
    DECLARE @i INT;
    SET @i = TRY_CONVERT(INT, @value);
    RETURN ISNULL(@i, @default);
END;
GO

/* --- dbo.split(value, delim, index) : 0-based index --- */
IF OBJECT_ID(N'dbo.split', N'FN') IS NOT NULL
    DROP FUNCTION dbo.split;
GO
CREATE FUNCTION dbo.split
(
    @value NVARCHAR(MAX),
    @delim NVARCHAR(10),
    @index INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @start INT = 1;
    DECLARE @pos   INT;
    DECLARE @i     INT = 0;

    IF @value IS NULL RETURN NULL;
    IF @delim IS NULL OR LEN(@delim) = 0 RETURN NULL;
    IF @index IS NULL OR @index < 0 RETURN NULL;

    WHILE 1 = 1
    BEGIN
        SET @pos = CHARINDEX(@delim, @value, @start);

        IF @pos = 0
        BEGIN
            IF @i = @index
                RETURN SUBSTRING(@value, @start, LEN(@value) - @start + 1);
            RETURN N'';
        END

        IF @i = @index
            RETURN SUBSTRING(@value, @start, @pos - @start);

        SET @start = @pos + LEN(@delim);
        SET @i = @i + 1;
    END

    RETURN N'';
END;
GO

/* --- dbo.get_checkCodeInLicence(code, dummy) -> big number to avoid blocking tests --- */
IF OBJECT_ID(N'dbo.get_checkCodeInLicence', N'FN') IS NOT NULL
    DROP FUNCTION dbo.get_checkCodeInLicence;
GO
CREATE FUNCTION dbo.get_checkCodeInLicence
(
    @code NVARCHAR(100),
    @dummy INT
)
RETURNS INT
AS
BEGIN
    RETURN 9999;
END;
GO
