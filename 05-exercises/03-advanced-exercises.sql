-- ============================================
-- ADVANCED EXERCISES
-- ============================================
-- These exercises challenge you with complex queries, optimization, and advanced features

-- ============================================
-- EXERCISE 1: Complex Window Function
-- ============================================
-- Task: For each book, show its price, the previous book's price (by book_id),
-- and the difference between them

-- Hint: Use LAG() window function

-- Your solution here:


-- Solution:
-- SELECT 
--     title,
--     price,
--     LAG(price) OVER (ORDER BY book_id) AS previous_price,
--     price - LAG(price) OVER (ORDER BY book_id) AS price_difference
-- FROM books;

-- ============================================
-- EXERCISE 2: Recursive CTE
-- ============================================
-- Task: Generate a series of numbers from 1 to 10 and show their squares

-- Hint: Use WITH RECURSIVE

-- Your solution here:


-- Solution:
-- WITH RECURSIVE number_series AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1
--     FROM number_series
--     WHERE n < 10
-- )
-- SELECT n, n * n AS square
-- FROM number_series;

-- ============================================
-- EXERCISE 3: Pivot Table Simulation
-- ============================================
-- Task: Create a report showing count of books by genre and price category
-- (Cheap: <$12, Moderate: $12-$16, Expensive: >$16)
-- Result should have genres as rows and price categories as columns

-- Hint: Use CASE with COUNT and GROUP BY

-- Your solution here:


-- Solution:
-- SELECT 
--     genre,
--     COUNT(CASE WHEN price < 12 THEN 1 END) AS cheap,
--     COUNT(CASE WHEN price BETWEEN 12 AND 16 THEN 1 END) AS moderate,
--     COUNT(CASE WHEN price > 16 THEN 1 END) AS expensive,
--     COUNT(*) AS total
-- FROM books
-- GROUP BY genre
-- ORDER BY total DESC;

-- ============================================
-- EXERCISE 4: Running Total
-- ============================================
-- Task: Show books ordered by price with a running total of prices

-- Hint: Use SUM() as a window function

-- Your solution here:


-- Solution:
-- SELECT 
--     title,
--     price,
--     SUM(price) OVER (ORDER BY price, book_id) AS running_total
-- FROM books;

-- ============================================
-- EXERCISE 5: Complex Aggregation
-- ============================================
-- Task: For each member, calculate:
-- - Total books borrowed
-- - Total currently unreturned
-- - Average borrowing duration (for returned books)

-- Hint: Multiple aggregations with FILTER or CASE

-- Your solution here:


-- Solution:
-- SELECT 
--     m.first_name || ' ' || m.last_name AS member_name,
--     COUNT(br.borrowing_id) AS total_borrowed,
--     COUNT(br.borrowing_id) FILTER (WHERE br.returned = FALSE) AS currently_unreturned,
--     ROUND(AVG(br.return_date - br.borrow_date) FILTER (WHERE br.returned = TRUE), 1) AS avg_borrow_days
-- FROM members m
-- LEFT JOIN borrowings br ON m.member_id = br.member_id
-- GROUP BY m.member_id, m.first_name, m.last_name
-- ORDER BY total_borrowed DESC;

-- ============================================
-- EXERCISE 6: Median Calculation
-- ============================================
-- Task: Calculate the median price of all books

-- Hint: Use PERCENTILE_CONT

-- Your solution here:


-- Solution:
-- SELECT 
--     PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price,
--     AVG(price) AS mean_price,
--     MIN(price) AS min_price,
--     MAX(price) AS max_price
-- FROM books;

-- ============================================
-- EXERCISE 7: Self-Join for Comparison
-- ============================================
-- Task: Find pairs of books by the same author

-- Hint: Self-join on author, ensure you don't match a book with itself

-- Your solution here:


-- Solution:
-- SELECT DISTINCT
--     b1.author,
--     b1.title AS book1,
--     b2.title AS book2
-- FROM books b1
-- JOIN books b2 ON b1.author = b2.author AND b1.book_id < b2.book_id
-- ORDER BY b1.author;

