-- ============================================
-- SETUP: Create tables and sample data
-- ============================================

-- Employees table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    hire_date DATE,
    salary NUMERIC(10, 2),
    department_id INTEGER
);

-- Departments table
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    manager_id INTEGER,
    location VARCHAR(100)
);

-- Projects table
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE,
    budget NUMERIC(12, 2),
    department_id INTEGER
);

-- Employee_Projects (many-to-many relationship)
CREATE TABLE employee_projects (
    employee_id INTEGER REFERENCES employees(employee_id),
    project_id INTEGER REFERENCES projects(project_id),
    role VARCHAR(50),
    hours_allocated INTEGER,
    PRIMARY KEY (employee_id, project_id)
);

-- Insert sample data
INSERT INTO departments (department_name, manager_id, location) VALUES
    ('Engineering', NULL, 'San Francisco'),
    ('Sales', NULL, 'New York'),
    ('Marketing', NULL, 'Los Angeles'),
    ('HR', NULL, 'Chicago'),
    ('Finance', NULL, 'Boston');

INSERT INTO employees (first_name, last_name, email, hire_date, salary, department_id) VALUES
    ('Alice', 'Johnson', 'alice.j@company.com', '2020-01-15', 95000, 1),
    ('Bob', 'Smith', 'bob.s@company.com', '2019-03-20', 85000, 1),
    ('Carol', 'Williams', 'carol.w@company.com', '2021-06-10', 78000, 1),
    ('David', 'Brown', 'david.b@company.com', '2018-09-05', 72000, 2),
    ('Eve', 'Davis', 'eve.d@company.com', '2020-11-12', 68000, 2),
    ('Frank', 'Miller', 'frank.m@company.com', '2022-02-28', 71000, 3),
    ('Grace', 'Wilson', 'grace.w@company.com', '2019-07-18', 65000, 3),
    ('Henry', 'Moore', 'henry.m@company.com', '2021-04-22', 62000, 4),
    ('Ivy', 'Taylor', 'ivy.t@company.com', '2020-08-30', 88000, 5),
    ('Jack', 'Anderson', 'jack.a@company.com', '2023-01-10', 91000, 1);

-- Update manager_id
UPDATE departments SET manager_id = 1 WHERE department_id = 1;
UPDATE departments SET manager_id = 4 WHERE department_id = 2;
UPDATE departments SET manager_id = 6 WHERE department_id = 3;
UPDATE departments SET manager_id = 8 WHERE department_id = 4;
UPDATE departments SET manager_id = 9 WHERE department_id = 5;

INSERT INTO projects (project_name, start_date, end_date, budget, department_id) VALUES
    ('Website Redesign', '2023-01-01', '2023-06-30', 150000, 1),
    ('Mobile App Development', '2023-03-15', '2024-03-15', 300000, 1),
    ('Q1 Sales Campaign', '2023-01-01', '2023-03-31', 50000, 2),
    ('Brand Refresh', '2023-02-01', '2023-08-31', 120000, 3),
    ('HR System Upgrade', '2023-04-01', '2023-12-31', 80000, 4),
    ('Financial Audit', '2023-01-01', '2023-12-31', 60000, 5);

INSERT INTO employee_projects (employee_id, project_id, role, hours_allocated) VALUES
    (1, 1, 'Lead Developer', 160),
    (1, 2, 'Technical Lead', 120),
    (2, 1, 'Developer', 140),
    (2, 2, 'Developer', 160),
    (3, 2, 'Developer', 180),
    (4, 3, 'Sales Manager', 100),
    (5, 3, 'Sales Associate', 80),
    (6, 4, 'Marketing Lead', 150),
    (7, 4, 'Designer', 160),
    (8, 5, 'Project Manager', 120),
    (9, 6, 'Financial Analyst', 140);

-- Display the data
SELECT 'Employees:' AS table_info;
SELECT * FROM employees LIMIT 5;

SELECT 'Departments:' AS table_info;
SELECT * FROM departments;

SELECT 'Projects:' AS table_info;
SELECT * FROM projects;
