-- ============================================
-- ADVANCED QUERIES
-- ============================================
-- Set operations, window functions, and more

-- UNION - Combine results from multiple queries (removes duplicates)
SELECT first_name, last_name, 'Employee' AS type
FROM employees
WHERE department_id = 1
UNION
SELECT first_name, last_name, 'Manager' AS type
FROM employees
WHERE employee_id IN (SELECT manager_id FROM departments);

-- UNION ALL - Like UNION but keeps duplicates (faster)
SELECT first_name FROM employees WHERE department_id = 1
UNION ALL
SELECT first_name FROM employees WHERE department_id = 2;

-- INTERSECT - Returns only rows that appear in both queries
SELECT first_name FROM employees WHERE salary > 75000
INTERSECT
SELECT first_name FROM employees WHERE department_id IN (1, 2);

-- EXCEPT - Returns rows from first query that aren't in second query
SELECT first_name, last_name FROM employees
EXCEPT
SELECT first_name, last_name FROM employees WHERE department_id = 3;

-- ============================================
-- WINDOW FUNCTIONS
-- ============================================
-- Perform calculations across a set of rows related to current row

-- ROW_NUMBER - Assign a unique number to each row
SELECT 
    first_name,
    last_name,
    salary,
    department_id,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

-- ROW_NUMBER with PARTITION BY (separate ranking per group)
SELECT 
    first_name,
    last_name,
    salary,
    department_id,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_rank
FROM employees
ORDER BY department_id, dept_rank;

-- RANK - Like ROW_NUMBER but gives same rank for ties
SELECT 
    first_name,
    last_name,
    salary,
    RANK() OVER (ORDER BY salary DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank
FROM employees;

-- NTILE - Divide rows into N buckets
SELECT 
    first_name,
    last_name,
    salary,
    NTILE(4) OVER (ORDER BY salary DESC) AS salary_quartile
FROM employees;

-- LAG - Access previous row's value
SELECT 
    first_name,
    last_name,
    salary,
    LAG(salary) OVER (ORDER BY salary) AS previous_salary,
    salary - LAG(salary) OVER (ORDER BY salary) AS salary_diff
FROM employees;

-- LEAD - Access next row's value
SELECT 
    first_name,
    last_name,
    hire_date,
    LEAD(hire_date) OVER (ORDER BY hire_date) AS next_hire_date
FROM employees;

-- Aggregate window functions
SELECT 
    first_name,
    last_name,
    salary,
    department_id,
    AVG(salary) OVER (PARTITION BY department_id) AS dept_avg_salary,
    salary - AVG(salary) OVER (PARTITION BY department_id) AS diff_from_avg
FROM employees;

-- Running total (cumulative sum)
SELECT 
    first_name,
    last_name,
    salary,
    SUM(salary) OVER (ORDER BY employee_id) AS running_total
FROM employees;

-- Moving average (last 3 rows)
SELECT 
    first_name,
    last_name,
    salary,
    AVG(salary) OVER (
        ORDER BY employee_id 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3
FROM employees;

-- FIRST_VALUE and LAST_VALUE
SELECT 
    first_name,
    last_name,
    salary,
    department_id,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department_id 
        ORDER BY salary DESC
    ) AS highest_dept_salary,
    LAST_VALUE(salary) OVER (
        PARTITION BY department_id 
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_dept_salary
FROM employees;

-- CASE expressions
SELECT 
    first_name,
    last_name,
    salary,
    CASE 
        WHEN salary > 85000 THEN 'High'
        WHEN salary > 70000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM employees;

-- CASE with aggregation
SELECT 
    department_id,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN salary > 80000 THEN 1 END) AS high_earners,
    COUNT(CASE WHEN salary BETWEEN 70000 AND 80000 THEN 1 END) AS mid_earners,
    COUNT(CASE WHEN salary < 70000 THEN 1 END) AS low_earners
FROM employees
GROUP BY department_id;

-- COALESCE - Return first non-null value
SELECT 
    first_name,
    last_name,
    COALESCE(email, 'No email provided') AS email_display
FROM employees;

-- NULLIF - Return NULL if two values are equal
SELECT 
    first_name,
    last_name,
    NULLIF(department_id, 3) AS dept_id_except_3
FROM employees;

-- Complex query combining multiple techniques
WITH employee_rankings AS (
    SELECT 
        e.employee_id,
        e.first_name,
        e.last_name,
        e.salary,
        d.department_name,
        ROW_NUMBER() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS dept_rank,
        PERCENT_RANK() OVER (ORDER BY e.salary) AS salary_percentile,
        COUNT(*) OVER (PARTITION BY e.department_id) AS dept_size
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
)
SELECT 
    first_name,
    last_name,
    salary,
    department_name,
    dept_rank,
    ROUND(salary_percentile::numeric, 2) AS percentile,
    dept_size,
    CASE 
        WHEN dept_rank = 1 THEN 'Top earner'
        WHEN dept_rank = 2 THEN 'Second highest'
        ELSE 'Other'
    END AS position_description
FROM employee_rankings
WHERE dept_rank <= 3
ORDER BY department_name, dept_rank;

-- Pivot-like query (transform rows to columns)
SELECT 
    d.department_name,
    SUM(CASE WHEN EXTRACT(YEAR FROM e.hire_date) = 2019 THEN 1 ELSE 0 END) AS hires_2019,
    SUM(CASE WHEN EXTRACT(YEAR FROM e.hire_date) = 2020 THEN 1 ELSE 0 END) AS hires_2020,
    SUM(CASE WHEN EXTRACT(YEAR FROM e.hire_date) = 2021 THEN 1 ELSE 0 END) AS hires_2021,
    SUM(CASE WHEN EXTRACT(YEAR FROM e.hire_date) >= 2022 THEN 1 ELSE 0 END) AS hires_2022_plus
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;