-- ============================================
-- EXERCISE 8: Advanced Subquery
-- ============================================
-- Task: Find the most popular genre (most borrowed books)

-- Hint: Subquery joining borrowings and books, then aggregate

-- Your solution here:


-- Solution:
-- SELECT 
--     genre,
--     borrow_count
-- FROM (
--     SELECT 
--         b.genre,
--         COUNT(*) AS borrow_count
--     FROM borrowings br
--     JOIN books b ON br.book_id = b.book_id
--     GROUP BY b.genre
-- ) AS genre_stats
-- WHERE borrow_count = (
--     SELECT MAX(borrow_count)
--     FROM (
--         SELECT COUNT(*) AS borrow_count
--         FROM borrowings br
--         JOIN books b ON br.book_id = b.book_id
--         GROUP BY b.genre
--     ) AS sub
-- );

-- ============================================
-- EXERCISE 9: NTILE for Quartiles
-- ============================================
-- Task: Divide books into 4 price quartiles and count books in each

-- Hint: Use NTILE(4) to create quartiles, then aggregate

-- Your solution here:


-- Solution:
-- WITH quartile_data AS (
--     SELECT 
--         title,
--         price,
--         NTILE(4) OVER (ORDER BY price) AS price_quartile
--     FROM books
-- )
-- SELECT 
--     price_quartile,
--     COUNT(*) AS book_count,
--     MIN(price) AS min_price,
--     MAX(price) AS max_price
-- FROM quartile_data
-- GROUP BY price_quartile
-- ORDER BY price_quartile;

-- ============================================
-- EXERCISE 10: Complex Date Query
-- ============================================
-- Task: For each month, show how many books were borrowed and returned

-- Hint: Use date_trunc and conditional counts

-- Your solution here:


-- Solution:
-- SELECT 
--     DATE_TRUNC('month', borrow_date) AS month,
--     COUNT(*) AS borrowed,
--     COUNT(*) FILTER (WHERE returned = TRUE) AS returned,
--     COUNT(*) FILTER (WHERE returned = FALSE) AS still_out
-- FROM borrowings
-- GROUP BY month
-- ORDER BY month;

-- ============================================
-- EXERCISE 11: Generate Missing Data
-- ============================================
-- Task: Generate a list of all genres and show book count for each,
-- including genres with 0 books (if we had a genres table)

-- Hint: Use generate_series with VALUES or create a genre list

-- Your solution here:


-- Solution:
-- WITH all_genres AS (
--     SELECT unnest(ARRAY['Fiction', 'Non-Fiction', 'Fantasy', 
--                         'Romance', 'Biography', 'Self-Help', 
--                         'Science', 'History']) AS genre
-- )
-- SELECT 
--     ag.genre,
--     COUNT(b.book_id) AS book_count
-- FROM all_genres ag
-- LEFT JOIN books b ON ag.genre = b.genre
-- GROUP BY ag.genre
-- ORDER BY book_count DESC, ag.genre;

-- ============================================
-- EXERCISE 12: Performance Analysis
-- ============================================
-- Task: Create a view and analyze its query plan with EXPLAIN

-- Hint: Create view, then use EXPLAIN ANALYZE

-- Your solution here:


-- Solution:
-- CREATE OR REPLACE VIEW popular_books AS
-- SELECT 
--     b.title,
--     b.author,
--     b.genre,
--     COUNT(br.borrowing_id) AS borrow_count
-- FROM books b
-- LEFT JOIN borrowings br ON b.book_id = br.book_id
-- GROUP BY b.book_id, b.title, b.author, b.genre;
-- 
-- EXPLAIN ANALYZE SELECT * FROM popular_books WHERE borrow_count > 1;

-- ============================================
-- EXERCISE 13: Create Function
-- ============================================
-- Task: Create a function that returns all books by a given author

-- Hint: CREATE FUNCTION with RETURNS TABLE

-- Your solution here:


-- Solution:
-- CREATE OR REPLACE FUNCTION get_books_by_author(author_name VARCHAR)
-- RETURNS TABLE(
--     title VARCHAR,
--     published_year INTEGER,
--     genre VARCHAR,
--     price NUMERIC
-- ) AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT b.title, b.published_year, b.genre, b.price
--     FROM books b
--     WHERE b.author = author_name
--     ORDER BY b.published_year;
-- END;
-- $$ LANGUAGE plpgsql;
-- 
-- -- Test it:
-- SELECT * FROM get_books_by_author('George Orwell');

