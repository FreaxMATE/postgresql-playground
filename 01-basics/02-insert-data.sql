-- ============================================
-- INSERT DATA
-- ============================================
-- Adding records to your tables

-- Insert a single student
INSERT INTO students (first_name, last_name, email, birth_date)
VALUES ('John', 'Doe', 'john.doe@university.edu', '2000-05-15');

-- Insert multiple students at once
INSERT INTO students (first_name, last_name, email, birth_date) VALUES
    ('Jane', 'Smith', 'jane.smith@university.edu', '1999-08-22'),
    ('Michael', 'Johnson', 'michael.j@university.edu', '2001-03-10'),
    ('Emily', 'Brown', 'emily.brown@university.edu', '2000-11-30'),
    ('David', 'Wilson', 'david.wilson@university.edu', '1999-12-05');

-- Insert with some optional fields omitted (will use defaults or NULL)
INSERT INTO students (first_name, last_name, email)
VALUES ('Sarah', 'Davis', 'sarah.davis@university.edu');

-- Insert courses
INSERT INTO courses (course_name, course_code, credits, department) VALUES
    ('Introduction to Computer Science', 'CS101', 3, 'Computer Science'),
    ('Data Structures and Algorithms', 'CS201', 4, 'Computer Science'),
    ('Database Systems', 'CS301', 3, 'Computer Science'),
    ('Calculus I', 'MATH101', 4, 'Mathematics'),
    ('Linear Algebra', 'MATH201', 3, 'Mathematics'),
    ('English Literature', 'ENG101', 3, 'English');

-- Insert enrollments (connecting students to courses)
-- Student 1 enrolls in courses 1, 2, and 4
INSERT INTO enrollments (student_id, course_id, grade) VALUES
    (1, 1, 'A'),
    (1, 2, 'B+'),
    (1, 4, 'A-');

-- Multiple students enrolling in various courses
INSERT INTO enrollments (student_id, course_id, grade) VALUES
    (2, 1, 'A-'),
    (2, 3, 'B'),
    (2, 5, 'A'),
    (3, 2, 'B+'),
    (3, 4, 'B'),
    (3, 6, 'A'),
    (4, 1, 'A'),
    (4, 3, 'A-'),
    (5, 2, 'B'),
    (5, 5, 'A+');

-- Insert and return the new record (useful to see what was inserted)
INSERT INTO students (first_name, last_name, email, birth_date)
VALUES ('Alex', 'Martinez', 'alex.m@university.edu', '2000-07-20')
RETURNING *;

-- Verify data was inserted
SELECT COUNT(*) AS total_students FROM students;
SELECT COUNT(*) AS total_courses FROM courses;
SELECT COUNT(*) AS total_enrollments FROM enrollments;
