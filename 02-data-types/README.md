# PostgreSQL Data Types

Understanding PostgreSQL's rich data type system.

## Categories

1. **Numeric Types** - Integers, decimals, floating-point
2. **Character Types** - Text, strings
3. **Date/Time Types** - Dates, times, timestamps
4. **Boolean Type** - True/false values
5. **JSON Types** - Structured data
6. **Array Types** - Lists of values
7. **Special Types** - UUID, IP addresses, geometric types

## How to Use

### Quick Start

```bash
# Run the demo file
psql mylearning -f 02-data-types/data-types-demo.sql

# Or inside psql
psql mylearning
\i 02-data-types/data-types-demo.sql

# View the created table
\d data_type_examples

# See the data
SELECT * FROM data_type_examples;
```

### Explore Specific Data Types

Inside psql, after running the demo:

```sql
-- See all numeric examples
SELECT 
    small_number, 
    regular_number, 
    decimal_number, 
    money_amount 
FROM data_type_examples;

-- See text/string examples
SELECT variable_char, unlimited_text FROM data_type_examples;

-- See date/time examples
SELECT date_only, timestamp_field FROM data_type_examples;

-- See JSON examples
SELECT json_data, jsonb_data FROM data_type_examples;

-- See array examples
SELECT integer_array, text_array FROM data_type_examples;
```

## Key Takeaways

- Choose appropriate types for your data to save space and improve performance
- Use constraints to ensure data integrity
- PostgreSQL has rich support for modern data types like JSON and arrays
- JSONB is faster and indexable compared to JSON
- Arrays allow storing multiple values in a single column
