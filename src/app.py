import streamlit as st
import pandas as pd
from sqlalchemy import create_engine, text
from urllib.parse import quote_plus
from datetime import date, timedelta

# -----------------------------
# Database connection 
# -----------------------------

schema = "liane_library"
host = "127.0.0.1"
user = "root"
password = quote_plus(st.secrets["mysql"]["password"])
port = 3306

connection_string = f"mysql+pymysql://{user}:{password}@{host}:{port}/{schema}"

engine = create_engine(connection_string)


# -----------------------------
# Helper functions 
# -----------------------------

# This is for reading data from MySQL into Python/Streamlit.
def load_data(query, params=None):
    return pd.read_sql(text(query), con=engine, params=params)

# This is for running, changing data in MySQL.
def run_query(query, params=None):
    with engine.begin() as connection:
        connection.execute(text(query), params or {})
        
## NOTE: without helper function books_df = pd.read_sql("SELECT * FROM books;", con=engine) and with helper function books_df = load_data("SELECT * FROM books;")


# -----------------------------
# App
# -----------------------------

st.set_page_config(page_title="Liane's Library", page_icon="📚", layout="wide")

# To make the title with other color
st.markdown(
    "<h1 style='color:#8B4513;'>📚 Liane's Library</h1>",
    unsafe_allow_html=True)

st.write(" Welcome To \"**MY WORLD OF BOOKS**\" ")

st.sidebar.title("OPTIONS")



#This line creates a default page the first time the app starts
if "menu" not in st.session_state:
    st.session_state.menu = "View Books"


# create click-buttons on the sidebar
if st.sidebar.button("📚 View Books"):
    st.session_state.menu = "View Books"

if st.sidebar.button("➕ Add Book"):
    st.session_state.menu = "Add Book"

if st.sidebar.button("👥 View Friends"):
    st.session_state.menu = "View Friends"

if st.sidebar.button("➕ Add Friend"):
    st.session_state.menu = "Add Friend"

if st.sidebar.button("📖 Borrow Book"):
    st.session_state.menu = "Borrow Book"

if st.sidebar.button("✅ Return Book"):
    st.session_state.menu = "Return Book"

if st.sidebar.button("⏰ Overdue Books"):
    st.session_state.menu = "Overdue Books"

# -----------------------------
# Delete / Deactivate section
# -----------------------------
st.sidebar.markdown("---")
st.sidebar.subheader("🚫 Delete Records")

if st.sidebar.button("🗑️ Delete Book"):
    st.session_state.menu = "Delete Book"

if st.sidebar.button("🗑️ Delete Friend"):
    st.session_state.menu = "Delete Friend"

menu = st.session_state.menu
# -----------------------------
# View Books
# -----------------------------

if menu == "View Books":
    st.header("📚 All Books")
    
    #to make a search bar 
    search_text_book = st.text_input("🔍 Search books by title, author, genre, availability or book condition")

    books_df = load_data("""
        SELECT 
            book_id,
            book_title as Book_Name,
            author_names as Author_Name,
            genre as Book_Genre,
            CASE 
                WHEN availability = 1 THEN 'Available'
                ELSE 'Borrowed'
            END AS Availability,
            book_condition as Book_Condition
        FROM books
        WHERE 
            book_title LIKE :search
            OR author_names LIKE :search
            OR genre LIKE :search
            OR book_condition LIKE :search
            OR (CASE WHEN availability = 1 THEN 'Available'
                ELSE 'Borrowed' END) LIKE :search
        ORDER BY book_id;
    """, {"search": f"%{search_text_book}%"})

    st.dataframe(books_df, hide_index=True, width="stretch")


# -----------------------------
# Add Book
# -----------------------------

