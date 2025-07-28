CREATE TABLE payments (
    id TEXT,
    amount NUMERIC,
    currency TEXT
);

INSERT INTO payments (id, amount, currency)
SELECT *
FROM JSON_TABLE(
    '{"payments":[{"payment_id":"pay1","sum":100.50,"curr":"USD"},{"payment_id":"pay2","sum":200.75,"curr":"EUR"}]}'::json,
    '$.payments[*]'
    COLUMNS (
        id TEXT PATH '$.payment_id',
        amount NUMERIC PATH '$.sum',
        currency TEXT PATH '$.curr'
    )
);

SELECT * FROM payments;