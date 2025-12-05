create database ECOMMERCE;

USE ECOMMERCE;

---USER TABLE
CREATE TABLE USERS(
    UserID INT PRIMARY KEY,
	Name NVARCHAR(100),
	Email NVARCHAR(100),
	JOINDATE DATE 
);

---PRODUCTS TABLE
CREATE TABLE PRODUCTS(
    ProductID INT PRIMARY KEY,
	ProductName NVARCHAR(100),
	Category NVARCHAR(50),
	Price DECIMAL(10,2),
	Stock INT
);

---ORDERS TABLE 
CREATE TABLE ORDERS(
    OrderID INT PRIMARY KEY,
	UserID INT,
	OrderDate DATE,
	TotalAmount DECIMAL(10,2),
	FOREIGN KEY (UserID) REFERENCES USERS(UserID)
);

---ORDERDETAILS
CREATE TABLE ORDERDETAILS(
    OrderDetailsID INT PRIMARY KEY,
	OrderID INT,
	ProductID INT,
	Quantity INT,
	SubTotal DECIMAL(10,2),
	FOREIGN KEY (OrderID) REFERENCES ORDERS (OrderID),
	FOREIGN KEY (ProductID) REFERENCES PRODUCTS (ProductID),

);


---PRODUCT RECOMENDATION
CREATE TABLE PRODUCTRECOMENDATIONS(
    RecomendationID INT PRIMARY KEY,
	UserID INT, 
	ProductID INT, 
	RecomendationDate DATE,
	FOREIGN KEY (UserID) REFERENCES USERS (UserID),
	FOREIGN KEY (ProductID) REFERENCES PRODUCTS (ProductID),
);


---RECOMENDATIONAUDIT
CREATE TABLE RECOMENDATIONAUDIT(
    AuditID INT PRIMARY KEY,
	UserID INT,
	ProductID INT,
	RecomendedDate DATE,
	AuditDate DATETIME,
	FOREIGN KEY (UserID) REFERENCES USERS (UserID),
	FOREIGN KEY (ProductID) REFERENCES PRODUCTS (ProductID),
);


-- USER DATA
INSERT INTO Users (UserID, Name, Email, JoinDate) VALUES
(1, 'Alice', 'alice@example.com', '2024-01-15'),
(2, 'Bob', 'bob@example.com', '2024-03-22'),
(3, 'Charlie', 'charlie@example.com', '2024-05-10'),
(4, 'Diana', 'diana@example.com', '2024-06-01'),
(5, 'Eve', 'eve@example.com', '2024-07-12'),
(6, 'Frank', 'frank@example.com', '2024-08-15'),
(7, 'Grace', 'grace@example.com', '2024-09-10'),
(8, 'Hank', 'hank@example.com', '2024-10-01'),
(9, 'Ivy', 'ivy@example.com', '2024-11-05'),
(10, 'Jack', 'jack@example.com', '2024-12-01');


-- PRODUCTS DATA
INSERT INTO Products (ProductID, ProductName, Category, Price, Stock) VALUES
(101, 'Laptop', 'Electronics', 700.00, 50),
(102, 'Headphones', 'Electronics', 50.00, 200),
(103, 'Coffee Maker', 'Appliances', 80.00, 75),
(104, 'Smartphone', 'Electronics', 500.00, 120),
(105, 'Blender', 'Appliances', 60.00, 90),
(106, 'Tablet', 'Electronics', 300.00, 100),
(107, 'Microwave', 'Appliances', 150.00, 40),
(108, 'Gaming Console', 'Electronics', 400.00, 30),
(109, 'Vacuum Cleaner', 'Appliances', 120.00, 60),
(110, 'Smartwatch', 'Electronics', 200.00, 150);

-- ORDERS DATA
INSERT INTO Orders (OrderID, UserID, OrderDate, TotalAmount) VALUES
(1, 1, '2024-06-10', 750.00),
(2, 2, '2024-07-05', 80.00),
(3, 3, '2024-07-15', 900.00),
(4, 4, '2024-08-01', 120.00),
(5, 5, '2024-08-20', 650.00),
(6, 6, '2024-09-05', 400.00),
(7, 7, '2024-09-25', 150.00),
(8, 8, '2024-10-10', 1000.00),
(9, 9, '2024-10-25', 200.00),
(10, 10, '2024-11-10', 750.00);

-- ORDER DETAILS DATA
INSERT INTO OrderDetails (OrderDetailsID, OrderID, ProductID, Quantity, Subtotal) VALUES
(1, 1, 101, 1, 700.00),
(2, 1, 102, 1, 50.00),
(3, 2, 103, 1, 80.00),
(4, 3, 104, 1, 500.00),
(5, 3, 106, 2, 400.00),
(6, 4, 105, 2, 120.00),
(7, 5, 108, 1, 400.00),
(8, 5, 109, 2, 240.00),
(9, 6, 102, 8, 400.00),
(10, 7, 110, 1, 150.00);

-- PRODUCT RECOMMENDATION DATA
INSERT INTO ProductRecomendations (RecomendationID, UserID, ProductID, RecomendationDate) VALUES
(1, 1, 103, '2024-06-12'),
(2, 1, 104, '2024-06-15'),
(3, 2, 105, '2024-07-07'),
(4, 2, 106, '2024-07-09'),
(5, 3, 107, '2024-07-17'),
(6, 4, 108, '2024-08-05'),
(7, 5, 109, '2024-08-22'),
(8, 6, 110, '2024-09-07'),
(9, 7, 101, '2024-09-27'),
(10, 8, 102, '2024-10-12');


