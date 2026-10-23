# 📚 Liane's Library

A personal library management application built with  **MySQL**, **Python**, **Pandas**, **SQLAlchemy**, and **Streamlit**.

This project demonstrates an end-to-end SQL-to-application workflow using a library management case study. It includes database design, advanced SQL querying, connecting a SQL database with Python, and building a Streamlit app to interact with the library data.


# 🚀 Live App

[👉 Open Liane's Library](https://lianes-library-app.streamlit.app/)


## 📌 Project Overview

Liane manages a large personal book collection and regularly lends books to friends and acquaintances, but over time, she started losing track of who borrowed which books. 
The goal of this project is to build a simple library management system for managing books, borrowers, and loans while keeping track of availability and reducing the risk of books going unreturned.

## 💡 The Solution

This project provides a simple database-backed web application that allows Liane to manage her personal library through an easy-to-use Streamlit interface.

The system connects a MySQL database with Python and Streamlit, enabling her to view, add, update, and manage library data without directly working with SQL commands.

The application allows her to:
- 📚 View and manage books
- 👥 Manage borrowers
- 🔄 Track borrowing records
- ✅ Check book availability
- ⏰ Identify overdue loans


## 🏗️ Project Architecture

```text
Database design
        ↓
SQL schema creation & Relationships
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
- 🔑 Primary and foreign keys
- 🔗 Table relationships and joins
- 🔍 Joins, filtering, and aggregations
- 🧮 Subqueries, CTEs, and temporary tables
- 🪟 Window functions
- ⚙️ Views, stored procedures and SQL functions
- 🐍 Python–SQL integration
- 🔗 SQLAlchemy database connection
- 🐼 Pandas data processing
- 🌐 Streamlit application development
- 🧪 Local database workflow

## 🛠️ Technologies

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
requirements.txt  Python dependencies
```

## 🧩 Project Components

### 🗄️ SQL

The SQL part of the project contains the database structure, table creation scripts, sample data, and advanced queries used to manage and analyse the library data.

### 🐍 Python

Python connects the application to MySQL using SQLAlchemy, executes SQL queries, and processes results with Pandas.

### 🌐 Streamlit Application

The Streamlit app provides a simple interface for interacting with the library data, such as viewing books, checking availability, and managing borrowing records.

## 🚀 Run Locally
```text
git clone https://github.com/satish-shrestha-4u/lianes-library-sql-streamlit-app
cd lianes-library-sql-streamlit-app

conda create -n lianes-library-env -c conda-forge python=3.12
conda activate lianes-library-env

pip install -r requirements.txt
```
Create the MySQL database and run the SQL files in:
```text
sql/lianes_library/
```
Configure the required database credentials in:
```text
.streamlit/secrets.toml
```
Then run:
```text
streamlit run src/app.py
```

## ✅ Purpose

This project demonstrates my ability to work across the complete data application workflow: designing relational databases, writing advanced SQL queries, connecting databases with Python, processing data, and building an interactive application with Streamlit.
