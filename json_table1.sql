CREATE TABLE demo_orders (
    id SERIAL PRIMARY KEY,
    order_data JSONB NOT NULL
);

INSERT INTO demo_orders (order_data) VALUES 
('{"items": [{"name": "Laptop", "qty": 1}, {"name": "Mouse", "qty": 2}]}'),
('{"items": [{"name": "Keyboard", "qty": 1}, {"name": "Monitor", "qty": 1}]}'),
('{"items": [{"name": "Phone", "qty": 3}, {"name": "Charger", "qty": 3}]}');

SELECT id, order_data FROM demo_orders;

SELECT item_name, quantity
FROM JSON_TABLE(
    :order_json,
    '$.items[*]'
    COLUMNS (
        item_name TEXT PATH '$.name',
        quantity INT PATH '$.qty'
    )
) AS items;

SELECT 
    o.id AS order_id,
    j.item_name,
    j.quantity
FROM 
    demo_orders o,
    JSON_TABLE(
        o.order_data,
        '$.items[*]'
        COLUMNS (
            item_name TEXT PATH '$.name',
            quantity INT PATH '$.qty'
        )
    ) AS j;