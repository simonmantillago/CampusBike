INSERT INTO Country (CountryName) VALUES
('Colombia'),
('USA'),
('Spain');

INSERT INTO City (CityName, CountryID) VALUES
('Bogotá', 1),
('Medellín', 1),
('New York', 2),
('Madrid', 3);

INSERT INTO Brand (BrandName) VALUES
('BrandA'),
('BrandB'),
('BrandC');

INSERT INTO Model (ModelName, BrandID) VALUES
('Mountain Bike 1', 1),
('Road Bike 2', 2),
('Electric Bike 3', 3);

INSERT INTO Bicycle (ModelID, Price, Stock) VALUES
(1, 500.00, 10),
(2, 750.00, 5),
(3, 1000.00, 3);

INSERT INTO Customer (ID, Name, Email, Phone, CityID) VALUES
('1098387298', 'John Doe', 'john@example.com', '123456789', 1),
('1767365849','Jane Smith', 'jane@example.com', '987654321', 2),
('1200890832','Carlos Perez' , 'carlos@example.com', '456789123', 3);

INSERT INTO Sale (Date, CustomerID, Total) VALUES
('2024-07-01','1098387298' , 500.00),
('2024-07-02','1767365849', 1500.00);

INSERT INTO SaleDetail (SaleID, BicycleID, Quantity, UnitPrice) VALUES
(1, 1, 1, 500.00),
(2, 2, 2, 750.00);

INSERT INTO Supplier (ID, SupplierName, Contact, Phone, Email, CityID) VALUES
(10001,'Supplier1', 'Contact1', '1122334455', 'supplier1@example.com', 1),
(10002,'Supplier2', 'Contact2', '2233445566', 'supplier2@example.com', 3);

INSERT INTO Part (PartName, Description, Price, Stock, SupplierID) VALUES
('Brake', 'High quality brake', 50.00, 20, 10001),
('Wheel', 'Durable wheel', 100.00, 15, 10002);

INSERT INTO Purchase (Date, SupplierID, Total) VALUES
('2024-07-01', 10001, 1000.00),
('2024-07-02', 10002, 1500.00);

INSERT INTO PurchaseDetail (PurchaseID, PartID, Quantity, UnitPrice) VALUES
(1, 1, 10, 50.00),
(2, 2, 15, 100.00);