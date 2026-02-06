/* ============================================================
   Demo: Продажи iPhone 2025 (RUB)
   База → данные → итоговый отчёт
   ============================================================ */

---------------------------------------------------------------
-- 1) Создание базы
---------------------------------------------------------------
IF DB_ID('qdb_demo_sales') IS NOT NULL
BEGIN
    ALTER DATABASE qdb_demo_sales
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE qdb_demo_sales;
END;
GO

CREATE DATABASE qdb_demo_sales;
GO

USE qdb_demo_sales;
GO

---------------------------------------------------------------
-- 2) Таблица Sales
---------------------------------------------------------------
IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL
    DROP TABLE dbo.Sales;
GO

CREATE TABLE dbo.Sales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    ProductType NVARCHAR(50)  NOT NULL,
    ProductName NVARCHAR(150) NOT NULL,
    SaleDate    DATE          NOT NULL,
    Quantity    INT           NOT NULL CHECK (Quantity > 0),
    UnitPrice   DECIMAL(12,2) NOT NULL CHECK (UnitPrice >= 0),
    TotalAmount AS (Quantity * UnitPrice),
    SaleMonth   AS (FORMAT(SaleDate, 'yyyy-MM'))
);
GO

---------------------------------------------------------------
-- 3) Данные: iPhone, 2025 год, цены в рублях
---------------------------------------------------------------
INSERT INTO dbo.Sales (ProductType, ProductName, SaleDate, Quantity, UnitPrice) VALUES
(N'Электроника', N'iPhone 15 Pro Max 256GB',   '2025-01-10', 2, 129990.00),
(N'Электроника', N'iPhone 15 Pro 128GB',       '2025-01-22', 1, 109990.00),
(N'Электроника', N'iPhone 15 128GB',           '2025-02-05', 3,  89990.00),
(N'Электроника', N'iPhone 14 Plus 128GB',      '2025-03-12', 1,  79990.00),
(N'Электроника', N'iPhone SE (3rd Gen) 64GB',  '2025-05-18', 4,  37990.00),
(N'Электроника', N'iPhone 15 Pro Max 512GB',   '2025-11-08', 1, 149990.00);
GO

---------------------------------------------------------------
-- 4) Итоговый отчёт (алиасы на русском)
---------------------------------------------------------------
WITH base AS (
  SELECT *
  FROM dbo.Sales
  WHERE SaleDate BETWEEN CAST('2025-01-01' AS DATE)
                      AND CAST('2025-12-31' AS DATE)
),
kpi AS (
  SELECT
    COUNT(*)         AS количество_продаж,
    SUM(TotalAmount) AS выручка,
    AVG(TotalAmount) AS средний_чек,
    MAX(TotalAmount) AS максимальная_продажа,
    MIN(TotalAmount) AS минимальная_продажа
  FROM base
),
top_product AS (
  SELECT TOP (1)
    ProductName      AS топ_товар,
    SUM(TotalAmount) AS выручка_топ_товара
  FROM base
  GROUP BY ProductName
  ORDER BY SUM(TotalAmount) DESC
),
top_month AS (
  SELECT TOP (1)
    SaleMonth        AS лучший_месяц,
    SUM(TotalAmount) AS выручка_лучшего_месяца
  FROM base
  GROUP BY SaleMonth
  ORDER BY SUM(TotalAmount) DESC
)
SELECT
  k.количество_продаж,
  k.выручка,
  k.средний_чек,
  k.максимальная_продажа,
  k.минимальная_продажа,
  p.топ_товар,
  p.выручка_топ_товара,
  m.лучший_месяц,
  m.выручка_лучшего_месяца
FROM kpi k
CROSS JOIN top_product p
CROSS JOIN top_month m;
GO