elif menu == "Add Book":
    st.header("➕ Add New Book")

    book_title = st.text_input("Book title")
    author_names = st.text_input("Author name")
    genre = st.text_input("Book Genre")
    book_condition = st.selectbox(
        "Book condition",
        ["New", "Very Good", "Good", "Fair", "Damaged"]
    )

    if st.button("Add Book"):
        if book_title.strip() == "" or author_names.strip() == "":
            st.warning("Book title and author names are required.")
           
        # check if the same book already exists
        else:
            existing_book = load_data("""
                            SELECT * FROM books 
                            WHERE LOWER(book_title) = LOWER(:book_title)
                            AND LOWER(author_names) = LOWER(:author_names);

                            """, {"book_title": book_title.strip(),
                                  "author_names": author_names.strip()
                                })

            if not existing_book.empty:
                st.warning("This book already exists in the library.")
            else:
                run_query("""
                    INSERT INTO books 
                        (book_title, author_names, genre, availability, book_condition)
                    VALUES 
                        (:book_title, :author_names, :genre, TRUE, :book_condition);
                """, {
                    "book_title": book_title,
                    "author_names": author_names,
                    "genre": genre,
                    "book_condition": book_condition
                })

                st.success("Book added successfully.")
                st.balloons()
                st.toast("📚 One new book added to Liane's Library!")


# -----------------------------
# View Friends
# -----------------------------

elif menu == "View Friends":
    st.header("👤 Friends")
    #to make a search bar
    search_text_friend = st.text_input("🔍 Search friends by name, phone, or address")
    friends_df = load_data("""
        SELECT 
            friend_id,
            first_name,
            last_name,
            address,
            phone_number,
            max_loan_books,
            notes
        FROM friends
        WHERE 
            first_name Like :search
            OR last_name Like :search
            OR phone_number LIKE :search
            OR address LIKE :search
            OR notes LIKE :search
        ORDER BY friend_id;
    """, {"search":f"%{search_text_friend}%"})

    st.dataframe(friends_df, hide_index=True, width="stretch")


# -----------------------------
# Add Friend
# -----------------------------

elif menu == "Add Friend":
    st.header("➕ Add New Friend")

    first_name = st.text_input("First name")
    last_name = st.text_input("Last name")
    address = st.text_input("Address")
    phone_number = st.text_input("Phone number")
    max_loan_books = st.number_input("Max loan books", min_value=1, max_value=5, value=3)
    notes = st.text_area("Notes")

    if st.button("Add Friend"):
        if first_name.strip() == "":
            st.warning("First name is required.")
        else:
            existing_friend = load_data(""" 
                        Select *
                        From friends
                        WHERE first_name = :first_name
                        AND last_name = :last_name
                        AND phone_number = :phone_number;
                        """,
                        {
                        "first_name": first_name,
                        "last_name": last_name,
                        "phone_number": phone_number
                        })
            
            if not existing_friend.empty:
                st.warning("This friend already exists.")
            else:
                run_query("""
                    INSERT INTO friends 
                        (first_name, last_name, address, phone_number, max_loan_books, notes)
                    VALUES 
                        (:first_name, :last_name, :address, :phone_number, :max_loan_books, :notes);
                """, {
                    "first_name": first_name,
                    "last_name": last_name,
                    "address": address,
                    "phone_number": phone_number,
                    "max_loan_books": max_loan_books,
                    "notes": notes
                })

                st.success("Friend added successfully.")
                st.toast("👥 One new friend added to Liane's Library!")


# -----------------------------
# Borrow Book
# -----------------------------

