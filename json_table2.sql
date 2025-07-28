CREATE TABLE event_logs (
    id SERIAL PRIMARY KEY,
    user_event JSONB NOT NULL
);

INSERT INTO event_logs (user_event) VALUES 
('{"geo": {"country": "US", "city": "New York"}, "event": "login", "timestamp": "2023-01-01T10:00:00"}'),
('{"geo": {"country": "US", "city": "Los Angeles"}, "event": "purchase", "timestamp": "2023-01-01T11:00:00"}'),
('{"geo": {"country": "DE", "city": "Berlin"}, "event": "login", "timestamp": "2023-01-01T12:00:00"}'),
('{"geo": {"country": "FR", "city": "Paris"}, "event": "view", "timestamp": "2023-01-01T13:00:00"}'),
('{"geo": {"country": "US", "city": "Chicago"}, "event": "purchase", "timestamp": "2023-01-01T14:00:00"}');

SELECT id, user_event FROM event_logs;

SELECT country, COUNT(*) AS event_count
FROM JSON_TABLE(
    :user_event,
    '$'
    COLUMNS (
        country TEXT PATH '$.geo.country'
    )
) AS data
GROUP BY country;

SELECT 
    data.country,
    COUNT(*) AS event_count
FROM 
    event_logs,
    JSON_TABLE(
        event_logs.user_event,
        '$'
        COLUMNS (
            country TEXT PATH '$.geo.country'
        )
    ) AS data
GROUP BY data.country;