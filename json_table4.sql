CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    json_data JSONB NOT NULL
);

INSERT INTO orders (json_data) VALUES
('{"delivery": {"status": "shipped", "address": "Moscow"}, "items": [{"name": "Laptop", "price": 999}]}'),
('{"delivery": {"status": "pending", "address": "Berlin"}, "items": [{"name": "Phone", "price": 599}]}'),
('{"delivery": {"status": "shipped", "address": "Paris"}, "items": [{"name": "Tablet", "price": 399}]}'),
('{"delivery": {"status": "delivered", "address": "London"}, "items": [{"name": "Monitor", "price": 199}]}');

SELECT *
FROM orders
WHERE json_data->'delivery'->>'status' = 'shipped';