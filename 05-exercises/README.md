# Practice Exercises

Test your PostgreSQL knowledge with these hands-on exercises.

## Structure

Each exercise file contains:
- Problem statement
- Sample data setup
- Hints
- Solution (at the bottom, commented out)

## Exercises

1. **Beginner Level** - Basic CRUD operations (10 exercises)
2. **Intermediate Level** - Joins and aggregations (15 exercises)
3. **Advanced Level** - Complex queries and optimizations (15 exercises)

## How to Practice

### Recommended Approach

1. **Open the exercise file** in your editor
2. **Read each problem** carefully
3. **Try to write the solution yourself**
4. **Test your solution** in psql:
   ```bash
   psql mylearning
   \i 05-exercises/01-beginner-exercises.sql
   ```
5. **Check the hints** if you're stuck
6. **Compare with the solution** (uncomment at bottom)
7. **Understand why it works**

### Quick Start

```bash
# Start with beginner exercises
psql mylearning

# The file includes setup - it creates tables with sample data
\i 05-exercises/01-beginner-exercises.sql

# Work through exercises 1-10
# Write your solutions where it says "Your solution here:"

# Move to intermediate when ready
\i 05-exercises/02-intermediate-exercises.sql

# Finally, advanced exercises
\i 05-exercises/03-advanced-exercises.sql
```

### Example Workflow

```sql
-- 1. Run the exercise file (includes setup)
\i 05-exercises/01-beginner-exercises.sql

-- 2. Try EXERCISE 1 yourself
-- Problem: Retrieve all books published after 2000
SELECT * FROM books WHERE published_year > 2000;

-- 3. Check if it works
-- If stuck, scroll down to see the solution

-- 4. Try variations
SELECT title, author FROM books WHERE published_year > 2000;
SELECT * FROM books WHERE published_year BETWEEN 2000 AND 2020;

-- 5. Move to next exercise
```

## Exercise Topics

### Beginner (01-beginner-exercises.sql)
- Basic SELECT statements
- WHERE clauses
- Sorting with ORDER BY
- COUNT and GROUP BY
- Simple INSERT, UPDATE, DELETE
- Basic JOINs

### Intermediate (02-intermediate-exercises.sql)
- LEFT/RIGHT JOINs
- Subqueries
- GROUP BY with HAVING
- CASE statements
- Window functions
- Date operations
- CTEs (Common Table Expressions)

### Advanced (03-advanced-exercises.sql)
- Complex window functions
- Recursive CTEs
- Pivot tables
- Performance optimization
- Functions and procedures
- Triggers
- Index optimization

## Tips for Success

1. **Practice regularly** - Do a few exercises each day
2. **Type it yourself** - Don't just read the solutions
3. **Experiment** - Try variations of each query
4. **Use \d commands** - Understand table structures
   ```sql
   \dt           -- See all tables
   \d books      -- See table structure
   ```
5. **Start simple** - Begin with beginner exercises even if you know some SQL
6. **Compare approaches** - Solutions often show multiple ways to solve problems
7. **Check your work** - Use SELECT to verify INSERT/UPDATE/DELETE operations

## Common Commands While Practicing

```sql
-- See what tables exist
\dt

-- See table structure
\d books
\d members

-- View sample data
SELECT * FROM books LIMIT 5;

-- Reset if needed (drop tables and start fresh)
DROP TABLE IF EXISTS borrowings, members, books;

-- Re-run the setup section from the exercise file
\i 05-exercises/01-beginner-exercises.sql
```

Good luck! 🚀
