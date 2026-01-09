-- ============================================
-- POSTGRESQL DATA TYPES DEMONSTRATION
-- ============================================

-- Create a comprehensive table showcasing various data types
CREATE TABLE data_type_examples (
    -- NUMERIC TYPES
    id SERIAL PRIMARY KEY,                    -- Auto-incrementing integer
    small_number SMALLINT,                    -- -32,768 to 32,767
    regular_number INTEGER,                   -- -2,147,483,648 to 2,147,483,647
    big_number BIGINT,                        -- Very large integers
    decimal_number DECIMAL(10, 2),            -- Exact decimal (10 digits, 2 after decimal)
    money_amount NUMERIC(12, 2),              -- Like DECIMAL, for money
    float_number REAL,                        -- 6 decimal digits precision
    double_number DOUBLE PRECISION,           -- 15 decimal digits precision
    
    -- CHARACTER TYPES
    fixed_char CHAR(5),                       -- Fixed-length (padded with spaces)
    variable_char VARCHAR(100),               -- Variable-length with limit
    unlimited_text TEXT,                      -- Unlimited length text
    
    -- DATE AND TIME TYPES
    date_only DATE,                           -- Date without time
    time_only TIME,                           -- Time without date
    time_with_tz TIME WITH TIME ZONE,        -- Time with timezone
    timestamp_field TIMESTAMP,                -- Date and time
    timestamp_with_tz TIMESTAMP WITH TIME ZONE, -- Date, time, and timezone
    interval_field INTERVAL,                  -- Time interval/duration
    
    -- BOOLEAN TYPE
    is_active BOOLEAN,                        -- TRUE, FALSE, or NULL
    
    -- JSON TYPES
    json_data JSON,                           -- JSON format (stores as text)
    jsonb_data JSONB,                         -- Binary JSON (faster, indexable)
    
    -- ARRAY TYPES
    integer_array INTEGER[],                  -- Array of integers
    text_array TEXT[],                        -- Array of text
    
    -- UUID TYPE
    unique_id UUID,                           -- Universally unique identifier
    
    -- SPECIAL TYPES
    ip_address INET,                          -- IPv4 or IPv6 address
    mac_address MACADDR,                      -- MAC address
    network_cidr CIDR,                        -- Network address
    
    -- BINARY DATA
    binary_data BYTEA                         -- Binary data (files, images)
);

-- ============================================
-- INSERT SAMPLE DATA
-- ============================================

INSERT INTO data_type_examples (
    small_number,
    regular_number,
    big_number,
    decimal_number,
    money_amount,
    float_number,
    double_number,
    fixed_char,
    variable_char,
    unlimited_text,
    date_only,
    time_only,
    time_with_tz,
    timestamp_field,
    timestamp_with_tz,
    interval_field,
    is_active,
    json_data,
    jsonb_data,
    integer_array,
    text_array,
    unique_id,
    ip_address,
    mac_address,
    network_cidr,
    binary_data
) VALUES (
    100,                                      -- small_number
    1000000,                                  -- regular_number
    9223372036854775807,                      -- big_number
    12345.67,                                 -- decimal_number
    50000.99,                                 -- money_amount
    3.14159,                                  -- float_number
    2.718281828459045,                        -- double_number
    'HELLO',                                  -- fixed_char
    'Variable length string',                 -- variable_char
    'This is a very long text that can be unlimited in length. PostgreSQL handles large text efficiently.',
    '2024-03-15',                             -- date_only
    '14:30:00',                               -- time_only
    '14:30:00+00',                            -- time_with_tz
    '2024-03-15 14:30:00',                    -- timestamp_field
    '2024-03-15 14:30:00+00',                 -- timestamp_with_tz
    '2 hours 30 minutes',                     -- interval_field
    TRUE,                                     -- is_active
    '{"name": "John", "age": 30}',            -- json_data
    '{"name": "John", "age": 30, "active": true}', -- jsonb_data
    ARRAY[1, 2, 3, 4, 5],                    -- integer_array
    ARRAY['apple', 'banana', 'orange'],      -- text_array
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',  -- unique_id
    '192.168.1.1',                            -- ip_address
    '08:00:2b:01:02:03',                      -- mac_address
    '192.168.1.0/24',                         -- network_cidr
    '\xDEADBEEF'                              -- binary_data (hex notation)
);

