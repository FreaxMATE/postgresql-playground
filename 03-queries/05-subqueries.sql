-- ============================================
-- SUBQUERIES
-- ============================================
-- Queries nested within other queries

-- Subquery in WHERE clause
-- Find employees who earn more than the average salary
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Subquery with IN
-- Find employees in departments located in San Francisco
SELECT first_name, last_name
FROM employees
WHERE department_id IN (
    SELECT department_id 
    FROM departments 
    WHERE location = 'San Francisco'
);

-- Subquery with NOT IN
-- Find employees not working on any project
SELECT first_name, last_name
FROM employees
WHERE employee_id NOT IN (
    SELECT DISTINCT employee_id 
    FROM employee_projects
);

-- Correlated subquery
-- For each employee, show their salary and department's average salary
SELECT 
    first_name,
    last_name,
    salary,
    department_id,
    (SELECT AVG(salary) 
     FROM employees e2 
     WHERE e2.department_id = e1.department_id) AS dept_avg_salary
FROM employees e1;

-- EXISTS operator
-- Find departments that have at least one project
SELECT department_name
FROM departments d
WHERE EXISTS (
    SELECT 1 
    FROM projects p 
    WHERE p.department_id = d.department_id
);

-- NOT EXISTS operator
-- Find departments with no projects
SELECT department_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 
    FROM projects p 
    WHERE p.department_id = d.department_id
);

-- Subquery in FROM clause (derived table)
-- Find departments where average salary is above overall average
SELECT 
    dept_stats.department_id,
    dept_stats.avg_salary,
    overall.company_avg
FROM (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) AS dept_stats
CROSS JOIN (
    SELECT AVG(salary) AS company_avg
    FROM employees
) AS overall
WHERE dept_stats.avg_salary > overall.company_avg;

-- Subquery with ALL
-- Find employees who earn more than ALL employees in department 3
SELECT first_name, last_name, salary
FROM employees
WHERE salary > ALL (
    SELECT salary 
    FROM employees 
    WHERE department_id = 3
);

-- Subquery with ANY (or SOME)
-- Find employees who earn more than ANY employee in department 4
SELECT first_name, last_name, salary, department_id
FROM employees
WHERE salary > ANY (
    SELECT salary 
    FROM employees 
    WHERE department_id = 4
)
AND department_id != 4;

-- Multiple levels of subqueries
-- Find employees in the highest-paid department
SELECT first_name, last_name, salary, department_id
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM employees
    GROUP BY department_id
    ORDER BY AVG(salary) DESC
    LIMIT 1
);

-- Subquery in SELECT (scalar subquery)
SELECT 
    e.first_name,
    e.last_name,
    e.salary,
    (SELECT AVG(salary) FROM employees) AS company_avg,
    e.salary - (SELECT AVG(salary) FROM employees) AS difference_from_avg
FROM employees e;

-- WITH clause (Common Table Expression - CTE)
-- More readable alternative to subqueries
WITH dept_averages AS (
    SELECT 
        department_id,
        AVG(salary) AS avg_salary,
        COUNT(*) AS employee_count
    FROM employees
    GROUP BY department_id
)
SELECT 
    d.department_name,
    da.avg_salary,
    da.employee_count
FROM dept_averages da
JOIN departments d ON da.department_id = d.department_id
WHERE da.avg_salary > 70000
ORDER BY da.avg_salary DESC;

-- Multiple CTEs
WITH 
dept_stats AS (
    SELECT 
        department_id,
        AVG(salary) AS avg_salary,
        COUNT(*) AS emp_count
    FROM employees
    GROUP BY department_id
),
project_stats AS (
    SELECT 
        department_id,
        COUNT(*) AS project_count,
        SUM(budget) AS total_budget
    FROM projects
    GROUP BY department_id
)
SELECT 
    d.department_name,
    COALESCE(ds.emp_count, 0) AS employees,
    ROUND(COALESCE(ds.avg_salary, 0), 2) AS avg_salary,
    COALESCE(ps.project_count, 0) AS projects,
    COALESCE(ps.total_budget, 0) AS budget
FROM departments d
LEFT JOIN dept_stats ds ON d.department_id = ds.department_id
LEFT JOIN project_stats ps ON d.department_id = ps.department_id
ORDER BY d.department_name;

-- Recursive CTE (for hierarchical data)
-- Note: Our current schema doesn't have hierarchy, but here's an example structure
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: Top-level managers
    SELECT 
        employee_id,
        first_name,
        last_name,
        department_id,
        1 AS level
    FROM employees
    WHERE employee_id IN (SELECT manager_id FROM departments)
    
    UNION ALL
    
    -- Recursive case would go here if we had a manager_id in employees table
    SELECT 
        e.employee_id,
        e.first_name,
        e.last_name,
        e.department_id,
        1 AS level
    FROM employees e
    WHERE false  -- Placeholder since we don't have hierarchy
)
SELECT * FROM employee_hierarchy;

-- Lateral join (advanced)
-- For each department, get top 2 highest-paid employees
SELECT 
    d.department_name,
    top_earners.first_name,
    top_earners.last_name,
    top_earners.salary
FROM departments d
CROSS JOIN LATERAL (
    SELECT first_name, last_name, salary
    FROM employees e
    WHERE e.department_id = d.department_id
    ORDER BY salary DESC
    LIMIT 2
) AS top_earners
ORDER BY d.department_name, top_earners.salary DESC;
