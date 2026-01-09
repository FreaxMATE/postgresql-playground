# Query Patterns

Master the art of querying data with PostgreSQL.

## Topics Covered

1. **Filtering** - WHERE, IN, BETWEEN, LIKE
2. **Joins** - INNER, LEFT, RIGHT, FULL OUTER
3. **Aggregation** - GROUP BY, HAVING, aggregate functions
4. **Sorting** - ORDER BY
5. **Subqueries** - Nested queries
6. **Set Operations** - UNION, INTERSECT, EXCEPT
7. **Window Functions** - Advanced analytics

## How to Use

### Quick Start - Run All Examples

```bash
# From command line
psql mylearning -f 03-queries/01-setup.sql
psql mylearning -f 03-queries/02-filtering.sql
psql mylearning -f 03-queries/03-joins.sql
psql mylearning -f 03-queries/04-aggregation.sql
psql mylearning -f 03-queries/05-subqueries.sql
psql mylearning -f 03-queries/06-advanced-queries.sql
```

### Interactive Learning (Recommended)

```bash
# Connect to database
psql mylearning

# Set up sample data first
\i 03-queries/01-setup.sql

# Verify data is loaded
\dt
SELECT * FROM employees LIMIT 5;

# Now explore each topic
\i 03-queries/02-filtering.sql
\i 03-queries/03-joins.sql
# ... etc
```

### Learn by Doing

After running setup, try these queries yourself:

```sql
-- Simple queries
SELECT * FROM employees WHERE salary > 80000;
SELECT first_name, last_name FROM employees ORDER BY salary DESC;

-- Joins
SELECT e.first_name, d.department_name 
FROM employees e 
JOIN departments d ON e.department_id = d.department_id;

-- Aggregation
SELECT department_id, COUNT(*), AVG(salary) 
FROM employees 
GROUP BY department_id;
```

## Learning Path

1. **Start with 01-setup.sql** - Creates sample database with employees, departments, projects
2. **02-filtering.sql** - Learn WHERE, LIKE, BETWEEN, IN
3. **03-joins.sql** - Master INNER, LEFT, RIGHT, FULL joins
4. **04-aggregation.sql** - Use COUNT, AVG, SUM, GROUP BY, HAVING
5. **05-subqueries.sql** - Write nested queries and CTEs
6. **06-advanced-queries.sql** - Window functions, UNION, complex patterns

## Tips

- Run each file section by section (copy-paste queries)
- Modify queries to see different results
- Use `\d table_name` to understand table structure
- Experiment with your own variations
