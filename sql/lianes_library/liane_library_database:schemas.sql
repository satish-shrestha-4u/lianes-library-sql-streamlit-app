Drop database if exists liane_library;

Create schema if not exists liane_library;

USE liane_library;

-- Drop Table if exists books;
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    book_title VARCHAR(100) NOT NULL,
    author_names VARCHAR(100),
    genre VARCHAR(50),
    availability BOOLEAN NOT NULL DEFAULT 1,
    book_condition VARCHAR(50)
);

    
-- Drop Table if exists friends;
CREATE TABLE friends (
    friend_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    address VARCHAR(50),
    phone_number VARCHAR(50),
    max_loan_books TINYINT DEFAULT 5,
    notes TEXT
);

-- Drop Table if exists book_loans;
CREATE TABLE book_loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    friend_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE,
    return_date DATE,
    FOREIGN KEY (book_id)
        REFERENCES books (book_id),
    FOREIGN KEY (friend_id)
        REFERENCES friends (friend_id)
);
    

    
DESCRIBE books;
DESCRIBE friends;
DESCRIBE book_loans;

-- to change or update the value 
UPDATE friends
SET first_name = 'Diana',
    last_name = 'Sheron',
    address = 'Hauptstrasse 20, Essen',
    phone_number = '+49 170 1234567',
    max_loan_books = 4,
    notes = 'Prefers nonfiction and data books'
WHERE friend_id = 1;


-- to delete friend row/rows
DELETE FROM friends 
WHERE
    friend_id = 11 OR friend_id = 12;
    
-- to add a new friend
-- You do not include friend_id because it is AUTO_INCREMENT.
INSERT INTO friends 
    (first_name, last_name, address, phone_number, max_loan_books, notes)
VALUES
    ('Maya', 'Keller', 'Hauptstrasse 12, Essen', '+49 170 1234567', 3, 'Likes fantasy books');
    

    
    