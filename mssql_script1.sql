/* Данный скрипт разработан
 * в компании Диасофт
 * для предварительного показа функционала 
 * продукта Digital Q.DataBase
 * в режиме эмуляции СУБД Microsoft SQL Server */

-- Меняем БД на demo в стиле MS SQL
USE demo

-- Установка формата дат и получение id-соединения - все в стиле MS SQL
SET dateformat dmy
select @@spid
go
-- никаких "точек с запятой", использование конструкции GO - это все также характерно для MS SQL



--Функции из MS SQL, которые часто применяются в запросах и отсутствуют в обычном PostgreSQL
SELECT DATEDIFF(DAY, '01.01.2024', '01.01.2025')
SELECT DATEADD(DAY, 5, '01.01.2025')

-- Удалим таблицу если она есть, заодно проверим функции работы с метаданными из MS SQL 
IF OBJECT_ID ( 'AUTO_PK_SUPPORT', 'U' ) IS NOT NULL
    DROP TABLE AUTO_PK_SUPPORT

-- Создадим таблицу    
CREATE TABLE AUTO_PK_SUPPORT (
 TABLE_NAME   VARCHAR(18) NOT NULL,   
 NEXT_ID   INTEGER DEFAULT 0 NOT NULL   
)

-- Удалим процедуру если она есть 
IF OBJECT_ID ( 'AUTO_PK_GEN', 'P' ) IS NOT NULL
    DROP PROCEDURE AUTO_PK_GEN

-- Создадим хранимую процедуру используя "родной" для MS SQL синтаксис
-- Обычный PostgreSQL такое никогда исполнить не сможет!     
CREATE PROCEDURE AUTO_PK_GEN
            @TABLENAME VARCHAR(18),
            @BATCHSIZE INTEGER,
            @NEXT_ID INTEGER OUT
            AS
BEGIN
     BEGIN TRANSACTION
        UPDATE AUTO_PK_SUPPORT SET NEXT_ID = NEXT_ID + @BATCHSIZE
        WHERE TABLE_NAME = @TABLENAME

        IF @@ROWCOUNT = 0
        INSERT INTO AUTO_PK_SUPPORT (TABLE_NAME, NEXT_ID)
        VALUES (@TABLENAME, 1000)
       
        SET @NEXT_ID = (SELECT NEXT_ID FROM AUTO_PK_SUPPORT WHERE TABLE_NAME = @TABLENAME)
     COMMIT
END

-- Удалим функцию если она есть 
IF OBJECT_ID ( 'AUTO_PK_FOR_TABLE', 'P' ) IS NOT NULL
    DROP PROCEDURE AUTO_PK_FOR_TABLE

-- Создадим функцию используя "родной" для MS SQL синтаксис 
CREATE PROCEDURE AUTO_PK_FOR_TABLE
 @TNAME VARCHAR(18),
 @PKBATCHSIZE INTEGER
 AS
BEGIN
 DECLARE @NEXT_ID INTEGER
 UPDATE AUTO_PK_SUPPORT SET @NEXT_ID = NEXT_ID = NEXT_ID + @PKBATCHSIZE
  WHERE TABLE_NAME = @TNAME
 SELECT @NEXT_ID as NEXT_ID
END



-- Позовем процедуру, один из параметров - переменная для возврата значений OUTPUT-параметра 
DECLARE @pk_value int
EXEC dbo.[AUTO_PK_GEN] @TABLENAME = 'BOOKS', @BATCHSIZE = 10, @NEXT_ID = @pk_value OUTPUT 
-- В этом exec есть обращение к ролям и квотирование идентификаторов в стиле MS SQL
SELECT @pk_value as RES

-- Вызовем функцию
EXECUTE AUTO_PK_FOR_TABLE @TNAME = N'BOOKS', @PKBATCHSIZE = 1
