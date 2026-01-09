-- ============================================
-- TRANSACTIONS
-- ============================================
-- Transactions ensure ACID properties:
-- Atomicity: All or nothing
-- Consistency: Database remains valid
-- Isolation: Transactions don't interfere with each other
-- Durability: Committed changes persist

-- Setup: Create sample tables
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    account_holder VARCHAR(100) NOT NULL,
    balance NUMERIC(12, 2) NOT NULL CHECK (balance >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions_log (
    transaction_id SERIAL PRIMARY KEY,
    from_account INTEGER,
    to_account INTEGER,
    amount NUMERIC(12, 2),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20)
);

-- Insert sample data
INSERT INTO accounts (account_holder, balance) VALUES
    ('Alice Johnson', 5000.00),
    ('Bob Smith', 3000.00),
    ('Carol Williams', 7500.00);

-- ============================================
-- BASIC TRANSACTION SYNTAX
-- ============================================

-- START TRANSACTION or BEGIN to start
-- COMMIT to save changes
-- ROLLBACK to undo changes

-- Example: Transfer money between accounts
BEGIN;

-- Deduct from sender
UPDATE accounts 
SET balance = balance - 500.00
WHERE account_holder = 'Alice Johnson';

-- Add to receiver
UPDATE accounts 
SET balance = balance + 500.00
WHERE account_holder = 'Bob Smith';

-- Log the transaction
INSERT INTO transactions_log (from_account, to_account, amount, status)
VALUES (1, 2, 500.00, 'completed');

-- Commit the transaction
COMMIT;

-- View results
SELECT * FROM accounts;
SELECT * FROM transactions_log;

-- ============================================
-- ROLLBACK EXAMPLE
-- ============================================

-- Start a transaction that we'll rollback
BEGIN;

UPDATE accounts 
SET balance = balance - 1000.00
WHERE account_holder = 'Bob Smith';

UPDATE accounts 
SET balance = balance + 1000.00
WHERE account_holder = 'Carol Williams';

-- Check the uncommitted changes
SELECT * FROM accounts;

-- Oops, changed our mind - rollback
ROLLBACK;

-- Data is back to the original state
SELECT * FROM accounts;

-- ============================================
-- SAVEPOINTS
-- ============================================
-- Savepoints allow partial rollback within a transaction

BEGIN;

-- Update 1
UPDATE accounts 
SET balance = balance - 200.00
WHERE account_holder = 'Alice Johnson';

SAVEPOINT after_alice_debit;

-- Update 2
UPDATE accounts 
SET balance = balance + 200.00
WHERE account_holder = 'Bob Smith';

SAVEPOINT after_bob_credit;

