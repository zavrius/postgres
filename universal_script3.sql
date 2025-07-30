/*
 * Исходный скрипт (Oracle-формат) с комментариями о проблемах в PostgreSQL
 * ВНИМАНИЕ: Этот скрипт не будет работать в PostgreSQL без изменений!
 */

-- 1. Комментарий в Oracle-стиле - НЕ РАБОТАЕТ в PostgreSQL
rem Это комментарий
/* PostgreSQL использует только -- для однострочных и /* */ для многострочных комментариев */

-- 2. Создание таблицы - ЧАСТИЧНО РАБОТАЕТ с проблемами
CREATE TABLE IF NOT EXISTS EMPLOYEES(
        EMPLOYEE_ID INTEGER,
        FIRST_NAME VARCHAR2(20),  -- НЕ РАБОТАЕТ: VARCHAR2 это Oracle-тип, в PostgreSQL нужно VARCHAR
        LAST_NAME VARCHAR2(25),   -- Аналогичная проблема
        EMAIL VARCHAR2(25),
        PHONE_NUMBER VARCHAR2(20),
        HIRE_DATE DATE,
        JOB_ID VARCHAR2(10),
        SALARY NUMERIC(8,2));     -- РАБОТАЕТ, но в PostgreSQL чаще используют DECIMAL

-- 3. Создание процедуры - НЕ РАБОТАЕТ в PostgreSQL
CREATE OR REPLACE PROCEDURE
add_employee(NAME VARCHAR2, SURNAME VARCHAR2, SAL NUMERIC) IS  -- НЕ РАБОТАЕТ:
                                                               -- 1) VARCHAR2 вместо VARCHAR
                                                               -- 2) "IS" вместо "AS $$"
                                                               -- 3) Нет указания языка
BEGIN
        INSERT INTO employees (FIRST_NAME, LAST_NAME, SALARY)  -- НЕ РАБОТАЕТ:
                                                               -- 1) Нет значения для обязательных полей (EMPLOYEE_ID)
                                                               -- 2) Нет DEFAULT для обязательных полей в таблице
        VALUES (NAME, SURNAME, SAL);
END add_employee;  -- НЕ РАБОТАЕТ: Нет $$ LANGUAGE plpgsql в конце

-- 4. Вызов процедуры - ЧАСТИЧНО РАБОТАЕТ
CALL add_employee('Andrei', 'Soloviev', 120000);  -- РАБОТАЕТ, если процедура создана правильно
EXEC add_employee('Sergei', 'Petrov', 133000);    -- НЕ РАБОТАЕТ: EXEC это Oracle-команда

-- 5. Выборка данных - РАБОТАЕТ
SELECT * FROM EMPLOYEES;  -- Полностью совместимый SQL

-- 6. Удаление объектов - ЧАСТИЧНО РАБОТАЕТ
DROP PROCEDURE add_employee;  -- РАБОТАЕТ, но лучше добавить IF EXISTS
DROP TABLE EMPLOYEES;         -- РАБОТАЕТ, но лучше добавить IF EXISTS

/*
 * Основные причины несовместимости:
 * 1. Использование Oracle-специфичных типов данных (VARCHAR2)
 * 2. Синтаксис создания процедур (IS вместо AS $$, нет LANGUAGE)
 * 3. Команда EXEC вместо CALL/DO
 * 4. Отсутствие обработки обязательных полей (EMPLOYEE_ID)
 * 5. Использование rem для комментариев
 */
