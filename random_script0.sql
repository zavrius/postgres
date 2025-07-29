-- Создаем таблицу для хранения случайных чисел
CREATE TABLE RandomNumbers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    random_value INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Вставляем 10 случайных чисел от 1 до 100
INSERT INTO RandomNumbers (random_value)
SELECT RANDOM(1, 100) FROM GENERATE_SERIES(1, 10);

-- Просмотр результатов
SELECT * FROM RandomNumbers;