-- ============================================
-- QUERY EXAMPLES FOR DIFFERENT DATA TYPES
-- ============================================

-- Numeric operations
SELECT 
    regular_number,
    regular_number * 2 AS doubled,
    ROUND(decimal_number) AS rounded_decimal
FROM data_type_examples;

-- String operations
SELECT 
    variable_char,
    LENGTH(variable_char) AS char_length,
    UPPER(variable_char) AS uppercase,
    LOWER(variable_char) AS lowercase,
    SUBSTRING(variable_char, 1, 8) AS first_8_chars
FROM data_type_examples;

-- Date/Time operations
SELECT 
    date_only,
    date_only + INTERVAL '7 days' AS next_week,
    EXTRACT(YEAR FROM date_only) AS year,
    EXTRACT(MONTH FROM date_only) AS month,
    AGE(CURRENT_DATE, date_only) AS age_from_today
FROM data_type_examples;

-- Boolean operations
SELECT 
    is_active,
    CASE WHEN is_active THEN 'Active' ELSE 'Inactive' END AS status
FROM data_type_examples;

-- JSON operations
SELECT 
    json_data,
    json_data->>'name' AS name,           -- Extract as text
    jsonb_data->'age' AS age,             -- Extract as JSON
    jsonb_data->>'age' AS age_text        -- Extract as text
FROM data_type_examples;

-- JSONB queries (more powerful)
SELECT * FROM data_type_examples
WHERE jsonb_data @> '{"active": true}';   -- Contains check

-- Array operations
SELECT 
    integer_array,
    integer_array[1] AS first_element,    -- Arrays are 1-indexed in PostgreSQL
    array_length(integer_array, 1) AS array_size,
    3 = ANY(integer_array) AS contains_three
FROM data_type_examples;

-- Unnest array (convert to rows)
SELECT unnest(text_array) AS fruit
FROM data_type_examples;

-- UUID generation
SELECT 
    unique_id,
    gen_random_uuid() AS new_random_uuid  -- Generate new UUID
FROM data_type_examples;

-- Network address operations
SELECT 
    ip_address,
    broadcast(network_cidr) AS broadcast_address,
    netmask(network_cidr) AS subnet_mask,
    host(ip_address) AS ip_as_text
FROM data_type_examples;

-- ============================================
-- TYPE CASTING
-- ============================================

SELECT 
    -- Cast integer to text
    regular_number::TEXT AS number_as_text,
    
    -- Cast text to integer
    '12345'::INTEGER AS text_as_number,
    
    -- Cast timestamp to date
    timestamp_field::DATE AS timestamp_as_date,
    
    -- Cast with CAST function
    CAST(decimal_number AS INTEGER) AS decimal_as_integer
FROM data_type_examples;

-- ============================================
-- CONSTRAINTS WITH DATA TYPES
-- ============================================

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(10, 2) CHECK (price > 0),      -- Price must be positive
    quantity INTEGER DEFAULT 0 CHECK (quantity >= 0), -- Quantity can't be negative
    manufactured_date DATE CHECK (manufactured_date <= CURRENT_DATE),
    description TEXT,
    tags TEXT[],
    metadata JSONB,
    is_available BOOLEAN DEFAULT TRUE
);

-- ============================================
-- CLEANUP
-- ============================================

-- Uncomment to drop tables
-- DROP TABLE IF EXISTS products;
-- DROP TABLE IF EXISTS data_type_examples;
