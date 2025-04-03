-- Library Database 
-- Created by: Damon Levy



DROP DATABASE IF EXISTS SimpleLibraryDB;
CREATE DATABASE SimpleLibraryDB;
USE SimpleLibraryDB;

-- 1. Basic Tables
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    author_id INT,
    available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id)
);

CREATE TABLE Borrowers (
    borrower_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);

CREATE TABLE Loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    borrower_id INT,
    loan_date DATE DEFAULT (CURRENT_DATE),
    returned BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (borrower_id) REFERENCES Borrowers(borrower_id)
);

-- 2. Sample Data
INSERT INTO Authors (name) VALUES
('J.K. Rowling'),
('George R.R. Martin'),
('Haruki Murakami');

INSERT INTO Books (title, author_id) VALUES
('Harry Potter and the Philosopher''s Stone', 1),
('A Game of Thrones', 2),
('Norwegian Wood', 3);

INSERT INTO Borrowers (name, email) VALUES
('John Smith', 'john@email.com'),
('Emily Davis', 'emily@email.com');

-- 3. CRUD OPERATIONS

-- CREATE (Insert new records)
INSERT INTO Authors (name) VALUES ('Agatha Christie');
INSERT INTO Books (title, author_id) VALUES ('Murder on the Orient Express', 4);
INSERT INTO Borrowers (name, email) VALUES ('Michael Johnson', 'michael@email.com');

-- READ (Select data)
-- Get all books
SELECT * FROM Books;

-- Get available books
SELECT b.title, a.name AS author 
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
WHERE b.available = TRUE;

-- Find books by specific author
--SELECT title FROM Books WHERE author_id = 1;

-- UPDATE (Modify existing data)
-- Mark a book as unavailable
--UPDATE Books SET available = FALSE WHERE book_id = 1;

-- Update borrower email
--UPDATE Borrowers SET email = 'new.email@example.com' WHERE borrower_id = 1;

-- DELETE (Remove records)
-- Remove a borrower
-- DELETE FROM Borrowers WHERE borrower_id = 3;

-- Remove a book (only if not referenced elsewhere)
-- DELETE FROM Books WHERE book_id = 4;

-- 5. BORROW BOOK FUNCTIONALITY

-- Function to borrow a book
DELIMITER //
CREATE PROCEDURE BorrowBook(
    IN p_book_id INT,
    IN p_borrower_id INT
)
BEGIN
    DECLARE book_available BOOLEAN;
    
    -- Check if book is available
    SELECT available INTO book_available FROM Books WHERE book_id = p_book_id;
    
    IF book_available THEN
        -- Record the loan
        INSERT INTO Loans (book_id, borrower_id) VALUES (p_book_id, p_borrower_id);
        
        -- Update book availability
        UPDATE Books SET available = FALSE WHERE book_id = p_book_id;
        
        SELECT CONCAT('Book successfully borrowed on ', CURRENT_DATE) AS message;
    ELSE
        SELECT 'Book is not available for borrowing' AS message;
    END IF;
END //
DELIMITER ;

-- Function to return a book
DELIMITER //
CREATE PROCEDURE ReturnBook(
    IN p_loan_id INT
)
BEGIN
    DECLARE book_id_var INT;
    
    -- Get the book ID from the loan
    SELECT book_id INTO book_id_var FROM Loans WHERE loan_id = p_loan_id;
    
    -- Mark loan as returned
    UPDATE Loans SET returned = TRUE WHERE loan_id = p_loan_id;
    
    -- Update book availability
    UPDATE Books SET available = TRUE WHERE book_id = book_id_var;
    
    SELECT 'Book successfully returned' AS message;
END //
DELIMITER ;

-- Test the borrow function
--CALL BorrowBook(1, 1);  -- Should succeed
--CALL BorrowBook(1, 2);  -- Should fail (book already borrowed)

-- View current loans
--SELECT b.title, br.name, l.loan_date 
--FROM Loans l
--JOIN Books b ON l.book_id = b.book_id
--JOIN Borrowers br ON l.borrower_id = br.borrower_id
-- WHERE l.returned = FALSE;

-- Test the return function
--CALL ReturnBook(1);  -- Return the first loan

-- Verify book is available again
--SELECT title, available FROM Books WHERE book_id = 1;