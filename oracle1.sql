/* Данный скрипт разработан
 * в компании Диасофт
 * для предварительного показа функционала 
 * продукта Digital Q.DataBase
 * в режиме эмуляции СУБД Oracle Database */

REM Таблица товаров магазина, прибывших со склада
CREATE TABLE product_descriptions (
    product_id NUMBER PRIMARY KEY, --id товара
	product_name VARCHAR2(100), --наименование товара
    description CLOB, --описание товара
	return_date DATE, --дата отправки обратно на склад
	created_date DATE DEFAULT SYSDATE --дата создания карточки принятого товара
);

REM Пакет с 2 процедурами
CREATE OR REPLACE PACKAGE product_utils AS
    --Добавление нового товара в систему
	PROCEDURE add_product_description(
        p_id NUMBER, --id товара
		p_name VARCHAR2, --наименование товара
        p_text VARCHAR2 --описание товара
    );
    
    --Отображение информации о товаре по id
	PROCEDURE show_description(
        p_id NUMBER --id товара
    );
END product_utils;
/

REM Реализация пакета
CREATE OR REPLACE PACKAGE BODY product_utils AS
    PROCEDURE add_product_description( 
        p_id NUMBER,
		p_name VARCHAR2,
        p_text VARCHAR2
    ) IS
		v_clob CLOB; --Локальные переменные
		v_current_date DATE;
		
    BEGIN
        DBMS_LOB.CREATETEMPORARY(v_clob, TRUE); --Создаем временный CLOB    
        DBMS_LOB.WRITE(v_clob, LENGTH(p_text), 1, p_text); --Записываем текст p_text в v_clob      
		SELECT SYSDATE INTO v_current_date FROM DUAL; --Записываем текущую дату в переменную		
        --Сохраняем все в таблицу, прибавив 2 месяца к дате отправки на склад:
        INSERT INTO product_descriptions (product_id, product_name, description, return_date)
		VALUES (p_id, p_name, v_clob, ADD_MONTHS(v_current_date, 2));     
        DBMS_LOB.FREETEMPORARY(v_clob); --Освобождаем временный CLOB
    END;
    
    PROCEDURE show_description(
        p_id NUMBER
    ) IS
        v_clob CLOB; --Локальные переменные
        v_buffer VARCHAR2(4000);
		v_amount_to_read NUMBER := 4000;
		v_product_name VARCHAR2(100);
		v_return_date DATE;
    BEGIN
        SELECT product_name INTO v_product_name FROM product_descriptions WHERE product_id = p_id;
        SELECT description INTO v_clob FROM product_descriptions WHERE product_id = p_id;
        DBMS_LOB.READ(v_clob, v_amount_to_read, 1, v_buffer); --Читаем первые 4000 символов
        SELECT return_date INTO v_return_date FROM product_descriptions WHERE product_id = p_id;
        --Выводим результат
        DBMS_OUTPUT.PUT_LINE('Наименование товара: ' || v_product_name);
		DBMS_OUTPUT.PUT_LINE('Описание товара: ' || v_buffer);
		DBMS_OUTPUT.PUT_LINE('Дата отправки обратно на склад: ' || v_return_date);
    END;
END product_utils;
/

REM Внепакетная функция для проверки истечения срока возврата товара
CREATE OR REPLACE FUNCTION is_return_date_expired(
    p_product_id NUMBER
) RETURN VARCHAR2
IS
    v_return_date DATE;
    v_result VARCHAR2(100);
BEGIN
    SELECT return_date INTO v_return_date 
    FROM product_descriptions 
    WHERE product_id = p_product_id;
    
    IF v_return_date < SYSDATE THEN
        v_result := 'Дата возврата на склад ИСТЕКЛА';
    ELSE
        v_result := 'Дата возврата на склад НЕ истекла';
    END IF;
    
    RETURN v_result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Товар с указанным ID не найден';
END is_return_date_expired;
/

SET SERVEROUTPUT ON

REM Тестовый блок
DECLARE
    v_product_id NUMBER := 1;  -- id товара
	v_product_name VARCHAR2(100) := 'ASUS TUF Gaming A15';
	v_description VARCHAR2(4000) := '1920x1080, IPS, AMD Ryzen 5 7535HS, ядра: 6, RAM 16 ГБ, SSD 512 ГБ, GeForce RTX 2050 для ноутбуков 4 ГБ, без ОС';
BEGIN
    -- Очищаем таблицу перед тестом
    DELETE FROM product_descriptions WHERE product_id = v_product_id;
	
	-- Добавляем описание товара
    product_utils.add_product_description(v_product_id, v_product_name, v_description);    
    -- Просматриваем описание
    product_utils.show_description(v_product_id);
	-- Проверяем срок возврата товара с помощью внепакетной функции
    DBMS_OUTPUT.PUT_LINE('Проверка срока возврата: ' || is_return_date_expired(v_product_id));
	-- Очищаем таблицу после теста
	DELETE FROM product_descriptions WHERE product_id = v_product_id;
END;
/

REM Зачистка объектов
DROP PACKAGE product_utils;
DROP FUNCTION is_return_date_expired;
DROP TABLE product_descriptions;
