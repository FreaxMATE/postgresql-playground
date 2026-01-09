-- ============================================
-- UPDATE DATA
-- ============================================
-- Modifying existing records

-- WARNING: Always use WHERE clause with UPDATE!
-- Without WHERE, ALL records will be updated!

-- Update a single field for a specific student
UPDATE students
SET email = 'john.doe.new@university.edu'
WHERE student_id = 1;

-- Update multiple fields at once
UPDATE students
SET first_name = 'Jonathan',
    last_name = 'Doe-Smith'
WHERE student_id = 1;

-- Update based on a condition
UPDATE enrollments
SET grade = 'A+'
WHERE student_id = 2 AND course_id = 1;

-- Update multiple records
UPDATE courses
SET credits = 4
WHERE department = 'Computer Science' AND credits = 3;

-- Update with calculation
UPDATE courses
SET credits = credits + 1
WHERE course_code = 'CS101';

-- Update using a subquery (advanced)
UPDATE students
SET enrollment_date = CURRENT_DATE
WHERE student_id IN (
    SELECT student_id FROM enrollments WHERE grade = 'A+'
);

-- Update and return the modified records
UPDATE enrollments
SET grade = 'A'
WHERE enrollment_id = 1
RETURNING *;

-- View the updated data
SELECT * FROM students WHERE student_id = 1;
SELECT * FROM enrollments WHERE student_id = 2;
