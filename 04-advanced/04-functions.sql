-- ============================================
-- FUNCTIONS AND STORED PROCEDURES
-- ============================================
-- Reusable database logic

-- ============================================
-- BASIC FUNCTION
-- ============================================

-- Simple function that returns a value
CREATE OR REPLACE FUNCTION calculate_tax(amount NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN amount * 0.08;  -- 8% tax
END;
$$ LANGUAGE plpgsql;

-- Use the function
SELECT calculate_tax(100.00);
SELECT calculate_tax(250.50);

-- ============================================
-- FUNCTION WITH MULTIPLE PARAMETERS
-- ============================================

CREATE OR REPLACE FUNCTION calculate_discount(
    price NUMERIC,
    discount_percent NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN price * (1 - discount_percent / 100);
END;
$$ LANGUAGE plpgsql;

-- Test it
SELECT calculate_discount(100.00, 10);  -- 10% off
SELECT calculate_discount(250.00, 25);  -- 25% off

-- ============================================
-- FUNCTION RETURNING TABLE
-- ============================================

CREATE OR REPLACE FUNCTION get_high_earners(min_salary NUMERIC)
RETURNS TABLE(
    employee_name TEXT,
    employee_salary NUMERIC,
    dept_name VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.first_name || ' ' || e.last_name,
        e.salary,
        d.department_name
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE e.salary >= min_salary
    ORDER BY e.salary DESC;
END;
$$ LANGUAGE plpgsql;

-- Use the function
SELECT * FROM get_high_earners(80000);

-- ============================================
-- FUNCTION WITH DEFAULT PARAMETERS
-- ============================================

CREATE OR REPLACE FUNCTION greet_employee(
    first_name VARCHAR,
    title VARCHAR DEFAULT 'Employee'
)
RETURNS TEXT AS $$
BEGIN
    RETURN 'Hello, ' || title || ' ' || first_name || '!';
END;
$$ LANGUAGE plpgsql;

-- Call with both parameters
SELECT greet_employee('Alice', 'Manager');

-- Call with default
SELECT greet_employee('Bob');

-- ============================================
-- FUNCTION WITH CONDITIONAL LOGIC
-- ============================================

CREATE OR REPLACE FUNCTION get_salary_grade(salary NUMERIC)
RETURNS VARCHAR AS $$
BEGIN
    IF salary >= 90000 THEN
        RETURN 'A - Excellent';
    ELSIF salary >= 80000 THEN
        RETURN 'B - Very Good';
    ELSIF salary >= 70000 THEN
        RETURN 'C - Good';
    ELSE
        RETURN 'D - Entry Level';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Test it
SELECT 
    first_name,
    last_name,
    salary,
    get_salary_grade(salary) AS grade
FROM employees;

-- ============================================
-- FUNCTION WITH LOOPS
-- ============================================

CREATE OR REPLACE FUNCTION generate_series_sum(max_num INTEGER)
RETURNS INTEGER AS $$
DECLARE
    total INTEGER := 0;
    counter INTEGER := 1;
BEGIN
    WHILE counter <= max_num LOOP
        total := total + counter;
        counter := counter + 1;
    END LOOP;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- Sum of numbers 1 to 10
SELECT generate_series_sum(10);

-- ============================================
-- FUNCTION WITH FOR LOOP
-- ============================================

CREATE OR REPLACE FUNCTION count_employees_by_dept()
RETURNS TABLE(dept_name VARCHAR, emp_count BIGINT) AS $$
DECLARE
    dept RECORD;
BEGIN
    FOR dept IN SELECT department_id, department_name FROM departments LOOP
        dept_name := dept.department_name;
        SELECT COUNT(*) INTO emp_count
        FROM employees
        WHERE department_id = dept.department_id;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM count_employees_by_dept();

-- ============================================
-- FUNCTION WITH EXCEPTION HANDLING
-- ============================================

CREATE OR REPLACE FUNCTION safe_divide(numerator NUMERIC, denominator NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN numerator / denominator;
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'Cannot divide by zero!';
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE NOTICE 'An error occurred: %', SQLERRM;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Test it
SELECT safe_divide(10, 2);
SELECT safe_divide(10, 0);

-- ============================================
-- FUNCTION THAT MODIFIES DATA
-- ============================================

CREATE OR REPLACE FUNCTION give_raise(
    emp_id INTEGER,
    raise_percent NUMERIC
)
RETURNS VOID AS $$
DECLARE
    current_salary NUMERIC;
BEGIN
    -- Get current salary
    SELECT salary INTO current_salary
    FROM employees
    WHERE employee_id = emp_id;
    
    -- Update salary
    UPDATE employees
    SET salary = salary * (1 + raise_percent / 100)
    WHERE employee_id = emp_id;
    
    RAISE NOTICE 'Salary updated from % to %', 
                 current_salary, 
                 current_salary * (1 + raise_percent / 100);
END;
$$ LANGUAGE plpgsql;

-- Give employee 1 a 5% raise
-- SELECT give_raise(1, 5);
-- SELECT salary FROM employees WHERE employee_id = 1;

-- ============================================
-- STORED PROCEDURES (PostgreSQL 11+)
-- ============================================
-- Unlike functions, procedures don't return values but can COMMIT/ROLLBACK

CREATE OR REPLACE PROCEDURE update_all_salaries(raise_percent NUMERIC)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE employees
    SET salary = salary * (1 + raise_percent / 100);
    
    RAISE NOTICE 'Updated all employee salaries by %', raise_percent;
    COMMIT;
END;
$$;

-- Call procedure
-- CALL update_all_salaries(2);

-- ============================================
-- FUNCTION WITH OUT PARAMETERS
-- ============================================

CREATE OR REPLACE FUNCTION get_employee_stats(
    dept_id INTEGER,
    OUT emp_count INTEGER,
    OUT avg_salary NUMERIC,
    OUT max_salary NUMERIC
)
AS $$
BEGIN
    SELECT 
        COUNT(*),
        AVG(salary),
        MAX(salary)
    INTO emp_count, avg_salary, max_salary
    FROM employees
    WHERE department_id = dept_id;
END;
$$ LANGUAGE plpgsql;

-- Use it
SELECT * FROM get_employee_stats(1);

-- ============================================
-- TRIGGER FUNCTIONS
-- ============================================
-- Special functions called by triggers

CREATE OR REPLACE FUNCTION log_salary_changes()
RETURNS TRIGGER AS $$
BEGIN
    -- Create log table if needed
    CREATE TABLE IF NOT EXISTS salary_audit (
        audit_id SERIAL PRIMARY KEY,
        employee_id INTEGER,
        old_salary NUMERIC,
        new_salary NUMERIC,
        changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    INSERT INTO salary_audit (employee_id, old_salary, new_salary)
    VALUES (NEW.employee_id, OLD.salary, NEW.salary);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- (Trigger creation in next file)

-- ============================================
-- AGGREGATE FUNCTIONS (Advanced)
-- ============================================
-- Custom aggregate functions

-- Median function example (simplified)
CREATE OR REPLACE FUNCTION array_median(anyarray)
RETURNS NUMERIC AS $$
    SELECT AVG(val)
    FROM (
        SELECT val
        FROM unnest($1) val
        ORDER BY 1
        LIMIT 2 - MOD(array_upper($1, 1), 2)
        OFFSET CEIL(array_upper($1, 1) / 2.0) - 1
    ) sub;
$$ LANGUAGE sql IMMUTABLE;

-- ============================================
-- FUNCTION VOLATILITY
-- ============================================

-- IMMUTABLE: Always returns same result for same input
CREATE OR REPLACE FUNCTION add_numbers(a INTEGER, b INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN a + b;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- STABLE: Result depends on database state but not within single statement
CREATE OR REPLACE FUNCTION get_current_employee_count()
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM employees);
END;
$$ LANGUAGE plpgsql STABLE;

-- VOLATILE: Can change within single statement (default)
CREATE OR REPLACE FUNCTION get_random_employee()
RETURNS TABLE(first_name VARCHAR, last_name VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT e.first_name, e.last_name
    FROM employees e
    ORDER BY RANDOM()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql VOLATILE;

-- ============================================
-- VIEW FUNCTION DETAILS
-- ============================================

-- List all functions
SELECT 
    n.nspname AS schema,
    p.proname AS function_name,
    pg_get_function_arguments(p.oid) AS arguments,
    pg_get_function_result(p.oid) AS return_type
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
    AND p.prokind = 'f'  -- 'f' for function, 'p' for procedure
ORDER BY p.proname;

-- Get function definition
SELECT pg_get_functiondef('calculate_tax'::regproc);

-- ============================================
-- DROP FUNCTIONS
-- ============================================

-- Drop specific function (need to specify parameter types)
DROP FUNCTION IF EXISTS calculate_tax(NUMERIC);
DROP FUNCTION IF EXISTS calculate_discount(NUMERIC, NUMERIC);
DROP FUNCTION IF EXISTS get_high_earners(NUMERIC);
DROP FUNCTION IF EXISTS greet_employee(VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS get_salary_grade(NUMERIC);

-- Drop procedure
DROP PROCEDURE IF EXISTS update_all_salaries(NUMERIC);

-- ============================================
-- BEST PRACTICES
-- ============================================

/*
1. Use meaningful function names
2. Add comments to document complex logic
3. Handle exceptions appropriately
4. Use correct volatility classification
5. Keep functions focused and simple
6. Use RETURNS TABLE for multiple rows
7. Use OUT parameters for multiple scalar values
8. Consider security (SECURITY DEFINER vs SECURITY INVOKER)
9. Test functions thoroughly
10. Use functions for business logic, not just simple calculations
*/
