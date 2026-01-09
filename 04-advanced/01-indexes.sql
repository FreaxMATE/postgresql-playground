-- ============================================
-- INDEXES
-- ============================================
-- Indexes speed up data retrieval at the cost of slower writes
-- and additional storage space

-- Setup: Create a sample table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,  -- Automatically creates an index
    name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    price NUMERIC(10, 2),
    stock_quantity INTEGER,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO products (name, category, price, stock_quantity, description) VALUES
    ('Laptop', 'Electronics', 999.99, 50, 'High-performance laptop'),
    ('Mouse', 'Electronics', 29.99, 200, 'Wireless mouse'),
    ('Desk', 'Furniture', 299.99, 30, 'Ergonomic desk'),
    ('Chair', 'Furniture', 199.99, 45, 'Office chair'),
    ('Monitor', 'Electronics', 349.99, 60, '27-inch monitor'),
    ('Keyboard', 'Electronics', 79.99, 150, 'Mechanical keyboard'),
    ('Bookshelf', 'Furniture', 149.99, 25, 'Wooden bookshelf'),
    ('Lamp', 'Furniture', 49.99, 80, 'LED desk lamp');

-- ============================================
-- TYPES OF INDEXES
-- ============================================

-- 1. B-tree Index (default) - Good for equality and range queries
CREATE INDEX idx_products_category ON products(category);

-- 2. Unique Index - Ensures uniqueness (like PRIMARY KEY or UNIQUE constraint)
CREATE UNIQUE INDEX idx_products_name ON products(name);

-- 3. Multi-column Index (Composite Index)
-- Order matters! Best when filtering by category then price
CREATE INDEX idx_products_category_price ON products(category, price);

-- 4. Partial Index - Index only rows that meet a condition
-- Useful for frequently queried subsets
CREATE INDEX idx_expensive_products ON products(price)
WHERE price > 100;

-- 5. Expression Index - Index on computed values
CREATE INDEX idx_products_lower_name ON products(LOWER(name));

-- 6. Hash Index - Only for equality comparisons (=)
-- Generally use B-tree unless you have specific needs
CREATE INDEX idx_products_category_hash ON products USING hash(category);

-- 7. GiST Index - For full-text search, geometric data
-- CREATE INDEX idx_products_description_gin ON products USING gin(to_tsvector('english', description));

-- 8. GIN Index - For full-text search, JSONB, arrays
-- Better than GiST for text search
CREATE INDEX idx_products_description_fts ON products 
USING gin(to_tsvector('english', description));

-- ============================================
-- VIEW EXISTING INDEXES
-- ============================================

-- List all indexes on a table
SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'products';

-- More detailed index information
SELECT 
    i.relname AS index_name,
    a.attname AS column_name,
    ix.indisunique AS is_unique,
    ix.indisprimary AS is_primary
FROM pg_class t
JOIN pg_class i ON i.oid = ANY(ix.indrelid::regclass[])
JOIN pg_index ix ON i.oid = ix.indexrelid
JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
WHERE t.relname = 'products'
ORDER BY i.relname, a.attnum;

-- ============================================
-- ANALYZE QUERY PERFORMANCE
-- ============================================

-- EXPLAIN - Shows the query execution plan
EXPLAIN SELECT * FROM products WHERE category = 'Electronics';

-- EXPLAIN ANALYZE - Actually runs the query and shows real timing
EXPLAIN ANALYZE SELECT * FROM products WHERE category = 'Electronics';

-- Compare with and without index
-- Without index (drop it first to see the difference)
DROP INDEX IF EXISTS idx_products_category;
EXPLAIN ANALYZE SELECT * FROM products WHERE category = 'Electronics';

-- Recreate index
CREATE INDEX idx_products_category ON products(category);
EXPLAIN ANALYZE SELECT * FROM products WHERE category = 'Electronics';

-- ============================================
-- INDEX USAGE TIPS
-- ============================================

-- Good: Uses index
SELECT * FROM products WHERE category = 'Electronics';

-- Good: Range query uses B-tree index
SELECT * FROM products WHERE price BETWEEN 100 AND 500;

-- Bad: Function on indexed column prevents index use
-- SELECT * FROM products WHERE LOWER(category) = 'electronics';

-- Good: Use expression index
SELECT * FROM products WHERE LOWER(name) = 'laptop';

-- Good: Multi-column index works for leftmost columns
SELECT * FROM products WHERE category = 'Electronics'; -- Uses idx_products_category_price
SELECT * FROM products WHERE category = 'Electronics' AND price > 100; -- Uses idx_products_category_price

-- Bad: Can't use multi-column index starting from second column
-- SELECT * FROM products WHERE price > 100; -- Won't use idx_products_category_price

-- ============================================
-- INDEX MAINTENANCE
-- ============================================

-- Reindex a specific index (useful after many updates/deletes)
REINDEX INDEX idx_products_category;

-- Reindex entire table
REINDEX TABLE products;

-- Analyze table to update statistics (helps query planner)
ANALYZE products;

-- Vacuum and analyze (reclaim space and update stats)
VACUUM ANALYZE products;

-- ============================================
-- DROP INDEXES
-- ============================================

-- Drop a specific index
DROP INDEX IF EXISTS idx_products_category_hash;

-- Note: You can't drop the primary key index this way
-- You'd need to alter the table constraint

-- ============================================
-- WHEN TO USE INDEXES
-- ============================================

/*
CREATE INDEXES FOR:
✓ Columns frequently used in WHERE clauses
✓ Columns used in JOIN conditions
✓ Columns used in ORDER BY or GROUP BY
✓ Foreign key columns
✓ Columns with high selectivity (many unique values)

DON'T CREATE INDEXES FOR:
✗ Small tables (full table scan is faster)
✗ Columns rarely used in queries
✗ Columns with low selectivity (few unique values, like boolean)
✗ Tables with frequent INSERT/UPDATE/DELETE operations
✗ Columns that are mostly NULL

REMEMBER:
- Indexes speed up reads but slow down writes
- Each index uses disk space
- Too many indexes can hurt performance
- Monitor and drop unused indexes
- Use EXPLAIN ANALYZE to verify index usage
*/

-- Check index size
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE tablename = 'products'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Find unused indexes (after database has been running)
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
    AND idx_scan = 0  -- Never used
    AND indexrelname NOT LIKE '%_pkey'  -- Exclude primary keys
ORDER BY pg_relation_size(indexrelid) DESC;

-- Cleanup
-- DROP TABLE IF EXISTS products;
