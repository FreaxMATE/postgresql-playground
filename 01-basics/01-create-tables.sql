-- ============================================
-- CREATE TABLES
-- ============================================
-- Creating tables is the first step in building a database.
-- Tables define the structure and types of data you'll store.

-- Create a simple students table
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,  -- SERIAL auto-increments, PRIMARY KEY ensures uniqueness
    first_name VARCHAR(50) NOT NULL, -- VARCHAR for variable-length text, NOT NULL means required
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,       -- UNIQUE ensures no duplicate emails
    birth_date DATE,
    enrollment_date DATE DEFAULT CURRENT_DATE -- DEFAULT sets a value if none provided
);

-- Create a courses table
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    course_code VARCHAR(10) UNIQUE NOT NULL,
    credits INTEGER CHECK (credits > 0), -- CHECK constraint ensures credits is positive
    department VARCHAR(50)
);

-- Create an enrollments table (links students and courses)
CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(student_id), -- FOREIGN KEY reference
    course_id INTEGER REFERENCES courses(course_id),
    grade VARCHAR(2),
    enrollment_date DATE DEFAULT CURRENT_DATE,
    UNIQUE(student_id, course_id) -- A student can't enroll in the same course twice
);

-- View the tables we created
\dt

-- Describe the structure of a specific table
\d students
