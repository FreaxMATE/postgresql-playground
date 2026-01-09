-- ============================================
-- INTERMEDIATE EXERCISES
-- ============================================

-- Note: Run the beginner exercises setup first, or use this setup

-- Ensure tables exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'books') THEN
        CREATE TABLE books (
            book_id SERIAL PRIMARY KEY,
            title VARCHAR(200) NOT NULL,
            author VARCHAR(100) NOT NULL,
            published_year INTEGER,
            genre VARCHAR(50),
            price NUMERIC(6, 2),
            copies_available INTEGER DEFAULT 0
        );
        
        INSERT INTO books (title, author, published_year, genre, price, copies_available) VALUES
            ('To Kill a Mockingbird', 'Harper Lee', 1960, 'Fiction', 12.99, 5),
            ('1984', 'George Orwell', 1949, 'Fiction', 14.99, 3),
            ('The Great Gatsby', 'F. Scott Fitzgerald', 1925, 'Fiction', 10.99, 4),
            ('Pride and Prejudice', 'Jane Austen', 1813, 'Romance', 9.99, 6),
            ('Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', 1997, 'Fantasy', 15.99, 8),
            ('The Hobbit', 'J.R.R. Tolkien', 1937, 'Fantasy', 13.99, 5),
            ('Sapiens', 'Yuval Noah Harari', 2011, 'Non-Fiction', 18.99, 7);
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'members') THEN
        CREATE TABLE members (
            member_id SERIAL PRIMARY KEY,
            first_name VARCHAR(50) NOT NULL,
            last_name VARCHAR(50) NOT NULL,
            email VARCHAR(100) UNIQUE,
            join_date DATE DEFAULT CURRENT_DATE,
            membership_type VARCHAR(20)
        );
        
        INSERT INTO members (first_name, last_name, email, membership_type) VALUES
            ('John', 'Doe', 'john.doe@email.com', 'Premium'),
            ('Jane', 'Smith', 'jane.smith@email.com', 'Standard'),
            ('Michael', 'Johnson', 'michael.j@email.com', 'Premium');
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'borrowings') THEN
        CREATE TABLE borrowings (
            borrowing_id SERIAL PRIMARY KEY,
            book_id INTEGER REFERENCES books(book_id),
            member_id INTEGER REFERENCES members(member_id),
            borrow_date DATE DEFAULT CURRENT_DATE,
            return_date DATE,
            returned BOOLEAN DEFAULT FALSE
        );
        
        INSERT INTO borrowings (book_id, member_id, borrow_date, return_date, returned) VALUES
            (1, 1, '2024-01-05', '2024-01-20', TRUE),
            (2, 1, '2024-01-15', NULL, FALSE),
            (3, 2, '2024-01-10', '2024-01-25', TRUE);
    END IF;
END $$;

-- ============================================
-- EXERCISE 1: LEFT JOIN with NULL check
-- ============================================
-- Task: Find all members who have never borrowed a book

-- Hint: Use LEFT JOIN and check for NULL

-- Your solution here:


-- Solution:
-- SELECT m.first_name, m.last_name, m.email
-- FROM members m
-- LEFT JOIN borrowings b ON m.member_id = b.member_id
-- WHERE b.borrowing_id IS NULL;

-- ============================================
-- EXERCISE 2: Subquery
-- ============================================
-- Task: Find books that cost more than the average book price

-- Hint: Use a subquery with AVG() in WHERE clause

-- Your solution here:


-- Solution:
-- SELECT title, author, price
-- FROM books
-- WHERE price > (SELECT AVG(price) FROM books)
-- ORDER BY price DESC;

-- ============================================
-- EXERCISE 3: GROUP BY with HAVING
-- ============================================
-- Task: Find genres that have more than 2 books

-- Hint: Use GROUP BY with HAVING and COUNT()

-- Your solution here:


-- Solution:
-- SELECT genre, COUNT(*) AS book_count
-- FROM books
-- GROUP BY genre
-- HAVING COUNT(*) > 2;

-- ============================================
-- EXERCISE 4: Complex JOIN
-- ============================================
-- Task: Show all unreturned books with member names and how many days they've been borrowed

-- Hint: JOIN three tables, filter by returned = FALSE, calculate date difference

-- Your solution here:


-- Solution:
-- SELECT 
--     m.first_name || ' ' || m.last_name AS member_name,
--     b.title,
--     br.borrow_date,
--     CURRENT_DATE - br.borrow_date AS days_borrowed
-- FROM borrowings br
-- JOIN members m ON br.member_id = m.member_id
-- JOIN books b ON br.book_id = b.book_id
-- WHERE br.returned = FALSE
-- ORDER BY days_borrowed DESC;

-- ============================================
-- EXERCISE 5: Aggregation with JOIN
-- ============================================
-- Task: Count how many books each member has borrowed (including members who borrowed 0)

-- Hint: Use LEFT JOIN with GROUP BY

-- Your solution here:


-- Solution:
-- SELECT 
--     m.first_name || ' ' || m.last_name AS member_name,
--     COUNT(br.borrowing_id) AS books_borrowed
-- FROM members m
-- LEFT JOIN borrowings br ON m.member_id = br.member_id
-- GROUP BY m.member_id, m.first_name, m.last_name
-- ORDER BY books_borrowed DESC;

-- ============================================
-- EXERCISE 6: CASE Statement
-- ============================================
-- Task: Categorize books by price: Cheap (<$12), Moderate ($12-$16), Expensive (>$16)

-- Hint: Use CASE WHEN in SELECT

-- Your solution here:


