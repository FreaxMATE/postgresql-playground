-- ============================================
-- BEGINNER EXERCISES
-- ============================================

-- Setup: Create a library database
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    published_year INTEGER,
    genre VARCHAR(50),
    price NUMERIC(6, 2),
    copies_available INTEGER DEFAULT 0
);

CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    join_date DATE DEFAULT CURRENT_DATE,
    membership_type VARCHAR(20)
);

CREATE TABLE borrowings (
    borrowing_id SERIAL PRIMARY KEY,
    book_id INTEGER REFERENCES books(book_id),
    member_id INTEGER REFERENCES members(member_id),
    borrow_date DATE DEFAULT CURRENT_DATE,
    return_date DATE,
    returned BOOLEAN DEFAULT FALSE
);

-- Insert sample data
INSERT INTO books (title, author, published_year, genre, price, copies_available) VALUES
    ('To Kill a Mockingbird', 'Harper Lee', 1960, 'Fiction', 12.99, 5),
    ('1984', 'George Orwell', 1949, 'Fiction', 14.99, 3),
    ('The Great Gatsby', 'F. Scott Fitzgerald', 1925, 'Fiction', 10.99, 4),
    ('Pride and Prejudice', 'Jane Austen', 1813, 'Romance', 9.99, 6),
    ('The Catcher in the Rye', 'J.D. Salinger', 1951, 'Fiction', 11.99, 2),
    ('Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', 1997, 'Fantasy', 15.99, 8),
    ('The Hobbit', 'J.R.R. Tolkien', 1937, 'Fantasy', 13.99, 5),
    ('Sapiens', 'Yuval Noah Harari', 2011, 'Non-Fiction', 18.99, 7),
    ('Educated', 'Tara Westover', 2018, 'Biography', 16.99, 4),
    ('Atomic Habits', 'James Clear', 2018, 'Self-Help', 17.99, 6);

INSERT INTO members (first_name, last_name, email, membership_type) VALUES
    ('John', 'Doe', 'john.doe@email.com', 'Premium'),
    ('Jane', 'Smith', 'jane.smith@email.com', 'Standard'),
    ('Michael', 'Johnson', 'michael.j@email.com', 'Premium'),
    ('Emily', 'Brown', 'emily.brown@email.com', 'Standard'),
    ('David', 'Wilson', 'david.wilson@email.com', 'Standard');

INSERT INTO borrowings (book_id, member_id, borrow_date, return_date, returned) VALUES
    (1, 1, '2024-01-05', '2024-01-20', TRUE),
    (2, 1, '2024-01-15', NULL, FALSE),
    (3, 2, '2024-01-10', '2024-01-25', TRUE),
    (6, 3, '2024-01-20', NULL, FALSE),
    (8, 4, '2024-01-12', '2024-01-28', TRUE),
    (10, 5, '2024-01-18', NULL, FALSE);

-- ============================================
-- EXERCISE 1: Basic SELECT
-- ============================================
-- Task: Retrieve all books published after 2000

-- Hint: Use WHERE clause with published_year

-- Your solution here:


-- Solution:
-- SELECT * FROM books WHERE published_year > 2000;

-- ============================================
-- EXERCISE 2: Filtering with AND/OR
-- ============================================
-- Task: Find all Fiction books priced under $15

-- Hint: Use WHERE with AND to combine conditions

-- Your solution here:


-- Solution:
-- SELECT title, author, price
-- FROM books
-- WHERE genre = 'Fiction' AND price < 15;

-- ============================================
-- EXERCISE 3: Sorting
-- ============================================
-- Task: List all books ordered by price (highest to lowest)

-- Hint: Use ORDER BY with DESC

-- Your solution here:


-- Solution:
-- SELECT title, author, price
-- FROM books
-- ORDER BY price DESC;

-- ============================================
-- EXERCISE 4: Counting
-- ============================================
-- Task: Count how many books are in each genre

-- Hint: Use COUNT() and GROUP BY

-- Your solution here:


-- Solution:
-- SELECT genre, COUNT(*) AS book_count
-- FROM books
-- GROUP BY genre
-- ORDER BY book_count DESC;

-- ============================================
-- EXERCISE 5: Basic UPDATE
-- ============================================
-- Task: Increase the price of all Fantasy books by 10%

-- Hint: Use UPDATE with SET and WHERE

-- Your solution here:


-- Solution:
-- UPDATE books
-- SET price = price * 1.10
-- WHERE genre = 'Fantasy';

-- ============================================
-- EXERCISE 6: Simple JOIN
-- ============================================
-- Task: Show all borrowings with member names and book titles

-- Hint: JOIN borrowings with members and books

-- Your solution here:


-- Solution:
-- SELECT 
--     m.first_name || ' ' || m.last_name AS member_name,
--     b.title AS book_title,
--     br.borrow_date
-- FROM borrowings br
-- JOIN members m ON br.member_id = m.member_id
-- JOIN books b ON br.book_id = b.book_id;

-- ============================================
-- EXERCISE 7: INSERT
-- ============================================
-- Task: Add a new book to the library

-- Hint: Use INSERT INTO with VALUES

-- Your solution here:


-- Solution:
-- INSERT INTO books (title, author, published_year, genre, price, copies_available)
-- VALUES ('The Midnight Library', 'Matt Haig', 2020, 'Fiction', 14.99, 5);

-- ============================================
-- EXERCISE 8: DELETE
-- ============================================
-- Task: Remove all books with 0 copies available

-- Hint: Use DELETE with WHERE

-- Your solution here:


-- Solution:
-- DELETE FROM books WHERE copies_available = 0;

-- ============================================
-- EXERCISE 9: Aggregation
-- ============================================
-- Task: Calculate the average price of books by genre

-- Hint: Use AVG() with GROUP BY

-- Your solution here:


-- Solution:
-- SELECT genre, ROUND(AVG(price), 2) AS average_price
-- FROM books
-- GROUP BY genre
-- ORDER BY average_price DESC;

-- ============================================
-- EXERCISE 10: Pattern Matching
-- ============================================
-- Task: Find all members whose email ends with '@email.com'

-- Hint: Use LIKE with % wildcard

-- Your solution here:


-- Solution:
-- SELECT first_name, last_name, email
-- FROM members
-- WHERE email LIKE '%@email.com';
