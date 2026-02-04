/* This script is developed
 * by the Diasoft company
 * for preliminary demonstration of the functionality
 * of the Digital Q.DataBase product
 * in Oracle Database emulation mode */

REM Store products table received from the warehouse
CREATE TABLE product_descriptions (
    product_id NUMBER PRIMARY KEY, -- product id
    product_name VARCHAR2(100), -- product name
    description CLOB, -- product description
    return_date DATE, -- return date back to warehouse
    created_date DATE DEFAULT SYSDATE -- creation date of received product card
);

REM Package specification with 2 procedures
CREATE OR REPLACE PACKAGE product_utils AS
    -- Add a new product to the system
    PROCEDURE add_product_description(
        p_id NUMBER, -- product id
        p_name VARCHAR2, -- product name
        p_text VARCHAR2 -- product description
    );
    
    -- Display product information by id
    PROCEDURE show_description(
        p_id NUMBER -- product id
    );
END product_utils;
/

REM Package body implementation
CREATE OR REPLACE PACKAGE BODY product_utils AS
    PROCEDURE add_product_description( 
        p_id NUMBER,
        p_name VARCHAR2,
        p_text VARCHAR2
    ) IS
        v_clob CLOB; -- local variables
        v_current_date DATE;
        
    BEGIN
        DBMS_LOB.CREATETEMPORARY(v_clob, TRUE); -- Create temporary CLOB    
        DBMS_LOB.WRITE(v_clob, LENGTH(p_text), 1, p_text); -- Write p_text into v_clob      
        SELECT SYSDATE INTO v_current_date FROM DUAL; -- Store current date into variable        
        -- Save everything into the table, adding 2 months to the return date:
        INSERT INTO product_descriptions (product_id, product_name, description, return_date)
        VALUES (p_id, p_name, v_clob, ADD_MONTHS(v_current_date, 2));     
        DBMS_LOB.FREETEMPORARY(v_clob); -- Free temporary CLOB
    END;
    
    PROCEDURE show_description(
        p_id NUMBER
    ) IS
        v_clob CLOB; -- local variables
        v_buffer VARCHAR2(4000);
        v_amount_to_read NUMBER := 4000;
        v_product_name VARCHAR2(100);
        v_return_date DATE;
    BEGIN
        SELECT product_name INTO v_product_name FROM product_descriptions WHERE product_id = p_id;
        SELECT description INTO v_clob FROM product_descriptions WHERE product_id = p_id;
        DBMS_LOB.READ(v_clob, v_amount_to_read, 1, v_buffer); -- Read first 4000 characters
        SELECT return_date INTO v_return_date FROM product_descriptions WHERE product_id = p_id;
        -- Output result
        DBMS_OUTPUT.PUT_LINE('Product name: ' || v_product_name);
        DBMS_OUTPUT.PUT_LINE('Product description: ' || v_buffer);
        DBMS_OUTPUT.PUT_LINE('Return date back to warehouse: ' || v_return_date);
    END;
END product_utils;
/

REM Standalone function to check product return date expiration
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
        v_result := 'Return date to warehouse has EXPIRED';
    ELSE
        v_result := 'Return date to warehouse has NOT expired';
    END IF;
    
    RETURN v_result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Product with specified ID was not found';
END is_return_date_expired;
/

REM Enable console output
SET SERVEROUTPUT ON

REM Test block. Calling created objects via anonymous block.
DECLARE
    v_product_id NUMBER := 1;  -- product id
    v_product_name VARCHAR2(100) := 'ASUS TUF Gaming A15';
    v_description VARCHAR2(4000) := '1920x1080, IPS, AMD Ryzen 5 7535HS, cores: 6, RAM 16 GB, SSD 512 GB, GeForce RTX 2050 Laptop GPU 4 GB, no OS';
BEGIN
    -- Clean table before test
    DELETE FROM product_descriptions WHERE product_id = v_product_id;
    
    -- Add product description
    product_utils.add_product_description(v_product_id, v_product_name, v_description);    
    -- Show description
    product_utils.show_description(v_product_id);
    -- Check product return date using standalone function
    DBMS_OUTPUT.PUT_LINE('Return date check: ' || is_return_date_expired(v_product_id));
    -- Clean table after test
    DELETE FROM product_descriptions WHERE product_id = v_product_id;
END;
/

REM Cleanup objects
DROP PACKAGE product_utils;
DROP FUNCTION is_return_date_expired;
DROP TABLE product_descriptions;
