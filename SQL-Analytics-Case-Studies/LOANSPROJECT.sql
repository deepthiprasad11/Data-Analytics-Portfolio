CREATE DATABASE LOANSPROJECT;
USE LOANSPROJECT;
SELECT * FROM LOANS;


----check data consistency ( TO CHECK WHETHER ALL THE  DATA IN THE REPECTIVE ROWS AND COLUMNS OF THE TABLE IS CRT) 
SELECT TOP 10 * FROM Loans
SELECT Column_Name , Data_Type
FROM INFORMATION_SCHEMA.columns
WHERE Table_Name = 'LOANS';


--1. CHECK THE DATA . IF ANY MODIFICATION REQUIRED.
--Funded_amt - BIG INT
ALTER TABLE LOANS
ALTER COLUMN funded_amount  BIGINT ;

--funded_date - DATE
ALTER TABLE LOANS
ALTER COLUMN funded_date  DATE ;

--durationyrs - INT
ALTER TABLE LOANS
ALTER COLUMN [duration years] INT ; 

--duration months - INT
ALTER TABLE LOANS
ALTER COLUMN [duration months] INT;

--10yrindex - FLOAT
ALTER TABLE LOANS
ALTER COLUMN [10 yr treasury index date funded] FLOAT;

--intratprcnt - FLOAT
ALTER TABLE LOANS 
ALTER COLUMN [interest rate percent] FLOAT;

--int rate - FLOAT
ALTER TABLE LOANS
ALTER COLUMN [interest rate] FLOAT;

--payments - MONEY
ALTER TABLE LOANS 
ALTER COLUMN payments MONEY;
 
--totalpastpayments - INT
ALTER TABLE LOANS 
ALTER COLUMN [total past payments] INT;

--loanbalance - MONEY
ALTER TABLE LOANS 
ALTER COLUMN [loan balance] MONEY;

--propertyvalue - BIG INT
ALTER TABLE LOANS 
ALTER COLUMN [property value] BIGINT;
 
--emplenght - INT
ALTER TABLE LOANS 
ALTER COLUMN [employment length] INT;

--totalunits - INT
ALTER TABLE LOANS 
ALTER COLUMN [TOTAL UNITS] INT;

--lansqfeet - INT
ALTER TABLE LOANS 
ALTER COLUMN [LAND SQUARE FEET] INT;

--grosssqfeet - INT
ALTER TABLE LOANS 
ALTER COLUMN [GROSS SQUARE FEET] INT;
 
-- Purpose
--Building class category
--- Years (2012-2019)
--durations - 15,30,10,20

---CHECK DATA DISTRIBUTION AS PER THE CATEGORIES ABOVE

---###PURPOSE###
SELECT purpose , COUNT(loan_id) AS 'TOATL_LOAN' , SUM(funded_amount) AS 'TOATL_LOAN_AMT' 
FROM Loans
GROUP BY purpose; 


---###--YEAR WISE DISTRIBUTION ###
SELECT YEAR(funded_date) AS 'THE_YEAR' ,purpose, COUNT(loan_id) AS 'NUM_OF_LOANS',
SUM (funded_amount) AS 'T_F_AMT' , MIN(funded_amount) AS 'MIN_F_AMT' , MAX(funded_amount) AS 'MAX_F_AMT'
FROM Loans
GROUP BY  YEAR(funded_date) , purpose
ORDER BY SUM (funded_amount) DESC;

---###BUILDING CLASS CATEGORY###---
SELECT DISTINCT [BUILDING CLASS CATEGORY] FROM LOANS;

---after inspecting this category , we have found that it includes sub categories as well
---so we will create one more attribute / new column - New_Building_class_Category.
---CONDOS , RENTAL , RESIDENTIAL , COMMERCIAL , OTHERS 

ALTER TABLE LOANS
ADD  New_Building_class_Category VARCHAR(50);


SELECT [BUILDING CLASS CATEGORY] , 
	CASE 
		WHEN [BUILDING CLASS CATEGORY] LIKE '%condo%' THEN 'Condos'
		WHEN [BUILDING CLASS CATEGORY] LIKE '%Rental%' THEN 'Rental'
		WHEN [BUILDING CLASS CATEGORY] LIKE '%family%' THEN 'Residential'
		WHEN [BUILDING CLASS CATEGORY] LIKE '%Commercial%' THEN 'Commercial'
		ELSE 'OTHERS' 
		END AS New_Building_class_Category
FROM Loans;