-- ============================================
-- EXERCISE 14: Index Optimization
-- ============================================
-- Task: Create appropriate indexes for the library database and verify improvement

-- Hint: Consider columns used in WHERE, JOIN, and ORDER BY

-- Your solution here:


-- Solution:
-- -- Create indexes
-- CREATE INDEX IF NOT EXISTS idx_books_genre ON books(genre);
-- CREATE INDEX IF NOT EXISTS idx_books_author ON books(author);
-- CREATE INDEX IF NOT EXISTS idx_borrowings_member ON borrowings(member_id);
-- CREATE INDEX IF NOT EXISTS idx_borrowings_book ON borrowings(book_id);
-- CREATE INDEX IF NOT EXISTS idx_borrowings_returned ON borrowings(returned);
-- 
-- -- Analyze query performance
-- EXPLAIN ANALYZE 
-- SELECT * FROM books WHERE genre = 'Fiction';
-- 
-- -- Check index usage
-- SELECT 
--     schemaname,
--     tablename,
--     indexname,
--     idx_scan,
--     idx_tup_read
-- FROM pg_stat_user_indexes
-- WHERE tablename IN ('books', 'borrowings', 'members')
-- ORDER BY idx_scan DESC;

-- ============================================
-- EXERCISE 15: Trigger Implementation
-- ============================================
-- Task: Create a trigger that automatically updates a book's copies_available
-- when a borrowing is marked as returned

-- Hint: Create trigger function, then trigger on UPDATE of borrowings

-- Your solution here:


-- Solution:
-- CREATE OR REPLACE FUNCTION update_book_copies()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     -- When a book is returned
--     IF NEW.returned = TRUE AND OLD.returned = FALSE THEN
--         UPDATE books
--         SET copies_available = copies_available + 1
--         WHERE book_id = NEW.book_id;
--     END IF;
--     
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;
-- 
-- CREATE TRIGGER borrowing_return_trigger
--     AFTER UPDATE ON borrowings
--     FOR EACH ROW
--     WHEN (NEW.returned = TRUE AND OLD.returned = FALSE)
--     EXECUTE FUNCTION update_book_copies();
-- 
-- -- Test it:
-- -- First check current copies
-- SELECT title, copies_available FROM books WHERE book_id = 2;
-- 
-- -- Mark a borrowing as returned
-- UPDATE borrowings SET returned = TRUE, return_date = CURRENT_DATE 
-- WHERE borrowing_id = 2;
-- 
-- -- Check copies again (should increase by 1)
-- SELECT title, copies_available FROM books WHERE book_id = 2;

-- ============================================
-- BONUS CHALLENGE
-- ============================================
-- Task: Create a comprehensive report function that generates library statistics

-- Your solution here:


-- Solution:
-- CREATE OR REPLACE FUNCTION library_statistics_report()
-- RETURNS TABLE(
--     metric VARCHAR,
--     value TEXT
-- ) AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT 'Total Books'::VARCHAR, COUNT(*)::TEXT FROM books
--     UNION ALL
--     SELECT 'Total Members'::VARCHAR, COUNT(*)::TEXT FROM members
--     UNION ALL
--     SELECT 'Books Currently Out'::VARCHAR, 
--            COUNT(*)::TEXT FROM borrowings WHERE returned = FALSE
--     UNION ALL
--     SELECT 'Most Popular Genre'::VARCHAR,
--            (SELECT genre FROM books b 
--             JOIN borrowings br ON b.book_id = br.book_id
--             GROUP BY genre ORDER BY COUNT(*) DESC LIMIT 1)
--     UNION ALL
--     SELECT 'Average Book Price'::VARCHAR,
--            '$' || ROUND(AVG(price), 2)::TEXT FROM books;
-- END;
-- $$ LANGUAGE plpgsql;
-- 
-- SELECT * FROM library_statistics_report();
