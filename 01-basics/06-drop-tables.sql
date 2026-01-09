-- ============================================
-- DROP TABLES (Cleanup)
-- ============================================
-- Removing tables from the database

-- Drop tables in reverse order of creation (because of foreign keys)
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

-- IF EXISTS prevents errors if the table doesn't exist

-- Verify tables are gone
\dt
