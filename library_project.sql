-- sql project title -library management system

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;


/* Task 1 Identify Members with Overdue Books
   Write a query to identify members who have overdue books (assume a 30-day return period).
   Display the member's name, book title, issue date, and days overdue.
*/

--solution --
--1.issued status == members == books == return status  (join all this)
-- after join filter books which is to return
-- overdue > 30 (using command SELECT CURRENT_DATE )

SELECT 
ist.issued_member_id,
m.member_name,
b.book_title,
ist.issued_date,
--rs.return_date, 
CURRENT_DATE - ist.issued_date as over_dues_days

FROM issued_status as ist
JOIN
members as m ON m.member_id = ist.issued_member_id
JOIN
books as b ON b.isbn = ist.issued_book_isbn 
LEFT JOIN 
return_status as rs ON rs.issued_id = ist.issued_id

WHERE rs.return_date IS NULL AND (CURRENT_DATE - ist.issued_date )> 30
order by 1;



/*
Task 2-  Update Book Status on Return
Write a query to update the status of books in the books table to "available" when they are returned 
(based on entries in the return_status table).
*/

-- solution--
-- 

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-553-29698-2';

SELECT * FROM books
WHERE isbn = '978-0-553-29698-2';

UPDATE books
SET status = 'No'
WHERE isbn = '978-0-553-29698-2';


SELECT * FROM return_status
WHERE issued_id = 'IS151';

INSERT INTO return_status(return_id, issued_id,return_date,book_quality)
VALUES
('RS125','IS151',CURRENT_DATE,'Good');

UPDATE books
SET status = 'Yes'
WHERE isbn = '978-0-553-29698-2';



--this above code is the logic but it is not in arranges correctly , so write this code to run evrytime in loop

-- to run this loop everytime , we have to create a function and in that we have to write the logic 
 -- so we had to use the store procedure concept to this question
 -- problem explain- if someone want to take the book we have to see that first
        -- and if it is present then we will give and other person want the same book ,
		-- so we know that the book is not there , so we have to update it to No and when he returns the 
		-- book we have to update again in the status of book to YES.


-- store procedures

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10),p_issued_id VARCHAR(10),p_book_quality VARCHAR(15) ) 
LANGUAGE plpgsql AS $$


DECLARE 

v_isbn VARCHAR(50);
v_book_name VARCHAR(80);


BEGIN
     --logic and code we should mention in this block
	 -- inserting into returnd based on users input 
	INSERT INTO return_status(return_id, issued_id,return_date,book_quality)
	VALUES
	(p_return_id,p_issued_id,CURRENT_DATE,p_book_quality);


	SELECT
	issued_book_isbn,
	issued_book_name
	INTO 
	v_isbn,
	v_book_name
	FROM issued_status 
	WHERE issued_id = p_issued_id;
	
	UPDATE books
	SET status = 'Yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank You for Returning The book: %',v_book_name;

END;
$$


-- this is for conformation or testing before running the function to clarify ourselves
SELECT * FROM issued_status
WHERE issued_id = 'IS135';

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM return_status

DELETE FROM return_status
WHERE issued_id = 'IS135';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';


SELECT * FROM return_status
WHERE issued_id = '978-0-307-58837-1';

---
-- call the function now 

CALL add_return_records('RS130','IS121','Good');


/*
Task 3: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned,
and the total revenue generated from book rentals.

*/

-- solution -- joins


SELECT 
b.branch_id,
b.manager_id,
COUNT(ist.issued_id) as number_of_issued,
COUNT(rs.return_id) as number_of_book_return,
SUM(bk.rental_price) as total_revenue

FROM issued_status as ist
JOIN 
employees as e ON e.emp_id = ist.issued_emp_id
JOIN 
branch as b ON e.branch_id = b.branch_id
LEFT JOIN 
return_status as rs ON rs.issued_id = ist.issued_id
JOIN
books as bk ON ist.issued_book_isbn = bk.isbn
GROUP BY 1,2;




/*
Task 4: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members
who have issued at least one book in the last 6 months.
*/


CREATE TABLE active_members 
AS
SELECT * FROM members 
WHERE member_id IN(
SELECT  issued_member_id 
FROM issued_status
WHERE issued_date > CURRENT_DATE - INTERVAL '2 month');


SELECT * FROM active_members;


/*
Task 17: Find Employees with the Most Book Issues Processed

Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch.

*/

SELECT 
	e.emp_name,
	b.*,
	COUNT(ist.issued_id) as number_of_books_issued


	FROM issued_status AS ist
	JOIN
	employees as e ON e.emp_id = ist.issued_emp_id
	JOIN 
	branch as b ON e.branch_id = b.branch_id

GROUP BY 1,2;