-- 1. Fetch all orders placed by users who joined before March 2024.
SELECT O.OrderID , O.UserID , O.OrderDate , O.TotalAmount
FROM ORDERS O
INNER JOIN USERS U
ON O.UserID = U.UserID
WHERE JOINDATE < '2024-03-01';

-- 2. List all products under the "Electronics" category with price greater than $100.
SELECT *
FROM PRODUCTS 
WHERE CATEGORY = 'ELECTRONICS' 
AND Price > 100;


-- ## FUNCTIONS ## -- 

-- 1. Scalar function to calculate total revenue from all orders.
CREATE FUNCTION GetTotalRevenue()
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalRevenue DECIMAL(10,2)
	SELECT @TotalRevenue = SUM(TotalAmount)	from ORDERS;
	return @TotalRevenue;
END;

SELECT dbo.GetTotalRevenue () AS TotalRevenue;


-- 2. Function to return total products purchased by a specific user.

CREATE FUNCTION GetTotalProductsPurchased(@UserID INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalProducts INT 
    SELECT @TotalProducts = SUM(Quantity)
    FROM Orders O 
    INNER JOIN OrderDetails OD 
    ON O.OrderID = OD.OrderID
    WHERE UserID = @UserID ;
    RETURN @TotalProducts;
END;

SELECT dbo.GetTotalProductsPurchased(1) AS TotalProductsPurchased;


---##TRANSACTIONS##---
-- 1. Transaction to place an order ensuring consistency.

BEGIN TRANSACTION ;

BEGIN TRY
-----insert into orders
    INSERT INTO ORDERS
	VALUES (11 , 3 , '2024-12-01' , 750);
-----insert into orderdetails
   INSERT INTO ORDERDETAILS
   VALUES (11 , 11, 101, 1, 700);
-----update products
    UPDATE PRODUCTS
	SET Stock = Stock - 1
	WHERE ProductID = 101;

	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
	THROW;
END CATCH;


---##STORED PROCEDURE##---
-- 1. Stored procedure to add a new user and recommend a random product.

CREATE PROCEDURE AddUserAndRecommendProduct
	@UserID INT,
	@Name NVARCHAR(100),
	@Email NVARCHAR(100),
	@JoinDate DATE
AS
BEGIN
---check userid is already available int the table
	IF EXISTS (SELECT 1 FROM USERS WHERE UserID = @UserID)
	BEGIN
		PRINT 'ERROR : UserID already exists';
		RETURN; 
	END;
	DECLARE @ProductID INT;
	DECLARE @RecomendationID INT;

----generate the next recomendationID
	SELECT @RecomendationID = ISNULL(MAX(RecomendationID), 0) + 1 FROM PRODUCTRECOMENDATIONS

----insert new user
	INSERT INTO USERS
	VALUES (@UserID , @Name , @Email, @JoinDate);

---recomend a random product
	SELECT TOP 1 @ProductID = @ProductID FROM PRODUCTS ORDER BY NEWID();

---insert the recommendation with the generated id 
	INSERT INTO PRODUCTRECOMENDATIONS
	VALUES(@RecomendationID , @UserID , @ProductID, GETDATE());
	
	PRINT 'User and recomendation is added successfully'

END;

-- Adding user with ID 401
EXEC AddUserAndRecommendProduct
    @UserID = 401,
    @Name = 'David Clark',
    @Email = 'david.clark@example.com',
    @JoinDate = '2024-12-06';

-- Adding user with ID 402
EXEC AddUserAndRecommendProduct
    @UserID = 402,
    @Name = 'Emma Taylor',
    @Email = 'emma.taylor@example.com',
    @JoinDate = '2024-12-07';

-- Verifying the results

-- User Table
SELECT * FROM Users WHERE UserID IN (401, 402);

-- ProductRecommendation Table
SELECT * FROM ProductRecomendations WHERE UserID IN (401, 402);



-- ## Analytical Questions ## --

-- 1. Fetch the total revenue grouped by product categories with max to min.

SELECT Category , SUM(SubTotal) AS TotalRevenue
FROM ORDERDETAILS OD
INNER JOIN PRODUCTS P 
ON OD.OrderDetailsID = P.ProductID
GROUP BY Category
ORDER BY 2 DESC ;

-- 2. Identify the top 2 user Name, ID, total with the highest spending.

SELECT TOP 2 U.UserID , U.Name , SUM(TotalAmount) AS 'TotalAmount'
FROM USERS U
INNER JOIN ORDERS O
ON U.UserID = O.UserID
GROUP BY U.UserID , U.Name
ORDER BY SUM(TotalAmount) DESC;


-- 3. Suggest products not yet purchased by a specific user.
CREATE FUNCTION GetProductsNotOrdered(@UserID INT)
RETURNS TABLE
AS
RETURN
(
SELECT ProductID , ProductName , Category
FROM PRODUCTS
WHERE ProductID NOT IN (
		SELECT ProductID 
		FROM ORDERS O
		INNER JOIN ORDERDETAILS OD
		ON O.OrderID = OD.OrderID
		WHERE O.UserID = @UserID
)
);

SELECT * FROM dbo.GetProductsNotOrdered(5);

