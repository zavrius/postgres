/* Данный скрипт разработан
 * в компании Диасофт
 * для предварительного показа функционала 
 * продукта Digital Q.DataBase
 * посредством соединения через протокол TDS (MSSQL) */

-- Установка формата дат
SET dateformat dmy
go

-- Создание таблицы для учета продаж
IF OBJECT_ID('Sales', 'U') IS NOT NULL
    DROP TABLE Sales
go

CREATE TABLE Sales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    SaleDate DATE DEFAULT GETDATE(),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalAmount AS (Quantity * UnitPrice), -- Вычисляемое поле
    SaleMonth AS (FORMAT(SaleDate, 'yyyy-MM')) -- Вычисляемое поле для анализа
)
go

-- Заполнение тестовыми данными
INSERT INTO Sales (ProductName, SaleDate, Quantity, UnitPrice) VALUES
    ('Ноутбук ASUS VivoBook', '15.01.2024', 2, 45000.00),
    ('Мышь беспроводная', '18.01.2024', 5, 1200.00),
    ('Монитор 24"', '22.01.2024', 1, 18000.00),
    ('Клавиатура механическая', '15.02.2024', 3, 3500.00),
    ('Ноутбук Lenovo IdeaPad', '28.02.2024', 1, 52000.00),
    ('Коврик для мыши', '05.03.2024', 10, 500.00)
go

-- Процедура для анализа продаж за период
IF OBJECT_ID('GetSalesReport', 'P') IS NOT NULL
    DROP PROCEDURE GetSalesReport
go

CREATE PROCEDURE GetSalesReport
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    -- Общая статистика по периоду
    SELECT 
        COUNT(*) as 'Количество продаж',
        SUM(TotalAmount) as 'Общая выручка',
        AVG(TotalAmount) as 'Средний чек',
        MAX(TotalAmount) as 'Максимальная продажа',
        MIN(TotalAmount) as 'Минимальная продажа'
    FROM Sales 
    WHERE SaleDate BETWEEN @StartDate AND @EndDate
    
    -- Детализация по товарам
    SELECT 
        ProductName as 'Товар',
        SUM(Quantity) as 'Количество',
        SUM(TotalAmount) as 'Сумма',
        FORMAT(SUM(TotalAmount) * 100.0 / (SELECT SUM(TotalAmount) FROM Sales WHERE SaleDate BETWEEN @StartDate AND @EndDate), 'N2') + '%' as 'Доля в выручке'
    FROM Sales 
    WHERE SaleDate BETWEEN @StartDate AND @EndDate
    GROUP BY ProductName
    ORDER BY SUM(TotalAmount) DESC
    
    -- Продажи по месяцам
    SELECT 
        SaleMonth as 'Месяц',
        COUNT(*) as 'Количество продаж',
        SUM(TotalAmount) as 'Выручка'
    FROM Sales 
    WHERE SaleDate BETWEEN @StartDate AND @EndDate
    GROUP BY SaleMonth
    ORDER BY SaleMonth
END
go

-- Процедура для расчета бонусов менеджеров
IF OBJECT_ID('CalculateManagerBonus', 'P') IS NOT NULL
    DROP PROCEDURE CalculateManagerBonus
go

CREATE PROCEDURE CalculateManagerBonus
    @TargetAmount DECIMAL(10,2) = 100000
AS
BEGIN
    SELECT 
        SaleMonth as 'Месяц',
        SUM(TotalAmount) as 'Фактическая выручка',
        @TargetAmount as 'Плановая выручка',
        CASE 
            WHEN SUM(TotalAmount) >= @TargetAmount THEN 'План выполнен'
            ELSE 'План не выполнен'
        END as 'Статус',
        CASE 
            WHEN SUM(TotalAmount) >= @TargetAmount THEN SUM(TotalAmount) * 0.05
            ELSE 0
        END as 'Бонус менеджера'
    FROM Sales
    GROUP BY SaleMonth
    ORDER BY SaleMonth
END
go

-- Демонстрация работы

-- Анализ продаж за первый квартал 2024
EXEC GetSalesReport '01.01.2024', '31.03.2024'
go

-- Расчет бонусов менеджеров
EXEC CalculateManagerBonus @TargetAmount = 50000
go

-- Быстрый анализ текущих продаж
SELECT 
    'Текущий месяц: ' + FORMAT(GETDATE(), 'MMMM yyyy') as 'Период',
    (SELECT COUNT(*) FROM Sales WHERE SaleDate >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) as 'Продаж в месяце',
    (SELECT SUM(TotalAmount) FROM Sales WHERE SaleDate >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) as 'Выручка в месяце'
go

-- Очистка
IF OBJECT_ID('Sales', 'U') IS NOT NULL
    DROP TABLE Sales
go

IF OBJECT_ID('GetSalesReport', 'P') IS NOT NULL
    DROP PROCEDURE GetSalesReport
go

IF OBJECT_ID('CalculateManagerBonus', 'P') IS NOT NULL
    DROP PROCEDURE CalculateManagerBonus
go
