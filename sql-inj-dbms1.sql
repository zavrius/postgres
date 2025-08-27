-- ======================================================
-- Полный скрипт для базы dbms1 с пользователем user1
-- Создаёт базу, пользователя, таблицы и заполняет данными
-- ======================================================

-- 1. Удаляем базу и пользователя, если они существуют
DROP DATABASE IF EXISTS dbms1;
DROP USER IF EXISTS user1 CASCADE;

-- 2. Создание базы
CREATE DATABASE dbms1;

-- 3. Создание пользователя и выдача базовых прав
CREATE USER user1 WITH PASSWORD 'user1';
GRANT CONNECT ON DATABASE dbms1 TO user1;

-- 4. Подключаемся к базе dbms1
\c dbms1

-- 5. Даем права пользователю user1 на схему public
GRANT USAGE ON SCHEMA public TO user1;

-- Таблицы ещё не созданы, поэтому права на них будем выдавать после создания
-- ======================================================
-- 6. Таблица persons (люди)
DROP TABLE IF EXISTS persons;
CREATE TABLE persons (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT
);

-- 7. Таблица products (товары)
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(100)
);

-- 8. Таблица orders (заказы)
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    person_id INT REFERENCES persons(id),
    product_id INT REFERENCES products(id)
);

-- 9. Выдаём полные права на все таблицы пользователю user1
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO user1;

-- 10. Заполнение таблицы persons
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

-- 11. Заполнение таблицы products
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

-- 12. Заполнение таблицы orders
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

-- 13. Проверка данных
SELECT * FROM persons;
SELECT * FROM products;
SELECT * FROM orders;