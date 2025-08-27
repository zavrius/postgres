-- 1. Удаляем базу и пользователя, если они существуют
DROP DATABASE IF EXISTS dbms1;
DROP USER IF EXISTS user1;

-- 2. Создание базы
CREATE DATABASE dbms1;

-- 3. Создание пользователя и права
CREATE USER user1 WITH PASSWORD 'user1';
GRANT CONNECT ON DATABASE dbms1 TO user1;

-- 4. Подключение к базе
\c dbms1

-- Даем права пользователю user1 на схему public
GRANT USAGE ON SCHEMA public TO user1;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO user1;

-- 5. Таблица людей
DROP TABLE IF EXISTS persons;
CREATE TABLE persons (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT
);

-- 6. Таблица товаров
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(100)
);

-- 7. Таблица заказов
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    person_id INT REFERENCES persons(id),
    product_id INT REFERENCES products(id)
);

-- 8. Заполнение таблицы persons
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

-- 9. Заполнение таблицы products
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

-- 10. Заполнение таблицы orders
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

-- 11. Проверка данных
SELECT * FROM persons;
SELECT * FROM products;
SELECT * FROM orders;