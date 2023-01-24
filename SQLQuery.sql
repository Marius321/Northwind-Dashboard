/*Adding the Unit Cost column to Order Details table*/
ALTER TABLE [dbo].[Order Details]
ADD UnitCost real;

/*Update the Unit Cost column with random numbers*/
UPDATE [dbo].[Order Details]
SET 
	[UnitCost]=ROUND(UnitPrice*(0.75 + ROUND( 0.1 *RAND(convert(varbinary, newid())),2)),2);

/*Creating an empty table for Orders*/
CREATE TABLE OrdersMain (
	OrderID int,
	CustomerID varchar(255),
	ClientName nvarchar(40),
	EmployeeID int,
	ProductID int,
	UnitPrice money,
	UnitCost money,
	Quantity smallint,
	Discount real,
	DiscountValue money,
	Revenue money,
	CostOfGoods money,
	DiscountedRevenue money,
	Freight money,
	FreightByProduct money,
	OrderDate datetime,
	RequiredDate datetime,
	ShippedDate datetime, 
	ShipName nvarchar(40),
	ShipAddress nvarchar(60),
	ShipCity nvarchar(15),
	ShipRegion nvarchar(15),
	ShipPostalCode nvarchar(10),
	ShipCountry nvarchar(15),
	ShippersName nvarchar(40),
	ClientContact nvarchar(30),
	ContactTitle nvarchar(30),
	ClientAddress nvarchar(60),
	ClientCity nvarchar(15),
	Region nvarchar(15),
	PostalCode nvarchar(10),
	Country nvarchar(15)
);

/* In case you want to delete the above table */
DROP TABLE dbo.OrdersMain;

/* Joining Orders, Order Details and Shippers tables and inserting the results into OrdersMain table*/
WITH number_of_products_cte (OrderID,NumberOfProducts) 
AS
(
SELECT [Orders].OrderID,
	COUNT([Orders].OrderID) AS NumberOfProducts
FROM Orders
INNER JOIN [Order Details] ON [Orders].OrderID=[Order Details].OrderID
GROUP BY [Orders].OrderID
)
INSERT INTO OrdersMain
SELECT
	Orders.OrderID,
	Orders.CustomerID,
	Customers.CompanyName AS ClientName,
	EmployeeID,
	[Order Details].ProductID,
	[Order Details].UnitPrice,
	UnitCost,
	Quantity,
	Discount,
	Discount*([Order Details].UnitPrice*Quantity) AS DiscountValue,
	[Order Details].UnitPrice*Quantity AS Revenue,
	UnitCost*Quantity AS CostOfGoods,
	([Order Details].UnitPrice*Quantity)*(1-Discount) AS DiscountedRevenue,
	Freight,
	Freight/NumberOfProducts AS FreightByProduct,
	DATEADD(year,24,OrderDate) AS OrderDate, -- The data is for 1997-1998, therefore adding 24 years to bring it closer to today
	DATEADD(year,24,RequiredDate) AS RequiredDate,
	DATEADD(year,24,ShippedDate) AS ShippedDate,
	ShipName,
	ShipAddress,
	ShipCity,
	ShipRegion,
	ShipPostalCode,
	ShipCountry,
	Shippers.CompanyName AS ShippersName,
	ContactName AS ClientContact,
	ContactTitle,
	[Address] AS ClientAddress,
	City AS ClientCity,
	Region,
	PostalCode,
	Country
FROM [dbo].[Orders]
INNER JOIN [dbo].[Order Details] ON [Orders].OrderID=[Order Details].OrderID
INNER JOIN [dbo].[Shippers] ON [Orders].ShipVia=[Shippers].ShipperID
INNER JOIN [dbo].[Customers] ON [Orders].CustomerID=[Customers].CustomerID
INNER JOIN number_of_products_cte ON [Orders].OrderID=[number_of_products_cte].OrderID

/*Creating the combined table for Employees*/
CREATE TABLE EmployeesMain (
	TerritoryID nvarchar(20),
	EmployeeID int,
	TerritoryDescription nchar(50),
	RegionDescription nchar(50),
	EmployeeName nvarchar(30),
	Title nvarchar(30),
	TitleOfCourtesy nvarchar(25),
	BirthDate datetime,
	HireDate datetime,
	[Address] nvarchar(60),
	City nvarchar(15),
	Region nvarchar(15),
	PostalCode nvarchar(10),
	Country nvarchar (15),
	Notes ntext,
	ReportsTo int
);

/* In case you want to delete the above table */
DROP TABLE dbo.EmployeesMain;

/* Joining Employee, Employee territories, Territories and Regions Table and inserting the results into EmployeeMain table */
WITH territory_cte(TerritoryID,EmployeeID,TerritoryDescription,RegionDescription)
AS
(
SELECT 
	t.TerritoryID,
	EmployeeID,
	TerritoryDescription,
	RegionDescription
FROM Territories AS t
	INNER JOIN Region AS r ON t.RegionID=r.RegionID
	INNER JOIN EmployeeTerritories AS e ON t.TerritoryID=e.TerritoryID
)
INSERT INTO EmployeesMain
SELECT
	t.TerritoryID,
	e.EmployeeID,
	TerritoryDescription,
	RegionDescription,
	FirstName + ' ' + LastName AS EmployeeName,
	Title,
	TitleOfCourtesy,
	DATEADD(year,24,BirthDate) AS BirthDate,
	DATEADD(year,24,HireDate) AS HireDate,
	[Address],
	City,
	Region,
	PostalCode,
	Country,
	Notes,
	ReportsTo
FROM Employees AS e
INNER JOIN territory_cte AS t ON e.EmployeeID=t.EmployeeID;

/*Creating the combined table for Products*/
CREATE TABLE ProductsMain (
	ProductID int,
	ProductName nvarchar(40),
	SupplierID int,
	Supplier nvarchar(40),
	CategoryID int,
	CategoryName nvarchar(15),
	Description ntext,
	UnitPrice money,
	UnitsInStock smallint,
	UnitsOnOrder smallint,
	ReorderLevel smallint,
	Discontinued bit,
	SupplierContact nvarchar(30),
	ContactTitle nvarchar(30),
	Country nvarchar(15),
	Phone nvarchar(24)
	);

	/* In case you want to delete the above table */
DROP TABLE dbo.ProductsMain;

/* Joining Products, Categories and Suppliers tables and inserting the results into ProductsMain table */
INSERT INTO ProductsMain
SELECT
	ProductID,
	ProductName,
	p.SupplierID,
	s.CompanyName AS Supplier,
	p.CategoryID,
	CategoryName,
	Description,
	UnitPrice,
	UnitsInStock,
	UnitsOnOrder,
	ReorderLevel,
	Discontinued,
	ContactName AS SupplierContanct,
	ContactTitle,
	Country,
	Phone
FROM Products AS p
INNER JOIN Categories AS c ON p.CategoryID=c.CategoryID
INNER JOIN Suppliers AS s ON p.SupplierID=s.SupplierID;