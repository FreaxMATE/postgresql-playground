-- ============================================
-- DELETE DATA
-- ============================================
-- Removing records from tables

-- WARNING: Always use WHERE clause with DELETE!
-- Without WHERE, ALL records will be deleted!

-- Delete a specific student
DELETE FROM students WHERE student_id = 7;

-- Delete based on a condition
DELETE FROM enrollments WHERE grade = 'F';

-- Delete multiple records
DELETE FROM enrollments 
WHERE student_id = 5 AND course_id IN (2, 5);

-- Delete with subquery
DELETE FROM enrollments
WHERE course_id IN (
    SELECT course_id FROM courses WHERE department = 'Physics'
);

-- Delete and return the deleted records
DELETE FROM enrollments
WHERE enrollment_id = 10
RETURNING *;

-- TRUNCATE - removes all records from a table (faster than DELETE)
-- Be very careful with this!
-- TRUNCATE enrollments; -- Uncomment to use

-- DROP TABLE - completely removes a table and all its data
-- DROP TABLE table_name; -- Uncomment to use

-- To delete with foreign key constraints, delete in correct order:
-- 1. Delete from child tables first (enrollments)
-- 2. Then delete from parent tables (students, courses)

-- Example: Delete a student and all their enrollments
BEGIN; -- Start a transaction
DELETE FROM enrollments WHERE student_id = 3;
DELETE FROM students WHERE student_id = 3;
COMMIT; -- Confirm the changes

-- View remaining data
SELECT COUNT(*) AS remaining_students FROM students;
SELECT COUNT(*) AS remaining_enrollments FROM enrollments;
