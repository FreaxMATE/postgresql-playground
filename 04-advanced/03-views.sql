-- ============================================
-- VIEWS
-- ============================================
-- Views are virtual tables based on queries
-- They don't store data, just the query definition

-- Setup: Use tables from previous examples
-- If needed, recreate them:

CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    salary NUMERIC(10, 2),
    department_id INTEGER,
    hire_date DATE
);

CREATE TABLE IF NOT EXISTS departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100),
    location VARCHAR(100)
);

-- Insert sample data if tables are empty
INSERT INTO departments (department_name, location) VALUES
    ('Engineering', 'San Francisco'),
    ('Sales', 'New York'),
    ('Marketing', 'Los Angeles')
ON CONFLICT DO NOTHING;

INSERT INTO employees (first_name, last_name, email, salary, department_id, hire_date) VALUES
    ('Alice', 'Johnson', 'alice@company.com', 95000, 1, '2020-01-15'),
    ('Bob', 'Smith', 'bob@company.com', 85000, 1, '2019-03-20'),
    ('Carol', 'Williams', 'carol@company.com', 72000, 2, '2021-06-10')
ON CONFLICT DO NOTHING;

-- ============================================
-- CREATE SIMPLE VIEW
-- ============================================

-- Create a view that combines employee and department data
CREATE VIEW employee_details AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    e.salary,
    d.department_name,
    d.location
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- Query the view just like a table
SELECT * FROM employee_details;

-- Filter the view
SELECT * FROM employee_details WHERE salary > 80000;

-- ============================================
-- CREATE VIEW WITH AGGREGATION
-- ============================================

CREATE VIEW department_summary AS
SELECT 
    d.department_id,
    d.department_name,
    d.location,
    COUNT(e.employee_id) AS employee_count,
    COALESCE(AVG(e.salary), 0) AS avg_salary,
    COALESCE(MAX(e.salary), 0) AS max_salary,
    COALESCE(MIN(e.salary), 0) AS min_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name, d.location;

SELECT * FROM department_summary;

-- ============================================
-- CREATE VIEW WITH COMPLEX LOGIC
-- ============================================

CREATE VIEW high_performing_employees AS
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    e.salary,
    d.department_name,
    CASE 
        WHEN e.salary > 90000 THEN 'Top Tier'
        WHEN e.salary > 80000 THEN 'Senior'
        WHEN e.salary > 70000 THEN 'Mid-Level'
        ELSE 'Junior'
    END AS salary_tier,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) AS years_employed
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.salary > 70000;

SELECT * FROM high_performing_employees;

-- ============================================
-- CREATE OR REPLACE VIEW
-- ============================================
-- Modify an existing view

CREATE OR REPLACE VIEW employee_details AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    e.salary,
    d.department_name,
    d.location,
    e.hire_date  -- Added new column
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- ============================================
-- UPDATABLE VIEWS
-- ============================================
-- Simple views can be updated directly

-- Create a simple view
CREATE VIEW engineering_employees AS
SELECT 
    employee_id,
    first_name,
    last_name,
    email,
    salary
FROM employees
WHERE department_id = 1;

-- You can insert through the view
INSERT INTO engineering_employees (first_name, last_name, email, salary)
VALUES ('David', 'Brown', 'david@company.com', 88000);

-- Update through the view
UPDATE engineering_employees
SET salary = 90000
WHERE first_name = 'David';

-- Delete through the view
-- DELETE FROM engineering_employees WHERE first_name = 'David';

-- Note: Views with joins, aggregations, DISTINCT, GROUP BY, etc. are not directly updatable

-- ============================================
-- WITH CHECK OPTION
-- ============================================
-- Ensures updates/inserts through view match the view's WHERE clause

CREATE OR REPLACE VIEW engineering_employees AS
SELECT 
    employee_id,
    first_name,
    last_name,
    email,
    salary,
    department_id
FROM employees
WHERE department_id = 1
WITH CHECK OPTION;

-- This will work
UPDATE engineering_employees SET salary = 95000 WHERE employee_id = 1;

