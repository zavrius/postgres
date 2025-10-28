-- 1. Создаём тестовую базу
-- CREATE DATABASE ms_test1;
-- GO

-- 2. Переходим в неё
USE ms_test1;
GO

-- 3. Создаём таблицу users
CREATE TABLE users (
    id INT PRIMARY KEY IDENTITY(1,1),
    username VARCHAR(50),
    email VARCHAR(100)
);
GO

-- 4. Создаём таблицу orders
CREATE TABLE orders (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT,
    product VARCHAR(100),
    amount DECIMAL(10,2),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
GO

-- 5. Вставляем немного данных
INSERT INTO users (username, email)
VALUES ('alice', 'alice@example.com'),
       ('bob', 'bob@example.com');
GO

INSERT INTO orders (user_id, product, amount)
VALUES (1, 'Coffee', 3.50),
       (1, 'Tea', 2.00),
       (2, 'Book', 12.99);
GO

-- 6. Смотрим, что получилось
SELECT * FROM users;
GO

SELECT * FROM orders;
GO
