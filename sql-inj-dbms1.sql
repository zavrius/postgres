-- Drop database if exists
DROP DATABASE IF EXISTS dbms1;

-- Create database
CREATE DATABASE dbms1;

-- Connect to the new database (в интерактивном psql делай так):
-- \c dbms1

-- Drop tables if they exist
DROP TABLE IF EXISTS persons;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS orders;

-- Create persons table
CREATE TABLE persons (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT
);

-- Create products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(100)
);

-- Create orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    person_id INT REFERENCES persons(id),
    product_id INT REFERENCES products(id)
);

-- Insert data into persons
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

-- Insert data into products
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

-- Insert data into orders
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

-- Check data
SELECT * FROM persons;
SELECT * FROM products;
SELECT * FROM orders;