-- Solution:
-- SELECT 
--     title,
--     price,
--     CASE 
--         WHEN price < 12 THEN 'Cheap'
--         WHEN price BETWEEN 12 AND 16 THEN 'Moderate'
--         ELSE 'Expensive'
--     END AS price_category
-- FROM books
-- ORDER BY price;

-- ============================================
-- EXERCISE 7: Window Function
-- ============================================
-- Task: Rank books by price within each genre

-- Hint: Use RANK() OVER (PARTITION BY ... ORDER BY ...)

-- Your solution here:


-- Solution:
-- SELECT 
--     title,
--     author,
--     genre,
--     price,
--     RANK() OVER (PARTITION BY genre ORDER BY price DESC) AS price_rank_in_genre
-- FROM books
-- ORDER BY genre, price_rank_in_genre;

-- ============================================
-- EXERCISE 8: IN with Subquery
-- ============================================
-- Task: Find all books that have been borrowed

-- Hint: Use IN with a subquery

-- Your solution here:


-- Solution:
-- SELECT title, author, genre
-- FROM books
-- WHERE book_id IN (SELECT DISTINCT book_id FROM borrowings);

-- ============================================
-- EXERCISE 9: Date Operations
-- ============================================
-- Task: Find all borrowings from the last 30 days

-- Hint: Use date arithmetic with CURRENT_DATE

-- Your solution here:


-- Solution:
-- SELECT 
--     br.borrowing_id,
--     b.title,
--     m.first_name || ' ' || m.last_name AS member_name,
--     br.borrow_date
-- FROM borrowings br
-- JOIN books b ON br.book_id = b.book_id
-- JOIN members m ON br.member_id = m.member_id
-- WHERE br.borrow_date >= CURRENT_DATE - INTERVAL '30 days'
-- ORDER BY br.borrow_date DESC;

-- ============================================
-- EXERCISE 10: Multiple Aggregations
-- ============================================
-- Task: For each genre, show: total books, average price, most expensive book

-- Hint: Use GROUP BY with multiple aggregate functions

-- Your solution here:


-- Solution:
-- SELECT 
--     genre,
--     COUNT(*) AS total_books,
--     ROUND(AVG(price), 2) AS avg_price,
--     MAX(price) AS max_price,
--     SUM(copies_available) AS total_copies
-- FROM books
-- GROUP BY genre
-- ORDER BY total_books DESC;

-- ============================================
-- EXERCISE 11: UNION
-- ============================================
-- Task: Create a list of all Fiction and Fantasy books, indicating their genre

-- Hint: Use UNION to combine two queries

-- Your solution here:


-- Solution:
-- SELECT title, author, 'Fiction' AS genre FROM books WHERE genre = 'Fiction'
-- UNION
-- SELECT title, author, 'Fantasy' AS genre FROM books WHERE genre = 'Fantasy'
-- ORDER BY title;

-- ============================================
-- EXERCISE 12: Correlated Subquery
-- ============================================
-- Task: Find books that are the most expensive in their genre

-- Hint: Use a correlated subquery comparing price

-- Your solution here:


-- Solution:
-- SELECT b1.title, b1.genre, b1.price
-- FROM books b1
-- WHERE b1.price = (
--     SELECT MAX(b2.price)
--     FROM books b2
--     WHERE b2.genre = b1.genre
-- )
-- ORDER BY b1.genre;

-- ============================================
-- EXERCISE 13: EXISTS
-- ============================================
-- Task: Find members who have Premium membership AND have borrowed at least one book

-- Hint: Use EXISTS with a subquery

-- Your solution here:


-- Solution:
-- SELECT m.first_name, m.last_name, m.membership_type
-- FROM members m
-- WHERE m.membership_type = 'Premium'
--   AND EXISTS (
--     SELECT 1 FROM borrowings br WHERE br.member_id = m.member_id
--   );

-- ============================================
-- EXERCISE 14: CTE (Common Table Expression)
-- ============================================
-- Task: Find genres where the average book price is above the overall average

-- Hint: Use WITH to create a CTE for genre averages

-- Your solution here:


-- Solution:
-- WITH genre_avg AS (
--     SELECT genre, AVG(price) AS avg_price
--     FROM books
--     GROUP BY genre
-- ),
-- overall_avg AS (
--     SELECT AVG(price) AS overall_avg_price
--     FROM books
-- )
-- SELECT 
--     ga.genre,
--     ROUND(ga.avg_price, 2) AS genre_avg_price,
--     ROUND(oa.overall_avg_price, 2) AS overall_avg_price
-- FROM genre_avg ga
-- CROSS JOIN overall_avg oa
-- WHERE ga.avg_price > oa.overall_avg_price
-- ORDER BY ga.avg_price DESC;

-- ============================================
-- EXERCISE 15: Transaction Practice
-- ============================================
-- Task: Borrow a book (update copies_available, insert borrowing record)
-- Use a transaction to ensure both operations succeed or fail together

-- Hint: Use BEGIN, UPDATE, INSERT, COMMIT

-- Your solution here:


-- Solution:
-- BEGIN;
-- 
-- -- Decrease available copies
-- UPDATE books
-- SET copies_available = copies_available - 1
-- WHERE book_id = 1 AND copies_available > 0;
-- 
-- -- Record the borrowing
-- INSERT INTO borrowings (book_id, member_id, borrow_date, returned)
-- VALUES (1, 2, CURRENT_DATE, FALSE);
-- 
-- COMMIT;
-- 
-- -- Verify
-- SELECT * FROM books WHERE book_id = 1;
-- SELECT * FROM borrowings WHERE book_id = 1 AND member_id = 2;
