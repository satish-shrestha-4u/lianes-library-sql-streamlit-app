# Liane's Library SQL Files

This folder contains the main SQL files for the Liane's Library database.

## Files

- `liane_library_database:schemas.sql` — creates the database tables and relationships
- `liane_library_seed_10.sql` — adds sample data for books, friends, and loans

## Purpose

These files create the MySQL database used by the Python and Streamlit app.

Run the files in this order:

```text
01_database_schema.sql
02_seed_sample_data.sql
