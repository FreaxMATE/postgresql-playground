-- ============================================
-- JOINS
-- ============================================
-- Combining data from multiple tables

-- INNER JOIN - Returns only matching rows from both tables
SELECT 
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;

-- Short form (INNER is optional)
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    d.location
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- LEFT JOIN (LEFT OUTER JOIN) - Returns all rows from left table and matching rows from right
-- NULL for non-matching rows from right table
SELECT 
    d.department_name,
    e.first_name,
    e.last_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id;

-- Find departments with no employees
SELECT 
    d.department_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- RIGHT JOIN (RIGHT OUTER JOIN) - Returns all rows from right table
SELECT 
    e.first_name,
    e.last_name,
    d.department_name
FROM departments d
RIGHT JOIN employees e ON d.department_id = e.department_id;

-- FULL OUTER JOIN - Returns all rows from both tables
-- NULL where there's no match
SELECT 
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
FULL OUTER JOIN departments d ON e.department_id = d.department_id;

-- CROSS JOIN - Cartesian product (every combination)
-- Be careful! This can return huge result sets
SELECT 
    e.first_name,
    p.project_name
FROM employees e
CROSS JOIN projects p
LIMIT 10;

-- Self JOIN - Join a table to itself
-- Find employees who earn more than Alice Johnson
SELECT 
    e1.first_name,
    e1.last_name,
    e1.salary,
    e2.first_name AS reference_employee,
    e2.salary AS reference_salary
FROM employees e1
JOIN employees e2 ON e1.salary > e2.salary
WHERE e2.first_name = 'Alice' AND e2.last_name = 'Johnson';

-- Multiple JOINs
-- Get employee, department, and project information
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    p.project_name,
    ep.role,
    ep.hours_allocated
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN employee_projects ep ON e.employee_id = ep.employee_id
JOIN projects p ON ep.project_id = p.project_id
ORDER BY e.last_name, p.project_name;

-- Join with WHERE clause
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    e.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.salary > 75000 AND d.location = 'San Francisco';

-- Join with aggregation
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS max_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY employee_count DESC;

-- Complex multi-table join
-- Get projects with their department, budget, and number of employees
SELECT 
    p.project_name,
    d.department_name,
    p.budget,
    COUNT(ep.employee_id) AS team_size,
    SUM(ep.hours_allocated) AS total_hours
FROM projects p
JOIN departments d ON p.department_id = d.department_id
LEFT JOIN employee_projects ep ON p.project_id = ep.project_id
GROUP BY p.project_id, p.project_name, d.department_name, p.budget
ORDER BY p.budget DESC;

-- Join with USING clause (when column names are the same)
-- Cleaner syntax when join columns have identical names
SELECT 
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
JOIN departments d USING (department_id);

-- Natural JOIN (automatically joins on columns with same names)
-- Be careful with this - it's implicit and can be error-prone
-- SELECT * FROM employees NATURAL JOIN departments;

-- Get manager information for each department
SELECT 
    d.department_name,
    e.first_name || ' ' || e.last_name AS manager_name,
    e.salary AS manager_salary
FROM departments d
JOIN employees e ON d.manager_id = e.employee_id;
