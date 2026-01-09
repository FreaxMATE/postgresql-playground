-- ============================================
-- FILTERING DATA
-- ============================================

-- Basic WHERE clause
SELECT first_name, last_name, salary
FROM employees
WHERE salary > 80000;

-- Multiple conditions with AND
SELECT first_name, last_name, salary, hire_date
FROM employees
WHERE salary > 70000 AND department_id = 1;

-- Multiple conditions with OR
SELECT first_name, last_name, department_id
FROM employees
WHERE department_id = 1 OR department_id = 2;

-- Combining AND and OR (use parentheses!)
SELECT first_name, last_name, salary, department_id
FROM employees
WHERE (department_id = 1 OR department_id = 2) AND salary > 80000;

-- IN operator (matches any value in a list)
SELECT first_name, last_name, department_id
FROM employees
WHERE department_id IN (1, 3, 5);

-- NOT IN operator
SELECT first_name, last_name, department_id
FROM employees
WHERE department_id NOT IN (1, 2);

-- BETWEEN operator (inclusive range)
SELECT first_name, last_name, salary
FROM employees
WHERE salary BETWEEN 70000 AND 85000;

-- Date range with BETWEEN
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date BETWEEN '2020-01-01' AND '2021-12-31';

-- LIKE operator (pattern matching)
-- % matches any sequence of characters
-- _ matches any single character
SELECT first_name, last_name, email
FROM employees
WHERE email LIKE '%@company.com';

SELECT first_name, last_name
FROM employees
WHERE first_name LIKE 'A%';  -- Starts with A

SELECT first_name, last_name
FROM employees
WHERE first_name LIKE '%e';  -- Ends with e

SELECT first_name, last_name
FROM employees
WHERE first_name LIKE '%a%';  -- Contains a

-- ILIKE operator (case-insensitive LIKE)
SELECT first_name, last_name
FROM employees
WHERE first_name ILIKE 'alice';

-- NOT LIKE operator
SELECT first_name, last_name, email
FROM employees
WHERE email NOT LIKE '%@company.com';

-- IS NULL / IS NOT NULL
SELECT first_name, last_name, salary
FROM employees
WHERE salary IS NOT NULL;

-- Comparison operators
SELECT project_name, budget
FROM projects
WHERE budget > 100000;  -- Greater than

SELECT project_name, budget
FROM projects
WHERE budget <= 100000;  -- Less than or equal to

SELECT project_name, budget
FROM projects
WHERE budget != 150000;  -- Not equal to (can also use <>)

-- Date comparisons
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date < '2020-01-01';

-- String comparison
SELECT first_name, last_name
FROM employees
WHERE last_name > 'M'  -- Alphabetically after M
ORDER BY last_name;

-- Combining multiple filters
SELECT 
    first_name, 
    last_name, 
    salary, 
    hire_date,
    department_id
FROM employees
WHERE salary BETWEEN 65000 AND 90000
    AND hire_date >= '2019-01-01'
    AND department_id IN (1, 2, 3)
    AND first_name LIKE '%a%'
ORDER BY salary DESC;
