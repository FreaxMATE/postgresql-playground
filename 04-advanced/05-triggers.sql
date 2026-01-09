-- ============================================
-- TRIGGERS
-- ============================================
-- Triggers automatically execute functions in response to events
-- Events: INSERT, UPDATE, DELETE, TRUNCATE

-- Setup: Create tables for examples
CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    last_modified TIMESTAMP
);

CREATE TABLE products_audit (
    audit_id SERIAL PRIMARY KEY,
    product_id INTEGER,
    action VARCHAR(10),
    old_price NUMERIC(10, 2),
    new_price NUMERIC(10, 2),
    old_stock INTEGER,
    new_stock INTEGER,
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- BEFORE INSERT TRIGGER
-- ============================================

-- Trigger function that sets last_modified timestamp
CREATE OR REPLACE FUNCTION set_last_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_modified := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER products_before_insert
    BEFORE INSERT ON products
    FOR EACH ROW
    EXECUTE FUNCTION set_last_modified();

-- Test it
INSERT INTO products (name, price, stock_quantity)
VALUES ('Laptop', 999.99, 50);

SELECT * FROM products;

-- ============================================
-- BEFORE UPDATE TRIGGER
-- ============================================

CREATE TRIGGER products_before_update
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION set_last_modified();

-- Test it
UPDATE products SET price = 899.99 WHERE name = 'Laptop';
SELECT * FROM products;

-- ============================================
-- AFTER INSERT/UPDATE/DELETE TRIGGER (Audit Log)
-- ============================================

CREATE OR REPLACE FUNCTION audit_product_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO products_audit (product_id, action, new_price, new_stock, changed_by)
        VALUES (NEW.product_id, 'INSERT', NEW.price, NEW.stock_quantity, current_user);
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO products_audit (
            product_id, action, 
            old_price, new_price, 
            old_stock, new_stock, 
            changed_by
        )
        VALUES (
            NEW.product_id, 'UPDATE',
            OLD.price, NEW.price,
            OLD.stock_quantity, NEW.stock_quantity,
            current_user
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO products_audit (product_id, action, old_price, old_stock, changed_by)
        VALUES (OLD.product_id, 'DELETE', OLD.price, OLD.stock_quantity, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create audit triggers
CREATE TRIGGER products_after_insert_audit
    AFTER INSERT ON products
    FOR EACH ROW
    EXECUTE FUNCTION audit_product_changes();

CREATE TRIGGER products_after_update_audit
    AFTER UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION audit_product_changes();

CREATE TRIGGER products_after_delete_audit
    AFTER DELETE ON products
    FOR EACH ROW
    EXECUTE FUNCTION audit_product_changes();

-- Test the audit triggers
INSERT INTO products (name, price, stock_quantity)
VALUES ('Mouse', 29.99, 100);

UPDATE products SET price = 24.99 WHERE name = 'Mouse';
UPDATE products SET stock_quantity = 95 WHERE name = 'Mouse';

DELETE FROM products WHERE name = 'Mouse';

-- View audit log
SELECT * FROM products_audit ORDER BY changed_at;

-- ============================================
-- CONDITIONAL TRIGGER (Only fire when specific column changes)
-- ============================================

CREATE OR REPLACE FUNCTION notify_price_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.price IS DISTINCT FROM NEW.price THEN
        RAISE NOTICE 'Price changed for product %: % -> %', 
                     NEW.name, OLD.price, NEW.price;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_price_change
    AFTER UPDATE ON products
    FOR EACH ROW
    WHEN (OLD.price IS DISTINCT FROM NEW.price)
    EXECUTE FUNCTION notify_price_change();

-- Test it
UPDATE products SET price = 999.99 WHERE name = 'Laptop';  -- Will trigger
UPDATE products SET stock_quantity = 45 WHERE name = 'Laptop';  -- Won't trigger

-- ============================================
-- PREVENT INVALID DATA WITH TRIGGER
-- ============================================

CREATE OR REPLACE FUNCTION prevent_negative_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock_quantity < 0 THEN
        RAISE EXCEPTION 'Stock quantity cannot be negative';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_check_stock
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION prevent_negative_stock();

-- Test it
-- This will fail
-- UPDATE products SET stock_quantity = -5 WHERE name = 'Laptop';

-- ============================================
-- STATEMENT-LEVEL TRIGGER
-- ============================================
-- Fires once per statement, not per row

CREATE TABLE product_changes_log (
    log_id SERIAL PRIMARY KEY,
    operation VARCHAR(10),
    rows_affected INTEGER,
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_product_statement()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO product_changes_log (operation, rows_affected)
    VALUES (TG_OP, (SELECT COUNT(*) FROM products));
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_statement_log
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH STATEMENT
    EXECUTE FUNCTION log_product_statement();

-- Test it - this fires once even though multiple rows might be affected
INSERT INTO products (name, price, stock_quantity) VALUES
    ('Keyboard', 79.99, 150),
    ('Monitor', 349.99, 60);

SELECT * FROM product_changes_log;

-- ============================================
-- CASCADE DELETE WITH TRIGGER
-- ============================================

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER,
    order_date DATE DEFAULT CURRENT_DATE
);

-- Insert some orders
INSERT INTO orders (product_id, quantity)
SELECT product_id, 5 FROM products WHERE name = 'Laptop';

-- Create trigger to delete related orders when product is deleted
CREATE OR REPLACE FUNCTION delete_product_orders()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM orders WHERE product_id = OLD.product_id;
    RAISE NOTICE 'Deleted orders for product %', OLD.name;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_before_delete_orders
    BEFORE DELETE ON products
    FOR EACH ROW
    EXECUTE FUNCTION delete_product_orders();

-- Test it
-- DELETE FROM products WHERE name = 'Laptop';

-- ============================================
-- AUTOMATICALLY UPDATE AGGREGATE TABLE
-- ============================================

CREATE TABLE product_stats (
    stat_id SERIAL PRIMARY KEY,
    total_products INTEGER,
    total_value NUMERIC(15, 2),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Initialize stats
INSERT INTO product_stats (total_products, total_value)
SELECT COUNT(*), SUM(price * stock_quantity) FROM products;

-- Function to update stats
CREATE OR REPLACE FUNCTION update_product_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE product_stats
    SET total_products = (SELECT COUNT(*) FROM products),
        total_value = (SELECT SUM(price * stock_quantity) FROM products),
        last_updated = CURRENT_TIMESTAMP;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update stats on any change
CREATE TRIGGER products_update_stats
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH STATEMENT
    EXECUTE FUNCTION update_product_stats();

-- Test it
INSERT INTO products (name, price, stock_quantity)
VALUES ('Desk Lamp', 49.99, 80);

SELECT * FROM product_stats;

-- ============================================
-- VIEW TRIGGERS
-- ============================================

-- List all triggers on a table
SELECT 
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers
WHERE event_object_table = 'products'
ORDER BY trigger_name;

-- More detailed trigger information
SELECT 
    tgname AS trigger_name,
    tgtype AS trigger_type,
    tgenabled AS enabled,
    proname AS function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
JOIN pg_class c ON t.tgrelid = c.oid
WHERE c.relname = 'products';

-- ============================================
-- DISABLE/ENABLE TRIGGERS
-- ============================================

-- Disable a specific trigger
ALTER TABLE products DISABLE TRIGGER products_price_change;

-- Enable it back
ALTER TABLE products ENABLE TRIGGER products_price_change;

-- Disable all triggers on a table
ALTER TABLE products DISABLE TRIGGER ALL;

-- Enable all triggers
ALTER TABLE products ENABLE TRIGGER ALL;

-- ============================================
-- DROP TRIGGERS
-- ============================================

DROP TRIGGER IF EXISTS products_before_insert ON products;
DROP TRIGGER IF EXISTS products_before_update ON products;
DROP TRIGGER IF EXISTS products_after_insert_audit ON products;
DROP TRIGGER IF EXISTS products_after_update_audit ON products;
DROP TRIGGER IF EXISTS products_after_delete_audit ON products;
DROP TRIGGER IF EXISTS products_price_change ON products;
DROP TRIGGER IF EXISTS products_check_stock ON products;
DROP TRIGGER IF EXISTS products_statement_log ON products;
DROP TRIGGER IF EXISTS products_before_delete_orders ON products;
DROP TRIGGER IF EXISTS products_update_stats ON products;

-- Drop functions
DROP FUNCTION IF EXISTS set_last_modified();
DROP FUNCTION IF EXISTS audit_product_changes();
DROP FUNCTION IF EXISTS notify_price_change();
DROP FUNCTION IF EXISTS prevent_negative_stock();
DROP FUNCTION IF EXISTS log_product_statement();
DROP FUNCTION IF EXISTS delete_product_orders();
DROP FUNCTION IF EXISTS update_product_stats();

-- ============================================
-- TRIGGER BEST PRACTICES
-- ============================================

/*
WHEN TO USE TRIGGERS:
✓ Audit logging
✓ Enforcing complex business rules
✓ Maintaining derived data
✓ Cascading changes
✓ Validating data
✓ Automatic timestamping

WHEN NOT TO USE TRIGGERS:
✗ Simple validation (use CHECK constraints instead)
✗ Complex business logic (use application code)
✗ Performance-critical operations
✗ When transparency is important

BEST PRACTICES:
1. Keep trigger functions simple and fast
2. Avoid cascading triggers (triggers calling triggers)
3. Be careful with BEFORE triggers - they can modify data
4. Use appropriate timing (BEFORE vs AFTER)
5. Use row-level for individual row logic
6. Use statement-level for aggregate operations
7. Document trigger behavior clearly
8. Test thoroughly, especially with bulk operations
9. Consider performance impact
10. Use WHEN clause to limit trigger execution

AVAILABLE VARIABLES IN TRIGGER FUNCTIONS:
- NEW: New row for INSERT/UPDATE
- OLD: Old row for UPDATE/DELETE
- TG_OP: Operation name (INSERT, UPDATE, DELETE, TRUNCATE)
- TG_NAME: Trigger name
- TG_WHEN: BEFORE or AFTER
- TG_LEVEL: ROW or STATEMENT
- TG_TABLE_NAME: Table name
*/

-- Cleanup
-- DROP TABLE IF EXISTS product_stats;
-- DROP TABLE IF EXISTS orders;
-- DROP TABLE IF EXISTS product_changes_log;
-- DROP TABLE IF EXISTS products_audit;
-- DROP TABLE IF EXISTS products;