elif menu == "Borrow Book":
    st.header("📖 Borrow Book")

    available_books = load_data("""
        SELECT 
            book_id,
            book_title,
            author_names
        FROM books
        WHERE availability = TRUE
        ORDER BY book_id;
    """)

    friends = load_data("""
        SELECT 
            friend_id,
            first_name,
            last_name
        FROM friends
        ORDER BY friend_id;
    """)

    if available_books.empty:
        st.warning("No available books.")
    elif friends.empty:
        st.warning("No friends found.")
    else:
        book_choice = st.selectbox(
            "Choose book",
            available_books["book_id"].astype(str) + " - " + available_books["book_title"] + " by " + available_books["author_names"]
        )

        friend_choice = st.selectbox(
            "Choose friend",
            friends["friend_id"].astype(str) + " - " + friends["first_name"] + " " + friends["last_name"]
        )

        loan_date = st.date_input("Loan date", value=date.today())
        due_date = st.date_input("Due date", value=date.today() + timedelta(days=14))

        if st.button("Borrow Book"):
            if due_date < loan_date:
                st.warning("Due date cannot be before loan date.") 
            else:
                book_id = int(book_choice.split(" - ")[0])
                friend_id = int(friend_choice.split(" - ")[0])

                with engine.begin() as connection:
                    connection.execute(text("""
                        INSERT INTO book_loans 
                            (book_id, friend_id, loan_date, due_date, return_date)
                        VALUES 
                            (:book_id, :friend_id, :loan_date, :due_date, NULL);
                    """), {
                        "book_id": book_id,
                        "friend_id": friend_id,
                        "loan_date": loan_date,
                        "due_date": due_date
                    })
    
                    connection.execute(text("""
                        UPDATE books
                        SET availability = FALSE
                        WHERE book_id = :book_id;
                    """), {
                        "book_id": book_id
                    })
    
                st.success("Book borrowed successfully.")
                
# Note: "engine.connect()" = connect only, good for SELECT queries, reading data,fetching results But for INSERT, UPDATE, or DELETE, you may need to manually commit. Whereas, "engine.begin()" = connect + transaction + automatic commit/rollback, good for INSERT, UPDATE, DELETE.

# -----------------------------
# Return Book
# -----------------------------
elif menu == "Return Book":
    st.header("✅ Return Book")

    borrowed_books = load_data("""
        SELECT 
            bl.loan_id,
            b.book_id,
            b.book_title,
            f.first_name,
            f.last_name,
            bl.loan_date,
            bl.due_date,
            b.book_condition
        FROM book_loans AS bl
        JOIN books AS b
            ON bl.book_id = b.book_id
        JOIN friends AS f
            ON bl.friend_id = f.friend_id
        WHERE bl.return_date IS NULL
        ORDER BY bl.due_date;
    """)

    if borrowed_books.empty:
        st.info("No books are currently borrowed.")
    else:
        loan_choice = st.selectbox("Choose book to return", 
                                   borrowed_books["loan_id"].astype(str) +
                                   " - " + 
                                   borrowed_books["book_title"]+ 
                                   " borrowed by " + 
                                   borrowed_books["first_name"] + 
                                   " " + 
                                   borrowed_books["last_name"]
                                   )
        
        return_date = st.date_input("Return date", value=date.today())
        
        book_condition = st.selectbox ("Book Condition when Returned", 
                                        ["New", "Very Good", "Good", "Fair", "Damaged"])

        if st.button("Return Book"):
            loan_id = int(loan_choice.split(" - ")[0])
            selected_loan = borrowed_books[borrowed_books["loan_id"] == loan_id].iloc[0]

            if return_date < selected_loan["loan_date"]:
                st.warning("Return date cannot be before loan date.")
            else:
                with engine.begin() as connection:
                    book_result = connection.execute(text("""
                        SELECT book_id
                        FROM book_loans
                        WHERE loan_id = :loan_id;
                    """), {"loan_id": loan_id}).fetchone()
    
                    book_id = book_result[0]
    
                    connection.execute(text("""
                        UPDATE book_loans
                        SET return_date = :return_date
                        WHERE loan_id = :loan_id;
                    """), {
                        "return_date": return_date,
                        "loan_id": loan_id
                    })
                    # change the book condition when returned
                    connection.execute(text("""
                        UPDATE books
                        SET availability = TRUE,
                        book_condition = :book_condition
                        WHERE book_id = :book_id;
                    """), {
                        "book_id": book_id,
                        "book_condition" :book_condition
                    })
                    
                st.success("Book returned successfully.")
                st.toast("A Book has been returned")