UPDATE LOANS 
SET New_Building_class_Category =
	CASE 
		WHEN [BUILDING CLASS CATEGORY] LIKE '%condo%' THEN 'Condos'
		WHEN [BUILDING CLASS CATEGORY] LIKE '%Rental%' THEN 'Rental'
		WHEN [BUILDING CLASS CATEGORY] LIKE '%family%' THEN 'Residential'
		WHEN [BUILDING CLASS CATEGORY] LIKE '%Commercial%' THEN 'Commercial'
		ELSE 'OTHERS' 
	END;

SELECT DISTINCT New_Building_class_Category FROM Loans;

----now checking the distributin of the new category--

SELECT New_Building_class_Category ,purpose, COUNT(loan_id) AS 'Num_of_loans' , SUM (funded_amount) AS 'Toatal_Amt'
FROM LOANS 
GROUP BY New_Building_class_Category , purpose
ORDER BY CASE 
		WHEN New_Building_class_Category LIKE '%condo%' THEN 1
		WHEN New_Building_class_Category LIKE '%Rental%' THEN 2
		WHEN New_Building_class_Category LIKE '%family%' THEN 3
		WHEN New_Building_class_Category LIKE '%Commercial%' THEN 4
		ELSE 5 
	END; 



----WE NEED TO ANALYSE THE FUNDED BALANCE OVER THE TIME---
---(how much we hav recovered , how much is there yet to be recovered , which particular loan is healthy and which loan might hv risk)

SELECT funded_date , [duration years] ,[total past payments], funded_amount , [loan balance] ,  (funded_amount -[loan balance]) AS 'Recovered_amt',
 (funded_amount -[loan balance]) / funded_amount * 100 AS '%_Recovered'
FROM LOANS
ORDER BY '%_Recovered';

SELECT MAX(funded_date) FROM Loans; --'2019-12-27'---
SELECT MIN(funded_date) FROM Loans; --'2012-01-01'---

SELECT DATEDIFF(MONTH , '2013-11-07' , MAX(funded_date)) FROM Loans;

--how many loans are there where Total_past_payments are not exact num of months as per the maxdate in the data
SELECT FORMAT(funded_date , 'MMM') AS 'Formatted_date' , FORMAT(funded_date , 'MMM YYYY') AS 'The_year',
 [duration years] ,[total past payments], funded_amount , [loan balance] ,  (funded_amount -[loan balance]) AS 'Recovered_amt',
 (funded_amount -[loan balance]) / funded_amount * 100 AS '%_Recovered'
FROM Loans
ORDER BY 'Formatted_date' , 'The_year';

---ANALYSE THE TREND OF LOANBALANCE---

WITH Trend_in_bal AS (
	SELECT funded_date , [loan balance] FROM Loans
),
 MONTHLY_BAL AS (
	SELECT
		 DATEPART(YEAR, funded_date ) AS 'TYEAR' ,
	     DATEPART(MONTH, funded_date ) AS 'TMONTH',
	     SUM([loan balance]) AS 'Total_Fun_Amt'
	 FROM LOANS
	 GROUP BY DATEPART(YEAR, funded_date ),DATEPART(MONTH, funded_date )
)
SELECT TYEAR , TMONTH , Total_Fun_Amt
FROM MONTHLY_BAL
ORDER BY TYEAR , TMONTH;

----INT RATE FLUCTUATION OVER THE PERIOD OF TIME----
WITH INT_RATE_TREND AS (
		SELECT funded_date , [interest rate percent] , 
		ROW_NUMBER() OVER (ORDER BY funded_date) AS 'ROW_NUM'
		FROM Loans
),

MONTHLY_TREND_RATE AS (
	SELECT
		YEAR(funded_date) AS 'Year', MONTH(funded_date) AS 'MONTH',
		AVG([interest rate percent]) AS 'Avg_int_rate'
	FROM INT_RATE_TREND
	GROUP BY YEAR(funded_date), MONTH(funded_date)
)

SELECT Year , MONTH , Avg_int_rate
FROM MONTHLY_TREND_RATE
ORDER BY Year , MONTH;


SELECT DISTINCT [interest rate percent] FROM Loans;

---INTEREST RATE SEGMENT---

SELECT [interest rate percent],
	CASE 
		WHEN [interest rate percent] < 3.0 THEN 3.0
		WHEN [interest rate percent] BETWEEN 3 AND 3.999 THEN 4.0
		ELSE 5.0 
		END
	AS 'INT_SEGMENT'
FROM Loans;

ALTER TABLE LOANS
ADD INT_RATE_SEG VARCHAR(10)

