CREATE TABLE user_settings (
    user_id SERIAL PRIMARY KEY,
    json_config JSONB NOT NULL
);

INSERT INTO user_settings (json_config) VALUES
('{"theme":"dark","prefs":{"ui":{"font":"Arial","size":12},"notifications":{"email":true,"sms":false}}}'),
('{"theme":"light","prefs":{"ui":{"font":"Roboto","size":14},"notifications":{"email":false,"sms":true}}}'),
('{"theme":"dark","prefs":{"ui":{"font":"Helvetica","size":16},"notifications":{"email":true,"sms":true}}}');

SELECT user_id
FROM user_settings
WHERE json_config->>'theme' = 'dark';