-- ======================================================
-- Полный скрипт для базы dbms1
-- Создаёт базу, таблицы и заполняет данными
-- ======================================================

-- 1. Удаляем базу, если существует
DROP DATABASE IF EXISTS dbms1;

-- 2. Создание базы
CREATE DATABASE dbms1;

-- 3. Подключаемся к базе dbms1
\c dbms1

-- ======================================================
-- 4. Таблица persons (люди)
DROP TABLE IF EXISTS persons;
CREATE TABLE persons (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT
);

-- 5. Таблица products (товары)
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(100)
);

-- 6. Таблица orders (заказы)
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    person_id INT REFERENCES persons(id),
    product_id INT REFERENCES products(id)
);

-- ======================================================
-- 7. Заполнение таблицы persons
INSERT INTO persons (first_name, last_name, age) VALUES
('John', 'Smith', 28),
('Emily', 'Johnson', 32),
('Michael', 'Brown', 41),
('Sarah', 'Davis', 25),
('David', 'Wilson', 36),
('Laura', 'Moore', 29),
('James', 'Taylor', 50),
('Olivia', 'Anderson', 22),
('Daniel', 'Thomas', 33),
('Sophia', 'Jackson', 27);

-- 8. Заполнение таблицы products
INSERT INTO products (product_name) VALUES
('Laptop'),
('Smartphone'),
('Headphones'),
('Tablet'),
('Smartwatch'),
('Keyboard'),
('Mouse'),
('Monitor'),
('Printer'),
('Camera');

-- 9. Заполнение таблицы orders
INSERT INTO orders (person_id, product_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- 10. Проверка данных
SELECT * FROM persons;
SELECT * FROM products;
SELECT * FROM orders;