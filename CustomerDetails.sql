USE CRM_Anlaysis;

SHOW TABLES;

SELECT *
FROM customerdetails;

-- 1.What is the distribution of account balances across different regions?

SELECT Geography_location,ROUND(SUM(Balance),2) AS account_balances
FROM customerdetails
GROUP BY Geography_location
ORDER BY account_balances DESC;


-- 2.	Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)

SELECT surname AS customers,ROUND(SUM(EstimatedSalary),2) AS `Highest Estimated Salary`
FROM customerdetails
WHERE  MONTH(JoiningDate) IN (10,11,12)
GROUP BY customers
ORDER BY `Highest Estimated Salary` DESC
LIMIT 5;
	
-- 3.	Calculate the average number of products used by customers who have a credit card. (SQL)

SELECT surname AS Customers,AVG(NumOfProducts) AS `Average Number of Products`
FROM customerdetails
WHERE HasCrCard=1
GROUP BY surname;

-- 4.	Determine the churn rate by gender for the most recent year in the dataset.

WITH CTE AS(
	SELECT Gender,COUNT(customerId) AS `Churn`
	FROM customerdetails
	WHERE Exited=1 AND YEAR(JoiningDate)=(SELECT MAX(YEAR(JoiningDate))
											FROM customerdetails)
	GROUP BY Gender
),totalCTE AS
(
	SELECT Gender,COUNT(*) AS `total`
	FROM customerdetails
    GROUP BY Gender
)
SELECT a.Gender,ROUND(churn/total,2)*100 AS `churn rate`
FROM CTE a
JOIN totalCTE b
ON a.Gender=b.Gender
GROUP BY a.Gender;

-- 5.	Compare the average credit score of customers who have exited and those who remain. (SQL)

SELECT Churn_status,ROUND(AVG(CreditScore),2) AS `Average Credit Score`
FROM customerdetails
GROUP BY Churn_status;

-- 6.	Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)

SELECT Gender,
ROUND(AVG(EstimatedSalary),2) AS `Highest Average Estimated Salary`,
COUNT(customerId) AS`Count of Active Member`
FROM customerdetails
WHERE IsActiveMember=1
GROUP BY Gender,IsActiveMember
ORDER BY `Highest Average Estimated Salary` DESC 
LIMIT 1;

-- 7.	Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)

SELECT CASE WHEN CreditScore BETWEEN 350 AND 450 THEN '350-450'
WHEN CreditScore BETWEEN 450 AND 550 THEN '450-550'
WHEN CreditScore BETWEEN 550 AND 650 THEN '550-650'
WHEN CreditScore BETWEEN 650 AND 750 THEN '650-750'
ELSE '750-850' END AS CreditScoreRange,
COUNT(customerId) AS customers
FROM customerdetails
WHERE Exited=1
GROUP BY CreditScoreRange
ORDER BY customers DESC;

-- 8.	Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)

SELECT Geography_location,COUNT(CustomerId) AS `Active Customers`
FROM customerdetails
WHERE IsActiveMember=1 AND tenure>5
GROUP BY Geography_location
ORDER BY `Active Customers` DESC
LIMIT 1;

-- 9.	What is the impact of having a credit card on customer churn, based on the available data?

SELECT CreditCard_Status,COUNT(customerId) AS `Customer Churn`
FROM customerdetails
WHERE Exited=1 AND CreditCard_Status='Credit Card Holder'
GROUP BY CreditCard_Status;

-- 10.	For customers who have exited, what is the most common number of products they have used?

SELECT NumOfProducts,COUNT(customerId) AS customers
FROM customerdetails
WHERE Exited=1
GROUP BY NumOfProducts
ORDER BY customers DESC 
LIMIT 1;

--  11.	Examine the trend of customer exits over time and identify any seasonal patterns (yearly or monthly).
--  Prepare the data through SQL and then visualize it.

SELECT YEAR(JoiningDate) AS Years,COUNT(CustomerId) AS CustomersCount
FROM customerdetails
WHERE Exited=1
GROUP BY Years
ORDER BY CustomersCount DESC;

-- 12.	Analyze the relationship between the number of products and the account balance for customers who have exited.

SELECT NumOfProducts,ROUND(AVG(Balance),2) AS `Account Balance`
FROM customerdetails
WHERE Exited=1
GROUP BY NumOfProducts
ORDER BY `Account Balance` DESC;


-- 15.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id.
--  Also, rank the gender according to the average value. (SQL)

WITH CTE AS(
	SELECT Gender,Geography_location,ROUND(AVG(EstimatedSalary),2) AS average_value
	FROM customerdetails
	GROUP BY Gender,Geography_location
)
SELECT DENSE_RANK() OVER(ORDER BY average_value DESC) AS Ranks ,Gender,Geography_location,average_value
FROM CTE;

-- 16.	Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

SELECT AgeBracket,AVG(Tenure) AS `Average Tenure`
FROM customerdetails
WHERE Exited=1
GROUP BY AgeBracket
ORDER BY AgeBracket;

-- 19.	Rank each bucket of credit score as per the number of customers who have churned the bank.

WITH CTE AS(
	SELECT CASE WHEN CreditScore BETWEEN 350 AND 450 THEN '350-450'
	WHEN CreditScore BETWEEN 450 AND 550 THEN '450-550'
	WHEN CreditScore BETWEEN 550 AND 650 THEN '550-650'
	WHEN CreditScore BETWEEN 650 AND 750 THEN '650-750'
	ELSE '750-850' END AS CreditScoreRange,
	COUNT(customerId) AS `No.of.Customers`
	FROM customerdetails
	WHERE Exited=1
	GROUP BY CreditScoreRange
	ORDER BY `No.of.Customers` DESC
)
SELECT DENSE_RANK() OVER(ORDER BY `No.of.Customers` DESC) AS Ranks,
CreditScoreRange,`No.of.Customers`
FROM CTE;

-- 20.	According to the age buckets find the number of customers who have a credit card. 
-- Also, retrieve those buckets that have a lesser than average number of credit cards per bucket.

SELECT AgeBracket,COUNT(HasCrCard) AS `number of customers`
FROM customerdetails
WHERE HasCrCard=1 
GROUP BY AgeBracket
HAVING `number of customers`<(SELECT AVG(tc) AS avrg
							FROM (SELECT COUNT(customerId) AS tc
								FROM customerDetails
                                WHERE HasCrCard=1)a) ;
                                
-- 21.	Rank the Locations as per the number of people who have churned the bank and the average balance of the learners.

WITH CTE AS(
	SELECT Geography_location,COUNT(customerId) AS `number of people`,ROUND(AVG(balance),2) AS `average balance`
	FROM customerdetails
	WHERE Exited=1
	GROUP BY Geography_location
)
SELECT DENSE_RANK() OVER(ORDER BY `number of people`DESC,`average balance` DESC) AS Ranks,
Geography_location,`number of people`,`average balance`
FROM CTE


