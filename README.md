# PostgreSQL Learning Guide

A comprehensive repository to learn PostgreSQL fundamentals from scratch.

## What is PostgreSQL?

PostgreSQL is a powerful, open-source object-relational database system with over 35 years of active development. It's known for its reliability, feature robustness, and performance.

## Prerequisites

- Basic understanding of databases
- PostgreSQL installed on your system

## Quick Start (Choose One)

### Option 1: Nix (Recommended - Works on any Linux/macOS) ❄️

**One command to start:**
```bash
nix develop
# That's it! PostgreSQL starts automatically
```

**Use it:**
```bash
psql mylearning                              # Connect to database
psql mylearning -f 01-basics/01-create-tables.sql  # Run SQL file
pg_ctl stop                                  # Stop when done
```

**Optional - Auto-load with direnv:**
```bash
echo "use flake" > .envrc && direnv allow
# Now PostgreSQL auto-starts when you cd into this directory!
```

### Option 2: Docker 🐳

**Start:**
```bash
docker compose up -d
```

**Use it:**
```bash
docker exec -it postgresql-learning psql -U postgres -d mylearning
```

**Stop:**
```bash
docker compose down
```

**With GUI:**
```bash
make docker-gui
# pgAdmin at http://localhost:5050 (admin@example.com / admin)
```

### Option 3: System PostgreSQL

**Install:**
```bash
# Ubuntu/Debian
sudo apt install postgresql

# macOS
brew install postgresql@15
```

**Use it:**
```bash
sudo -u postgres createdb mylearning
sudo -u postgres psql mylearning
```

## Repository Structure

```
📁 01-basics/           # Core SQL operations (CREATE, INSERT, SELECT, UPDATE, DELETE)
📁 02-data-types/       # PostgreSQL data types and their usage
📁 03-queries/          # Query patterns (WHERE, JOIN, GROUP BY, ORDER BY)
📁 04-advanced/         # Indexes, transactions, views, and functions
📁 05-exercises/        # Practice problems with solutions
```

## Learning Path

1. **Basics** - Start here to understand tables, CRUD operations
2. **Data Types** - Learn PostgreSQL's rich type system
3. **Queries** - Master filtering, joining, and aggregating data
4. **Advanced** - Explore performance and advanced features
5. **Exercises** - Practice what you've learned

## Quick Reference Commands



## Tips for Learning

1. Practice each example by typing it yourself
2. Experiment by modifying the queries
3. Check the output to understand what each query does
4. Complete exercises to reinforce your learning

## Common Commands

### Running SQL Files

**From command line (outside psql):**
```bash
psql mylearning -f 01-basics/01-create-tables.sql
psql mylearning -f 01-basics/02-insert-data.sql
```

**Inside psql (after running `psql mylearning`):**
```sql
\i 01-basics/01-create-tables.sql
\i 01-basics/02-insert-data.sql
```

### PostgreSQL Interactive Commands (inside psql)

```sql
-- View data
\dt                   -- List all tables
\d table_name         -- Show table structure
SELECT * FROM students;  -- View all data in students table

-- Navigation
\l                    -- List all databases
\c database_name      -- Switch to different database
\q                    -- Quit psql

-- Help
\?                    -- Show all psql commands
\h SELECT             -- Help on SQL command
```

### From Command Line

```bash
# Connect to database
psql mylearning

# Run SQL file from command line
psql mylearning -f 01-basics/01-create-tables.sql

# Run SQL directly
psql mylearning -c "SELECT * FROM students;"

# Stop PostgreSQL (Nix)
pg_ctl stop

# Docker commands
docker exec -it postgresql-learning psql -U postgres -d mylearning
docker compose down                 # Stop
```

## Troubleshooting

**"Address already in use" or "Port conflict"**
- Nix setup uses Unix sockets only (no port conflicts!)
- If still issues: `rm -rf .pgdata && nix develop`

**"Permission denied"**
```bash
chmod -R 700 .pgdata
```

**Start fresh:**
```bash
# Nix
rm -rf .pgdata && nix develop

# Docker
docker compose down -v && docker compose up -d
```

## Resources

- [Official PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Tutorial](https://www.postgresqltutorial.com/)
- [PostgreSQL Exercises](https://pgexercises.com/)

Happy Learning! 🐘