UPDATE Loans 
SET INT_RATE_SEG = 
	CASE
		WHEN [interest rate percent] < 3.0 THEN 3.0
		WHEN [interest rate percent] BETWEEN 3 AND 3.999 THEN 4.0
		ELSE 5.0 
		END;

SELECT Purpose, COUNT(loan_id) AS 'Numofloan' ,
	SUM (CASE WHEN INT_RATE_SEG = '3.0' THEN funded_amount END) AS 'SEG3.0AMT' ,
	SUM (CASE WHEN INT_RATE_SEG = '4.0' THEN funded_amount END) AS 'SEG4.0AMT' , 
	SUM (CASE WHEN INT_RATE_SEG = '5.0' THEN funded_amount END) AS 'SEG5.0AMT' 
FROM Loans
GROUP BY purpose
ORDER BY Numofloan;

---we need to see the fluctuation in int_rate_ over the time for all purposes---
SELECT MAX(funded_amount), MIN(funded_amount) FROM loans
WHERE INT_RATE_SEG='5.0'

--- range of funded_amount in this int_segment
--12500000  max,  640000 min
--3.0
--10508000 max, 444000 min
--4.0
--156000000 max, 440000 min
--5.0--

select Distinct Purpose from Loans
/* boat
commerical property
home
investment property
plane*/

-- the banking institution needs to know about the evaluation of loans against properties
--- it is imp because in case of any defaulter the bank can realised their funded amount against the property

-- analysing the property value

SELECT MAX([property value]) , AVG([property value]) , MIN([property value])
FROM Loans;

-- create property_value segment
--low_seg, high_seg, mid_val_seg

---below 1000000 is low_val_seg
---between 1000000 and 2000000 mid_val_Seg
---more than 2000000 is high seg
		

SELECT [property value] , purpose , loan_id, funded_amount , COUNT(loan_id) AS 'Total_loans', 
	CASE	
		WHEN [property value] < 1000000 THEN 'Low_Seg'
		WHEN [property value] BETWEEN 1000000 AND 2000000 THEN 'Mid_Seg'
		ELSE 'High_Seg'
		END 
	AS 'Property_val_seg'
FROM LOANS
WHERE funded_amount > [property value]
GROUP BY  [property value] , purpose , loan_id, funded_amount , Property_val_seg;
 
/* AS PER THE DATA WE DONT HV ANY LOAN WHERE FUNDED AMT > PROPERTY VALUE*/

WITH Risk_Factors AS(
	SELECT 
		 [employment length] , New_Building_class_Category , [loan balance] , [total past payments] ,(funded_amount - [loan balance]) AS 'Overdue'
	FROM Loans
)


, Risk_by_category AS(
	SELECT  
		[employment length] , New_Building_class_Category , 
		AVG(Overdue) AS 'Avg_Overdue_Amt' , 
		SUM(Overdue) AS 'T_Overdue_Amt' , 
		COUNT(*) AS Num_of_loans 
	FROM Risk_Factors
	GROUP BY [employment length] , New_Building_class_Category 
)

SELECT [employment length] , New_Building_class_Category , Avg_Overdue_Amt , T_Overdue_Amt 
FROM Risk_by_category
WHERE New_Building_class_Category = 'RENTAL'

----ANALYSING IS THERE ANY PROPERTY VALUE < FUNDED AMOUNT ALSO CREATE PROPERTY SEG BASED ON VALUE DISTRIBUTION

SELECT MAX([property value]) , MIN([property value]) , AVG([property value])
FROM LOANS;

---<1000000 - low_pro_seg
---between 1000000 and 2000000 mid_pro_seg
--->2000000 hig_pro_seg

SELECT purpose , loan_id , funded_amount , [property value] , COUNT(loan_id) AS 'Num_of_loan',
	CASE
		WHEN [property value] < 1000000 THEN 'Low_pro_seg'
		WHEN [property value] BETWEEN 1000000 AND 2000000 THEN 'Mid_pro_seg'
		ELSE 'High_pro_seg'
		END 
	AS 'Pro_seg'
	FROM LOANS
	WHERE funded_amount > [property value]
	GROUP BY purpose , loan_id , funded_amount , [property value] , 
	CASE
		WHEN [property value] < 1000000 THEN 'Low_pro_seg'
		WHEN [property value] BETWEEN 1000000 AND 2000000 THEN 'Mid_pro_seg'
		ELSE 'High_pro_seg'
		END; 
----OUTPUT INDICATES THAT THERE IS NO PROPERTY VALUE IS > FUNDED AMOUNT


  













 