-- This will fail (tries to change department_id)
-- UPDATE engineering_employees SET department_id = 2 WHERE employee_id = 1;

-- ============================================
-- MATERIALIZED VIEWS
-- ============================================
-- Unlike regular views, materialized views store the actual data
-- Must be refreshed to update data

CREATE MATERIALIZED VIEW department_stats AS
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    SUM(e.salary) AS total_payroll
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;

-- Query materialized view
SELECT * FROM department_stats;

-- Refresh materialized view to update data
REFRESH MATERIALIZED VIEW department_stats;

-- Refresh without locking (allows concurrent reads)
REFRESH MATERIALIZED VIEW CONCURRENTLY department_stats;
-- Note: Requires a unique index on the materialized view

-- Create unique index for concurrent refresh
CREATE UNIQUE INDEX ON department_stats (department_name);

-- ============================================
-- RECURSIVE VIEWS
-- ============================================
-- Views can use recursive CTEs

CREATE VIEW employee_hierarchy AS
WITH RECURSIVE hierarchy AS (
    -- Base case
    SELECT 
        employee_id,
        first_name,
        last_name,
        department_id,
        1 AS level
    FROM employees
    WHERE employee_id = 1  -- Start with a specific employee
    
    UNION ALL
    
    -- Recursive case (would need a manager_id column for real hierarchy)
    SELECT 
        e.employee_id,
        e.first_name,
        e.last_name,
        e.department_id,
        h.level + 1
    FROM employees e
    JOIN hierarchy h ON e.department_id = h.department_id
    WHERE h.level < 3
)
SELECT DISTINCT * FROM hierarchy;

-- ============================================
-- VIEW METADATA
-- ============================================

-- List all views in current database
SELECT 
    table_name,
    view_definition
FROM information_schema.views
WHERE table_schema = 'public';

-- Get view definition
SELECT pg_get_viewdef('employee_details', true);

-- List materialized views
SELECT 
    schemaname,
    matviewname,
    matviewowner
FROM pg_matviews
WHERE schemaname = 'public';

-- ============================================
-- DROP VIEWS
-- ============================================

DROP VIEW IF EXISTS employee_hierarchy;
DROP VIEW IF EXISTS high_performing_employees;
DROP VIEW IF EXISTS engineering_employees;

DROP MATERIALIZED VIEW IF EXISTS department_stats;

-- Drop with cascade (drops dependent objects)
-- DROP VIEW employee_details CASCADE;

-- ============================================
-- VIEW BENEFITS
-- ============================================

/*
1. SECURITY: Hide sensitive columns, restrict access
2. SIMPLIFICATION: Complex queries become simple SELECT *
3. ABSTRACTION: Change underlying tables without affecting queries
4. REUSABILITY: Define once, use many times
5. CONSISTENCY: Same logic applied everywhere

WHEN TO USE VIEWS:
✓ Frequently used complex queries
✓ Security/access control
✓ Simplifying complex joins
✓ Providing different perspectives of data

WHEN TO USE MATERIALIZED VIEWS:
✓ Expensive queries that don't need real-time data
✓ Aggregations over large datasets
✓ Reports that can tolerate staleness
✓ When query performance is critical

REMEMBER:
- Regular views don't store data (no space overhead)
- Materialized views store data (use space, need refresh)
- Views can impact performance if the underlying query is complex
- Use indexes on underlying tables to improve view performance
*/

-- ============================================
-- EXAMPLE: Security with Views
-- ============================================

-- Create a view that hides salary information
CREATE VIEW public_employee_directory AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    d.department_name,
    d.location
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- Grant access to view (but not underlying tables)
-- GRANT SELECT ON public_employee_directory TO public_role;

-- Users can query the view but won't see salary
SELECT * FROM public_employee_directory;

-- Cleanup
-- DROP VIEW IF EXISTS public_employee_directory;
-- DROP VIEW IF EXISTS department_summary;
-- DROP VIEW IF EXISTS employee_details;
