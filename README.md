# 📚 Liane's Library

A personal library management system built with  **MySQL**, **Python**, **SQLAlchemy**, and **Streamlit**.

This project demonstrates a full SQL-to-application workflow using a library management case study. It includes database design, advanced SQL querying, connecting a SQL database with Python, and building a Streamlit app to interact with the library data.

## 📌 Project Overview

Liane is an avid reader with a large personal book collection. She enjoys lending books to friends, colleagues, and acquaintances, but over time, she started losing track of who borrowed which book.

The goal of this project is to create a simple library management system that helps Liane manage her collection, track loans, check book availability, and reduce the risk of books going unreturned.

## 🎯 The Problem
Liane wants to continue sharing her books, but she needs a better way to:
- track all books in her collection
- record who borrowed each book
- check which books are currently unavailable
- identify overdue loans
- manage borrowers without using complicated tools

## 💡 The Solution

This project provides a simple database-backed web application that allows Liane to manage her personal library through an easy-to-use Streamlit interface.

The system connects a MySQL database with Python and Streamlit, enabling users to view, add, update, and manage library data without directly working with SQL commands.

## 🔄 Workflow

```text
Database design
        ↓
SQL schema creation
        ↓
Table creation and sample data insertion
        ↓
Advanced SQL queries
        ↓
Python database connection
        ↓
SQL query execution with Python
        ↓
Streamlit web application
```

## 🧠 Key Areas Covered

- 🗄️ Relational database design
- 🧱 SQL schema creation
- 🔑 Primary keys and foreign keys
- 🔗 Table relationships
- 📊 Advanced SQL queries
- 🔍 Joins, filtering, and aggregations
- 🧮 Subqueries, CTEs, and temporary tables
- 🪟 Window functions
- ⚙️ Views, Stored procedures and SQL functions
- 🐍 Connecting SQL with Python
- 🔗 SQLAlchemy database connection
- 🐼 Reading SQL results into Pandas
- 🌐 Building a Streamlit interface
- 🧪 Local database workflow

## 🛠️ Tools Used

- 🐬 MySQL - database
- 🐍 Python - core programming language
- 🐼 Pandas - data manipulation
- 🔗 SQLAlchemy - database connection
- 🌐 Streamlit - web interface
- 🔌 PyMySQL — MySQL driver for Python

## 📁 Repository Structure

```text
sql/              SQL schema, sample data, and advanced SQL practice files
src/              Streamlit application files
notebooks/        SQL and Python connection notebooks
.gitignore        Files excluded from GitHub, including secrets
requirements.txt  Python package requirements
```

## 🧩 Project Components

### 🗄️ SQL

The SQL part of the project contains the database structure, table creation scripts, sample data, and advanced queries used to manage and analyse the library data.

### 🐍 Python

The Python part focuses on connecting to the SQL database, executing queries, and working with query results in Pandas.

### 🌐 Streamlit App

The Streamlit app provides a simple interface for interacting with the library data, such as viewing books, checking availability, and managing borrowing records.

## 🚀 How to Run
### 1️⃣ Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/lianes-library-sql-streamlit-app.git
cd lianes-library-sql-streamlit-app
```
### 2️⃣ Create and activate the environment
```bash
conda create -n lianes-library-env -c conda-forge python=3.12 streamlit sqlalchemy pandas pymysql python-dotenv
conda activate lianes-library-env
```
### 3️⃣ Set up the MySQL database
Create a MySQL database and run the SQL files in the `sql/lianes_library/` folder:
```text
liane_library_database:schemas.sql
liane_library_seed_10.sql
```
### 4️⃣ Create a Streamlit secrets file
Create a `.streamlit/secrets.toml` file in the project root:

```text
.streamlit/secrets.toml
```

### 5️⃣ Run the Streamlit app
```bash
streamlit run src/app.py
```

## ✅ Purpose

This project demonstrates my ability to work across the data application workflow: designing relational data, writing SQL queries, connecting databases with Python, and building a small interactive application using Streamlit.
