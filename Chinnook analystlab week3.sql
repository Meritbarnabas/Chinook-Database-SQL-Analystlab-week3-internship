Select * from album;
Select * from artist;
Select * from customer;
Select * from employee;
Select * from genre;
Select * from invoice;
Select * from invoiceline;
Select * from mediatype;
Select * from playlist;
Select * from playlisttrack;
Select * from track;
---replace null value
UPDATE Track
SET Composer = 'Unknown Composer'
WHERE Composer IS NULL;
UPDATE Customer
SET Company = 'Not Provided'
WHERE Company IS NULL;
UPDATE Customer
SET State = 'Unknown'
WHERE State IS NULL;
UPDATE Invoice
SET BillingState = 'Unknown'
WHERE BillingState IS NULL;
UPDATE Invoice
SET BillingPostalCode = '00000'
WHERE BillingPostalCode IS NULL;
UPDATE Customer
SET PostalCode = '00000'
WHERE PostalCode IS NULL;
ALTER TABLE Employee
ALTER COLUMN BirthDate DATE;

ALTER TABLE Employee
ALTER COLUMN HireDate DATE;

ALTER TABLE Invoice
ALTER COLUMN InvoiceDate DATE;

-- CHINOOK DATABASE SQL ANALYSIS
-- AnalystLab Africa - Week 3

-- 1. Display all customers
SELECT *
FROM Customer;
-- 2. Customers from USA
SELECT FirstName, LastName, Country
FROM Customer
WHERE Country = 'USA';
-- 3. Customers ordered by Last Name
SELECT FirstName, LastName
FROM Customer
ORDER BY LastName;
-- AGGREGATE FUNCTIONS
-- ==========================================

-- Total number of customers
SELECT COUNT(*) AS TotalCustomers
FROM Customer;

-- Total revenue generated
SELECT SUM(Total) AS TotalRevenue
FROM Invoice;

-- Average invoice value
SELECT AVG(Total) AS AverageInvoice
FROM Invoice;

-- Revenue by country
SELECT BillingCountry,
SUM(Total) AS Revenue
FROM Invoice
GROUP BY BillingCountry
ORDER BY Revenue DESC;

-- Countries with revenue above $100
SELECT BillingCountry,
SUM(Total) AS Revenue
FROM Invoice
GROUP BY BillingCountry
HAVING SUM(Total) > 100;

-- ==========================================
-- JOINS
-- ==========================================

-- Customer purchases
SELECT c.FirstName,
c.LastName,
i.InvoiceId,
i.InvoiceDate,
i.Total
FROM Customer c
INNER JOIN Invoice i
ON c.CustomerId = i.CustomerId;

-- Invoice details with track names
SELECT i.InvoiceId,
t.Name AS TrackName,
il.UnitPrice,
il.Quantity
FROM InvoiceLine il
INNER JOIN Invoice i
ON il.InvoiceId = i.InvoiceId
INNER JOIN Track t
ON il.TrackId = t.TrackId;

-- Track and album information
SELECT t.Name AS TrackName,
a.Title AS AlbumName
FROM Track t
INNER JOIN Album a
ON t.AlbumId = a.AlbumId;

-- ==========================================
-- BUSINESS QUESTIONS
-- ==========================================

-- Top 10 customers by revenue
SELECT TOP 10
c.CustomerId,
c.FirstName,
c.LastName,
SUM(i.Total) AS Revenue
FROM Customer c
INNER JOIN Invoice i
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId,
c.FirstName,
c.LastName
ORDER BY Revenue DESC;

-- Top selling tracks
SELECT TOP 10
t.Name,
SUM(il.Quantity) AS UnitsSold
FROM InvoiceLine il
INNER JOIN Track t
ON il.TrackId = t.TrackId
GROUP BY t.Name
ORDER BY UnitsSold DESC;

-- Top genres by sales
SELECT g.Name AS Genre,
SUM(il.Quantity) AS UnitsSold
FROM InvoiceLine il
INNER JOIN Track t
ON il.TrackId = t.TrackId
INNER JOIN Genre g
ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY UnitsSold DESC;

-- Monthly revenue trend
SELECT YEAR(InvoiceDate) AS SalesYear,
MONTH(InvoiceDate) AS SalesMonth,
SUM(Total) AS Revenue
FROM Invoice
GROUP BY YEAR(InvoiceDate),
MONTH(InvoiceDate)
ORDER BY SalesYear, SalesMonth;

-- ==========================================
-- SUBQUERIES
-- ==========================================

-- Customers spending above average
SELECT CustomerId,
FirstName,
LastName
FROM Customer
WHERE CustomerId IN
(
SELECT CustomerId
FROM Invoice
GROUP BY CustomerId
HAVING SUM(Total) >
(
SELECT AVG(Total)
FROM Invoice
)
);
-- WINDOW FUNCTIONS
-- ==========================================

-- Rank customers by revenue
SELECT c.CustomerId,
c.FirstName,
c.LastName,
SUM(i.Total) AS Revenue,
RANK() OVER
(
ORDER BY SUM(i.Total) DESC
) AS RevenueRank
FROM Customer c
INNER JOIN Invoice i
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId,
c.FirstName,
c.LastName;

-- Row number for invoices
SELECT InvoiceId,
CustomerId,
Total,
ROW_NUMBER() OVER
(
ORDER BY Total DESC
) AS RowNum
FROM Invoice;

-- Revenue by customer partition
SELECT CustomerId,
InvoiceId,
Total,
SUM(Total) OVER
(
PARTITION BY CustomerId
) AS CustomerRevenue
FROM Invoice;

-- ==========================================
-- QUERY OPTIMIZATION
-- ==========================================

CREATE INDEX IX_Invoice_CustomerId
ON Invoice(CustomerId);

CREATE INDEX IX_InvoiceLine_TrackId
ON InvoiceLine(TrackId);
