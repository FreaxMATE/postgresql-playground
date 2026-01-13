# PostgreSQL Basics

Learn the fundamental SQL operations in PostgreSQL.

## Contents

1. **Creating Tables** - Define database structure
2. **Inserting Data** - Add records to tables
3. **Selecting Data** - Retrieve records from tables
4. **Updating Data** - Modify existing records
5. **Deleting Data** - Remove records from tables

## How to Use These Files

### Method 1: From Command Line (Recommended)

Run each file in order from your terminal:

```bash
# Make sure PostgreSQL is running and you're in the postgresql directory
psql mylearning -f 01-basics/01-create-tables.sql
psql mylearning -f 01-basics/02-insert-data.sql
psql mylearning -f 01-basics/03-select-data.sql
psql mylearning -f 01-basics/04-update-data.sql
psql mylearning -f 01-basics/05-delete-data.sql
```

### Method 2: Inside psql Interactive Shell

```bash
# First, connect to the database
psql mylearning

# Then run files one by one (inside psql prompt)
\i 01-basics/01-create-tables.sql
\i 01-basics/02-insert-data.sql
\i 01-basics/03-select-data.sql
\i 01-basics/04-update-data.sql
\i 01-basics/05-delete-data.sql
```

## Quick Start Example

```bash
# 1. Connect to database
psql mylearning

# 2. Create tables
\i 01-basics/01-create-tables.sql

# 3. View the tables you created
\dt

# 4. See structure of a specific table
\d students

# 5. Insert some data
\i 01-basics/02-insert-data.sql

# 6. View the data
SELECT * FROM students;

# 7. Continue with other files...
```

## Useful Commands While Learning

### Basic Table Operations

```sql
-- View all tables
\dt

-- Describe a table (see columns, types, constraints)
\d students

-- List all tables and their owners
\dt *

-- Show table definition
\d+ students

-- View data in a table
SELECT * FROM students;

-- View just a few rows
SELECT * FROM students LIMIT 5;
```

### Extra Useful Commands for This Section

```sql
-- Check table constraints and indexes
\d students

-- View column information in detail
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'students';

-- Check all constraints on a table
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'students';

-- View default values for columns
\d+ students

-- See current schema
\dn

-- List all databases
\l

-- Show table size
SELECT pg_size_pretty(pg_total_relation_size('students'));

-- Count rows in table
SELECT COUNT(*) FROM students;

-- Check data types used
SELECT distinct(data_type) 
FROM information_schema.columns 
WHERE table_name IN ('students', 'courses', 'enrollments');

-- See all foreign keys in a table
SELECT constraint_name, column_name, foreign_table_name 
FROM information_schema.key_column_usage 
WHERE table_name = 'enrollments';

-- Drop a table if it exists (before recreating)
DROP TABLE IF EXISTS students CASCADE;

-- Clear screen
\! clear

-- Quit psql
\q
```

## Common Issues

**"Did not find any relations"** when running `\dt`:
- This means no tables exist yet
- Run `01-create-tables.sql` first

**Tables already exist error**:
- Run `06-drop-tables.sql` to clean up
- Then start over with `01-create-tables.sql`

**Lost track of what you did**:
- Use `\dt` to see all tables
- Use `SELECT * FROM table_name LIMIT 5;` to peek at data
