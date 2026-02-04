/* This script is developed
 * by the Diasoft company
 * for preliminary demonstration of the functionality
 * of the Digital Q.DataBase product
 * via connection using the TDS (MSSQL) protocol */

-- Set date format
SET dateformat dmy
go

-- Create table for sales tracking
IF OBJECT_ID('Sales', 'U') IS NOT NULL
    DROP TABLE Sales
go

CREATE TABLE Sales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    SaleDate DATE DEFAULT GETDATE(),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalAmount AS (Quantity * UnitPrice), -- Computed column
    SaleMonth AS (FORMAT(SaleDate, 'yyyy-MM')) -- Computed column for analytics
)
go

-- Insert test data
INSERT INTO Sales (ProductName, SaleDate, Quantity, UnitPrice) VALUES
    ('ASUS VivoBook Laptop', '15.01.2024', 2, 45000.00),
    ('Wireless Mouse', '18.01.2024', 5, 1200.00),
    ('24-inch Monitor', '22.01.2024', 1, 18000.00),
    ('Mechanical Keyboard', '15.02.2024', 3, 3500.00),
    ('Lenovo IdeaPad Laptop', '28.02.2024', 1, 52000.00),
    ('Mouse Pad', '05.03.2024', 10, 500.00)
go

-- Procedure for sales analysis by period
IF OBJECT_ID('GetSalesReport', 'P') IS NOT NULL
    DROP PROCEDURE GetSalesReport
go

CREATE PROCEDURE GetSalesReport
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    -- Overall statistics for the period
    SELECT 
        COUNT(*) as 'Number of sales',
        SUM(TotalAmount) as 'Total revenue',
        AVG(TotalAmount) as 'Average check',
        MAX(TotalAmount) as 'Maximum sale',
        MIN(TotalAmount) as 'Minimum sale'
    FROM Sales 
    WHERE SaleDate BETWEEN @StartDate AND @EndDate
    
    -- Breakdown by products
    SELECT 
        ProductName as 'Product',
        SUM(Quantity) as 'Quantity',
        SUM(TotalAmount) as 'Amount',
        FORMAT(
            SUM(TotalAmount) * 100.0 / 
            (SELECT SUM(TotalAmount) 
             FROM Sales 
             WHERE SaleDate BETWEEN @StartDate AND @EndDate),
            'N2'
        ) + '%' as 'Revenue share'
    FROM Sales 
    WHERE SaleDate BETWEEN @StartDate AND @EndDate
    GROUP BY ProductName
    ORDER BY SUM(TotalAmount) DESC
    
    -- Monthly sales
    SELECT 
        SaleMonth as 'Month',
        COUNT(*) as 'Number of sales',
        SUM(TotalAmount) as 'Revenue'
    FROM Sales 
    WHERE SaleDate BETWEEN @StartDate AND @EndDate
    GROUP BY SaleMonth
    ORDER BY SaleMonth
END
go

-- Procedure for manager bonus calculation
IF OBJECT_ID('CalculateManagerBonus', 'P') IS NOT NULL
    DROP PROCEDURE CalculateManagerBonus
go

CREATE PROCEDURE CalculateManagerBonus
    @TargetAmount DECIMAL(10,2) = 100000
AS
BEGIN
    SELECT 
        SaleMonth as 'Month',
        SUM(TotalAmount) as 'Actual revenue',
        @TargetAmount as 'Target revenue',
        CASE 
            WHEN SUM(TotalAmount) >= @TargetAmount THEN 'Target achieved'
            ELSE 'Target not achieved'
        END as 'Status',
        CASE 
            WHEN SUM(TotalAmount) >= @TargetAmount THEN SUM(TotalAmount) * 0.05
            ELSE 0
        END as 'Manager bonus'
    FROM Sales
    GROUP BY SaleMonth
    ORDER BY SaleMonth
END
go

-- Demonstration

-- Sales analysis for Q1 2024
EXEC GetSalesReport '01.01.2024', '31.03.2024'
go

-- Manager bonus calculation
EXEC CalculateManagerBonus @TargetAmount = 50000
go

-- Quick analysis of current sales
SELECT 
    'Current month: ' + FORMAT(GETDATE(), 'MMMM yyyy') as 'Period',
    (SELECT COUNT(*) 
     FROM Sales 
     WHERE SaleDate >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
    ) as 'Sales this month',
    (SELECT SUM(TotalAmount) 
     FROM Sales 
     WHERE SaleDate >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
    ) as 'Revenue this month'
go

-- Cleanup
IF OBJECT_ID('Sales', 'U') IS NOT NULL
    DROP TABLE Sales
go

IF OBJECT_ID('GetSalesReport', 'P') IS NOT NULL
    DROP PROCEDURE GetSalesReport
go

IF OBJECT_ID('CalculateManagerBonus', 'P') IS NOT NULL
    DROP PROCEDURE CalculateManagerBonus
go