-- Update 3 (let's say this fails)
UPDATE accounts 
SET balance = balance - 100.00
WHERE account_holder = 'Carol Williams';

-- Rollback to specific savepoint (undo update 3 only)
ROLLBACK TO SAVEPOINT after_bob_credit;

-- Continue with transaction
INSERT INTO transactions_log (from_account, to_account, amount, status)
VALUES (1, 2, 200.00, 'completed');

COMMIT;

SELECT * FROM accounts;

-- ============================================
-- TRANSACTION ISOLATION LEVELS
-- ============================================

/*
PostgreSQL supports these isolation levels:
1. READ UNCOMMITTED (not really different from READ COMMITTED in PostgreSQL)
2. READ COMMITTED (default)
3. REPEATABLE READ
4. SERIALIZABLE
*/

-- Set isolation level for current transaction
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- Your queries here
COMMIT;

-- Or set for session
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- ============================================
-- READ COMMITTED (Default)
-- ============================================
-- Each query sees data committed before the query started

-- Transaction 1
BEGIN;
SELECT balance FROM accounts WHERE account_holder = 'Alice Johnson';
-- (Shows 4800.00)

-- Meanwhile, Transaction 2 commits a change
-- BEGIN;
-- UPDATE accounts SET balance = 5000.00 WHERE account_holder = 'Alice Johnson';
-- COMMIT;

-- Back to Transaction 1
SELECT balance FROM accounts WHERE account_holder = 'Alice Johnson';
-- (Now shows 5000.00 - sees the committed change)
COMMIT;

-- ============================================
-- REPEATABLE READ
-- ============================================
-- All queries in the transaction see a snapshot from the start

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT balance FROM accounts WHERE account_holder = 'Alice Johnson';
-- (Shows current balance)

-- Even if another transaction commits changes,
-- this transaction will see the same data
SELECT balance FROM accounts WHERE account_holder = 'Alice Johnson';
-- (Shows same balance)
COMMIT;

-- ============================================
-- SERIALIZABLE
-- ============================================
-- Strictest isolation - transactions execute as if serial

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- Your queries here
COMMIT;

-- ============================================
-- LOCKS
-- ============================================

-- Explicit locks for specific situations

-- SELECT FOR UPDATE - Lock rows for update
BEGIN;
SELECT * FROM accounts WHERE account_holder = 'Alice Johnson' FOR UPDATE;
-- Row is locked until transaction ends
UPDATE accounts SET balance = balance - 100 WHERE account_holder = 'Alice Johnson';
COMMIT;

-- SELECT FOR SHARE - Lock for reading (allows other reads, blocks writes)
BEGIN;
SELECT * FROM accounts WHERE account_holder = 'Bob Smith' FOR SHARE;
-- Other transactions can read but not modify
COMMIT;

-- LOCK TABLE - Lock entire table
BEGIN;
LOCK TABLE accounts IN ACCESS EXCLUSIVE MODE;
-- Full exclusive lock on table
COMMIT;

-- ============================================
-- HANDLING DEADLOCKS
-- ============================================

/*
Deadlock example (requires two concurrent sessions):

Session 1:
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
-- Now wait...
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;

Session 2 (running concurrently):
BEGIN;
UPDATE accounts SET balance = balance - 50 WHERE account_id = 2;
-- Now wait...
UPDATE accounts SET balance = balance + 50 WHERE account_id = 1;
COMMIT;

One will be rolled back with a deadlock error.
Always access resources in the same order to avoid deadlocks!
*/

-- ============================================
-- TRANSACTION BEST PRACTICES
-- ============================================

/*
1. Keep transactions short
2. Don't include user interaction in transactions
3. Access tables in the same order across transactions
4. Use appropriate isolation levels
5. Handle errors and rollback when needed
6. Use savepoints for complex transactions
7. Avoid long-running transactions
*/

-- ============================================
-- ERROR HANDLING IN TRANSACTIONS
-- ============================================

-- PostgreSQL function with transaction handling
CREATE OR REPLACE FUNCTION transfer_money(
    from_id INTEGER,
    to_id INTEGER,
    amount NUMERIC
) RETURNS BOOLEAN AS $$
BEGIN
    -- Start implicit transaction (functions are transactional)
    
    -- Check if sender has enough balance
    IF (SELECT balance FROM accounts WHERE account_id = from_id) < amount THEN
        RAISE EXCEPTION 'Insufficient funds';
    END IF;
    
    -- Deduct from sender
    UPDATE accounts SET balance = balance - amount WHERE account_id = from_id;
    
    -- Add to receiver
    UPDATE accounts SET balance = balance + amount WHERE account_id = to_id;
    
    -- Log transaction
    INSERT INTO transactions_log (from_account, to_account, amount, status)
    VALUES (from_id, to_id, amount, 'completed');
    
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Transaction automatically rolls back on error
        INSERT INTO transactions_log (from_account, to_account, amount, status)
        VALUES (from_id, to_id, amount, 'failed');
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Test the function
SELECT transfer_money(1, 2, 100.00);
SELECT * FROM accounts;
SELECT * FROM transactions_log;

-- Try with insufficient funds
SELECT transfer_money(2, 1, 10000.00);
SELECT * FROM transactions_log;

-- ============================================
-- TWO-PHASE COMMIT (Advanced)
-- ============================================
-- For distributed transactions across databases

-- Prepare transaction
BEGIN;
UPDATE accounts SET balance = balance - 50 WHERE account_id = 1;
PREPARE TRANSACTION 'my_transaction_id';

-- Later, commit or rollback
COMMIT PREPARED 'my_transaction_id';
-- or
-- ROLLBACK PREPARED 'my_transaction_id';

-- Cleanup
-- DROP FUNCTION IF EXISTS transfer_money;
-- DROP TABLE IF EXISTS transactions_log;
-- DROP TABLE IF EXISTS accounts;
