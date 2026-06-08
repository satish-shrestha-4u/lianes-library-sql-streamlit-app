-- Small seed data for final liane_library schema
-- Includes: 10 books, 10 friends, book_loans

USE liane_library;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE book_loans;
TRUNCATE TABLE books;
TRUNCATE TABLE friends;
SET FOREIGN_KEY_CHECKS = 1;


-- Books
INSERT INTO books (book_id, book_title, author_names, genre, availability, book_condition) VALUES
(1, 'Pride and Prejudice', 'Jane Austen', 'Classic Fiction', 1, 'Good'),
(2, '1984', 'George Orwell', 'Dystopian Fiction', 0, 'Very Good'),
(3, 'Harry Potter and the Philosopher''s Stone', 'J.K. Rowling', 'Fantasy', 0, 'Good'),
(4, 'The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 1, 'Very Good'),
(5, 'Murder on the Orient Express', 'Agatha Christie', 'Mystery', 1, 'Good'),
(6, 'The Shining', 'Stephen King', 'Horror', 0, 'Fair'),
(7, 'Norwegian Wood', 'Haruki Murakami', 'Literary Fiction', 1, 'Good'),
(8, 'Beloved', 'Toni Morrison', 'Literary Fiction', 1, 'Very Good'),
(9, 'Sapiens', 'Yuval Noah Harari', 'History', 0, 'Good'),
(10, 'Atomic Habits', 'James Clear', 'Self-help', 1, 'New');


-- Friends
INSERT INTO friends (friend_id, first_name, last_name, address, phone_number, max_loan_books, notes) VALUES
(1, 'Satish', 'Shrestha', 'Hauptstrasse 12, Essen', '+49 170 1111111', 3, 'Prefers nonfiction and data books'),
(2, 'Liane', 'Müller', 'Goethestrasse 5, Dortmund', '+49 171 2222222', 2, 'Returns books quickly'),
(3, 'Amit', 'Khanal', 'Bahnhofstrasse 18, Bochum', '+49 172 3333333', 4, 'Likes fantasy'),
(4, 'Sarah', 'Schmidt', 'Ringstrasse 41, Essen', '+49 173 4444444', 3, 'Interested in classics'),
(5, 'Michael', 'Weber', 'Parkallee 7, Düsseldorf', '+49 174 5555555', 2, 'Often borrows thrillers'),
(6, 'Anna', 'Fischer', 'Bergstrasse 22, Köln', '+49 175 6666666', 5, 'Likes literary fiction'),
(7, 'David', 'Neumann', 'Gartenstrasse 9, Bonn', '+49 176 7777777', 3, 'Call before lending'),
(8, 'Priya', 'Patel', 'Lindenweg 14, Münster', '+49 177 8888888', 4, 'Prefers history books'),
(9, 'Laura', 'Braun', 'Schillerstrasse 30, Wuppertal', '+49 178 9999999', 2, 'Likes horror'),
(10, 'Daniel', 'Wagner', 'Kaiserstrasse 3, Duisburg', '+49 179 1010101', 3, 'Interested in productivity books');

-- Book loans
-- return_date NULL means the book is currently borrowed.
INSERT INTO book_loans (loan_id, book_id, friend_id, loan_date, due_date, return_date) VALUES
(1, 1, 4, '2026-01-05', '2026-01-20', '2026-01-18'),
(2, 2, 1, '2026-05-01', '2026-05-15', NULL),
(3, 3, 3, '2026-05-03', '2026-05-17', NULL),
(4, 4, 2, '2026-02-10', '2026-02-24', '2026-02-23'),
(5, 5, 5, '2026-03-01', '2026-03-15', '2026-03-20'),
(6, 6, 9, '2026-05-10', '2026-05-24', NULL),
(7, 7, 6, '2026-04-01', '2026-04-15', '2026-04-14'),
(8, 8, 6, '2026-04-20', '2026-05-04', '2026-05-02'),
(9, 9, 8, '2026-05-12', '2026-05-26', NULL),
(10, 10, 10, '2026-02-01', '2026-02-15', '2026-02-10'),
(11, 2, 7, '2026-03-10', '2026-03-24', '2026-03-30'),
(12, 3, 1, '2026-01-15', '2026-01-29', '2026-01-28');