# -----------------------------
# Overdue Books
# -----------------------------
elif menu == "Overdue Books":
    st.header("⏰ Overdue Books")

    overdue_df = load_data("""
        SELECT 
            bl.loan_id,
            b.book_title,
            f.first_name,
            f.last_name,
            bl.loan_date,
            bl.due_date,
            DATEDIFF(CURDATE(), bl.due_date) AS days_overdue
        FROM book_loans AS bl
        JOIN books AS b
            ON bl.book_id = b.book_id
        JOIN friends AS f
            ON bl.friend_id = f.friend_id
        WHERE bl.return_date IS NULL
          AND bl.due_date < CURDATE()
        ORDER BY days_overdue DESC;
    """)

    if overdue_df.empty:
        st.success("No overdue books.")
    else:
        st.dataframe(overdue_df, hide_index= True, width="stretch")



# -----------------------------
# Delete Book
# -----------------------------

elif menu == "Delete Book":
    st.header("🗑️ Delete Book")

    books_df = load_data("""
        SELECT 
            book_id,
            book_title,
            author_names
        FROM books
        ORDER BY book_id;
    """)

    if books_df.empty:
        st.info("No books found.")
    else:
        book_choice = st.selectbox(
            "Choose book to delete",
            books_df["book_id"].astype(str)
            + " - "
            + books_df["book_title"]
            + " by "
            + books_df["author_names"]
        )

        st.warning("Deleting a book will also delete its loan history.")

        confirm_delete = st.checkbox("I understand and want to delete this book.")

        if st.button("Delete Book"):
            if not confirm_delete:
                st.warning("Please confirm before deleting.")
            else:
                book_id = int(book_choice.split(" - ")[0])

                with engine.begin() as connection:
                    # delete related loans first
                    connection.execute(text("""
                        DELETE FROM book_loans
                        WHERE book_id = :book_id;
                    """), {
                        "book_id": book_id
                    })

                    # delete book after loan records
                    connection.execute(text("""
                        DELETE FROM books
                        WHERE book_id = :book_id;
                    """), {
                        "book_id": book_id
                    })

                st.success("Book deleted permanently.")
                st.toast("🗑️ Book removed.")

# -----------------------------
# Delete Friend
# -----------------------------
elif menu == "Delete Friend":
    st.header("🗑️ Delete Friend")

    friends_df = load_data("""
        SELECT 
            friend_id,
            first_name,
            last_name,
            phone_number
        FROM friends
        ORDER BY friend_id;
    """)

    if friends_df.empty:
        st.info("No friends found.")
    else:
        friend_choice = st.selectbox(
            "Choose friend to delete",
            friends_df["friend_id"].astype(str)
            + " - "
            + friends_df["first_name"]
            + " "
            + friends_df["last_name"]
            + " | "
            + friends_df["phone_number"].fillna("") # fillna("") prevents NaN or NULL or errors from appearing in the dropdown.
        )

        st.warning("Deleting a friend will also delete their loan history.")

        confirm_delete = st.checkbox("I understand and want to delete this friend.")

        if st.button("Delete Friend"):
            if not confirm_delete:
                st.warning("Please confirm before deleting.")
            else:
                friend_id = int(friend_choice.split(" - ")[0])

                with engine.begin() as connection:
                    # delete related loans first
                    connection.execute(text("""
                        DELETE FROM book_loans
                        WHERE friend_id = :friend_id;
                    """), {
                        "friend_id": friend_id
                    })

                    # delete friend after loan records
                    connection.execute(text("""
                        DELETE FROM friends
                        WHERE friend_id = :friend_id;
                    """), {
                        "friend_id": friend_id
                    })

                st.success("Friend deleted permanently.")
                st.toast("🗑️ Friend removed.")





    