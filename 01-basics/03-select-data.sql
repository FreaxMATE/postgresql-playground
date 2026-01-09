-- ============================================
-- SELECT DATA
-- ============================================
-- Retrieving data from your tables

-- Select all columns from students
SELECT * FROM students;

-- Select specific columns
SELECT first_name, last_name, email FROM students;

-- Select with a condition (WHERE clause)
SELECT * FROM students WHERE birth_date < '2000-01-01';

-- Select with multiple conditions (AND, OR)
SELECT * FROM students 
WHERE birth_date >= '2000-01-01' AND email LIKE '%@university.edu';

-- Select with LIMIT (get only first 3 records)
SELECT * FROM students LIMIT 3;

-- Select with ORDER BY (sort results)
SELECT first_name, last_name, birth_date 
FROM students 
ORDER BY birth_date ASC; -- ASC = ascending, DESC = descending

-- Select distinct values (no duplicates)
SELECT DISTINCT department FROM courses;

-- Select with aggregation functions
SELECT COUNT(*) AS total_students FROM students;
SELECT AVG(credits) AS average_credits FROM courses;
SELECT MAX(credits) AS max_credits, MIN(credits) AS min_credits FROM courses;

-- Select with GROUP BY (aggregate per group)
SELECT department, COUNT(*) AS course_count, AVG(credits) AS avg_credits
FROM courses
GROUP BY department;

-- Select with HAVING (filter groups after aggregation)
SELECT department, COUNT(*) AS course_count
FROM courses
GROUP BY department
HAVING COUNT(*) >= 2;

-- Select with LIKE (pattern matching)
-- % matches any sequence of characters
-- _ matches any single character
SELECT * FROM students WHERE email LIKE 'john%';
SELECT * FROM students WHERE first_name LIKE 'J%';

-- Select with IN (match any value in a list)
SELECT * FROM courses WHERE department IN ('Computer Science', 'Mathematics');

-- Select with BETWEEN (range query)
SELECT * FROM students WHERE birth_date BETWEEN '1999-01-01' AND '2000-12-31';

-- Select with IS NULL / IS NOT NULL
SELECT * FROM students WHERE birth_date IS NULL;
SELECT * FROM students WHERE birth_date IS NOT NULL;

-- Alias columns and tables (AS keyword)
SELECT 
    first_name AS "First Name",
    last_name AS "Last Name",
    email AS "Email Address"
FROM students AS s;

-- Concatenate strings
SELECT first_name || ' ' || last_name AS full_name, email
FROM students;

-- Mathematical operations
SELECT course_name, credits, credits * 15 AS study_hours_per_week
FROM courses;
