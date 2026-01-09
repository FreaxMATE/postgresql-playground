# Advanced PostgreSQL Topics

Learn advanced database concepts and optimization techniques.

## Topics

1. **Indexes** - Speed up queries with proper indexing
2. **Transactions** - Ensure data consistency with ACID properties
3. **Views** - Create virtual tables for simplified queries
4. **Functions** - Write reusable database logic
5. **Triggers** - Automatically execute code on data changes
6. **Constraints** - Enforce data integrity rules

## Prerequisites

Complete the basics and queries sections first for best understanding.

## How to Use

### Quick Start

```bash
# From command line - run each file individually
psql mylearning -f 04-advanced/01-indexes.sql
psql mylearning -f 04-advanced/02-transactions.sql
psql mylearning -f 04-advanced/03-views.sql
psql mylearning -f 04-advanced/04-functions.sql
psql mylearning -f 04-advanced/05-triggers.sql
```

### Interactive Learning (Recommended)

```bash
# Connect to database
psql mylearning

# Learn about indexes
\i 04-advanced/01-indexes.sql

# Check what indexes were created
\di

# Learn about transactions
\i 04-advanced/02-transactions.sql

# Continue with other topics...
```

## What You'll Learn

### Indexes
- When to use indexes
- Different index types (B-tree, hash, GIN, etc.)
- Performance optimization with EXPLAIN
- Index maintenance

### Transactions
- ACID properties
- BEGIN, COMMIT, ROLLBACK
- Isolation levels
- Handling concurrent access

### Views
- Creating reusable queries
- Updatable views
- Materialized views
- Security and abstraction

### Functions
- Writing custom PostgreSQL functions
- Return types and parameters
- PL/pgSQL language basics
- Error handling

### Triggers
- Automatic actions on data changes
- BEFORE vs AFTER triggers
- Row-level vs statement-level
- Audit logging

## Example Workflow

```sql
-- 1. Create a simple table
CREATE TABLE products (id SERIAL, name TEXT, price NUMERIC);

-- 2. Add an index for better performance
CREATE INDEX idx_products_name ON products(name);

-- 3. Create a view for common queries
CREATE VIEW expensive_products AS 
SELECT * FROM products WHERE price > 100;

-- 4. Create a function
CREATE FUNCTION get_product_count() RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM products);
END;
$$ LANGUAGE plpgsql;

-- 5. Use everything together
SELECT * FROM expensive_products;
SELECT get_product_count();
```
