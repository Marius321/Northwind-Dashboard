# Northwind Sales Dashboard
This repository showcases the SQL data preparation (using SSMS) behind my personal Tableau dashboarding project. The purpose of this project is to demonstrate my SQL and Tableau abilities.

![image](https://user-images.githubusercontent.com/117634180/213013756-b9a379a9-3d38-46dc-aabb-f044ad2f1056.png)
The dashboard is available here: 

Below I outlined the steps involved in the creation of this dashboard.

## STEP 1. Installing the Database
First I installed the SQL Server Management Studio (SSMS) onto my local machine and ran the Northwind database installation scripts locally. The scripts to create and load the database are available [here](https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/northwind-pubs).

## STEP 2. Writing the Scripts
I used the database schema to join the tables together and wrote SQL queries to select and transform the data for my three tables: one for order (called OrdersMain), one for employees (called EmployeesMain) and one for products (called ProductsMain). The scripts are available [here](https://github.com/Marius321/Northwind-Dashboard/blob/main/SQLQuery.sql).

![database_schema](https://user-images.githubusercontent.com/117634180/213016206-473ed04d-696d-4d90-8e18-2be10c2b324c.png)

Certain code snippets are also available at the bottom of this README file.

## STEP 3. Downloading the tables/data model
Downloaded the aforementioned tables in Microsoft Excel (.csv) format and icorporated them into my Tableau Data Model:
![image](https://user-images.githubusercontent.com/117634180/213017815-633e71b3-8a8e-4aae-a3cb-e894efded018.png)

## STEP 4. Creating the dashboards
The last step involved creating a Tableau dashboard. Tableau functionality and features used:
  - Dynamic Parameters
  - Parameter Actions
  - Level of Detail Expressions
  - Navigation Buttons
  - Custom Shapes and Custom Number Formatting
## SQL Code Snippets
Joining tables together and selecting columns across different datasets
```
SELECT 
	t.TerritoryID,
	EmployeeID,
	TerritoryDescription,
	RegionDescription
FROM Territories AS t
	INNER JOIN Region AS r ON t.RegionID=r.RegionID
	INNER JOIN EmployeeTerritories AS e ON t.TerritoryID=e.TerritoryID
```
Aggregating, formatting and applying various functions to transform data
```
SELECT [Orders].OrderID,
	COUNT([Orders].OrderID) AS NumberOfProducts
FROM Orders
INNER JOIN [Order Details] ON [Orders].OrderID=[Order Details].OrderID
GROUP BY [Orders].OrderID
...
[UnitCost]=ROUND(UnitPrice*(0.75 + ROUND( 0.1 *RAND(convert(varbinary, newid())),2)),2);
...
DATEADD(year,24,OrderDate) AS OrderDate,
```
Writing CASE statements
```
CASE Metric WHEN 'Revenue' THEN 1
WHEN 'CostOfGoods' THEN 2
WHEN 'DiscountValue' THEN 3
WHEN 'FreightByProduct' THEN 4
ELSE 999 END AS SortingIndex
```
Writing CTEs
```
WITH number_of_products_cte (OrderID,NumberOfProducts) 
AS
(
SELECT [Orders].OrderID,
	COUNT([Orders].OrderID) AS NumberOfProducts
FROM Orders
INNER JOIN [Order Details] ON [Orders].OrderID=[Order Details].OrderID
GROUP BY [Orders].OrderID
)
```
Changing data structure by unpivoting
```
SELECT * 
	FROM(SELECT OrderID,
		OrderDate,
		-SUM(DiscountValue) AS DiscountValue,
		SUM(Revenue) AS Revenue,
		-SUM(CostOfGoods) AS CostOfGoods,
		-SUM(FreightByProduct) AS FreightByProduct
	FROM OrdersMain 
	GROUP BY OrderID,OrderDate) a
UNPIVOT(Value for Metric IN (a.DiscountValue, Revenue, CostOfGoods, FreightByProduct)) AS b
```
Creating, altering and updating tables
```
CREATE TABLE waterfall_dataset (
	OrderID int,
	OrderDate datetime,
	Metric nvarchar(40),
	Value money,
	SortingIndex smallint)
...
ALTER TABLE [dbo].[Order Details]
ADD UnitCost real;
...
UPDATE [dbo].[Order Details]
SET
[UnitCost]=ROUND(UnitPrice*(0.75 + ROUND( 0.1 *RAND(convert(varbinary, newid())),2)),2);
```
