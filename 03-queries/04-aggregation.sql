-- ============================================
-- AGGREGATION AND GROUP BY
-- ============================================

-- COUNT - Number of rows
SELECT COUNT(*) AS total_employees FROM employees;

-- COUNT with DISTINCT
SELECT COUNT(DISTINCT department_id) AS departments_with_employees
FROM employees;

-- AVG - Average
SELECT AVG(salary) AS average_salary FROM employees;

-- SUM - Total
SELECT SUM(salary) AS total_payroll FROM employees;

-- MIN and MAX
SELECT 
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary
FROM employees;

-- Multiple aggregates
SELECT 
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    SUM(salary) AS total_salary
FROM employees;

-- GROUP BY - Aggregate by groups
SELECT 
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
ORDER BY department_id;

-- GROUP BY with multiple aggregates
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    SUM(salary) AS dept_payroll
FROM employees
GROUP BY department_id
ORDER BY avg_salary DESC;

-- GROUP BY with JOIN
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(e.salary), 2) AS avg_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY employee_count DESC;

-- HAVING clause - Filter groups (use after GROUP BY)
-- WHERE filters rows before grouping, HAVING filters groups after grouping
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
HAVING COUNT(*) >= 3;

-- HAVING with multiple conditions
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
HAVING COUNT(*) >= 2 AND AVG(salary) > 70000;

-- WHERE and HAVING together
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary
FROM employees
WHERE hire_date >= '2019-01-01'  -- Filter rows before grouping
GROUP BY department_id
HAVING AVG(salary) > 70000       -- Filter groups after aggregation
ORDER BY avg_salary DESC;

-- GROUP BY multiple columns
SELECT 
    EXTRACT(YEAR FROM hire_date) AS hire_year,
    department_id,
    COUNT(*) AS employees_hired
FROM employees
GROUP BY hire_year, department_id
ORDER BY hire_year, department_id;

-- GROUP BY with date functions
SELECT 
    EXTRACT(YEAR FROM hire_date) AS year,
    COUNT(*) AS hires
FROM employees
GROUP BY year
ORDER BY year;

SELECT 
    DATE_TRUNC('month', hire_date) AS hire_month,
    COUNT(*) AS employees_hired
FROM employees
GROUP BY hire_month
ORDER BY hire_month;

-- String aggregation (GROUP_CONCAT equivalent)
SELECT 
    d.department_name,
    STRING_AGG(e.first_name || ' ' || e.last_name, ', ') AS employees
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;

-- Statistical aggregates
SELECT 
    department_id,
    STDDEV(salary) AS salary_std_dev,
    VARIANCE(salary) AS salary_variance
FROM employees
GROUP BY department_id;

-- Project statistics
SELECT 
    p.project_name,
    COUNT(ep.employee_id) AS team_size,
    SUM(ep.hours_allocated) AS total_hours,
    AVG(ep.hours_allocated) AS avg_hours_per_person
FROM projects p
LEFT JOIN employee_projects ep ON p.project_id = ep.project_id
GROUP BY p.project_id, p.project_name
ORDER BY total_hours DESC;

-- Complex aggregation with multiple tables
SELECT 
    d.department_name,
    COUNT(DISTINCT e.employee_id) AS total_employees,
    COUNT(DISTINCT p.project_id) AS total_projects,
    COALESCE(SUM(p.budget), 0) AS total_budget,
    ROUND(AVG(e.salary), 2) AS avg_employee_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
LEFT JOIN projects p ON d.department_id = p.department_id
GROUP BY d.department_name
ORDER BY total_budget DESC;

-- FILTER clause (PostgreSQL-specific) - Conditional aggregation
SELECT 
    department_id,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE salary > 80000) AS high_earners,
    COUNT(*) FILTER (WHERE hire_date >= '2020-01-01') AS recent_hires
FROM employees
GROUP BY department_id;
