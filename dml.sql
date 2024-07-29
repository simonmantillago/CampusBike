USE bike_shop;


INSERT INTO Country (CountryName) VALUES 
('USA'),
('Canada'),
('Mexico'),
('Brazil');


INSERT INTO City (CityName, CountryID) VALUES 
('New York', 1),
('Toronto', 2),
('Mexico City', 3),
('Rio de Janeiro', 4);


INSERT INTO Brand (BrandName) VALUES 
('Giant'),
('Trek'),
('Specialized'),
('Cannondale');


INSERT INTO Category (CategoryName) VALUES 
('Mountain'),
('Road'),
('Hybrid'),
('Electric');


INSERT INTO Model (ModelName, BrandID, CategoryID) VALUES 
('Anthem Advanced Pro', 1, 1),
('Domane SL 6', 2, 2),
('Turbo Vado SL', 3, 4),
('Synapse Carbon', 4, 3);


INSERT INTO Bicycle (ModelID, Price, Stock) VALUES 
(1, 4500.00, 10),
(2, 3500.00, 5),
(3, 7000.00, 2),
(4, 3000.00, 7);


INSERT INTO Customer (ID, Name, Email, Phone, CityID) VALUES 
('C001', 'Alice Smith', 'alice.smith@example.com', '123-456-7890', 1),
('C002', 'Bob Johnson', 'bob.johnson@example.com', '234-567-8901', 2),
('C003', 'Carlos Mendoza', 'carlos.mendoza@example.com', '345-678-9012', 3),
('C004', 'Diana Costa', 'diana.costa@example.com', '456-789-0123', 4);


INSERT INTO Sale (Date, CustomerID, Total) VALUES 
('2023-01-15', 'C001', 4500.00),
('2022-06-30', 'C002', 3500.00),
('2021-09-20', 'C003', 7000.00),
('2020-12-10', 'C004', 3000.00);


INSERT INTO SaleDetail (SaleID, BicycleID, Quantity, UnitPrice) VALUES 
(1, 1, 1, 4500.00),
(2, 2, 1, 3500.00),
(3, 3, 1, 7000.00),
(4, 4, 1, 3000.00);


INSERT INTO Supplier (ID, SupplierName, Contact, Phone, Email, CityID) VALUES 
(101, 'Bike Parts Co.', 'John Doe', '567-890-1234', 'john.doe@bikeparts.com', 1),
(102, 'Cycling Supplies Ltd.', 'Jane Roe', '678-901-2345', 'jane.roe@cyclingsupplies.com', 2),
(103, 'Pedal Power Inc.', 'Carlos Silva', '789-012-3456', 'carlos.silva@pedalpower.com', 3),
(104, 'Wheel World', 'Diana Luz', '890-123-4567', 'diana.luz@wheelworld.com', 4);


INSERT INTO Part (PartName, Description, Price, Stock, SupplierID) VALUES 
('Chain', 'High-performance bike chain', 25.00, 100, 101),
('Brake Pads', 'Durable brake pads', 15.00, 200, 102),
('Tire', 'All-terrain tire', 50.00, 150, 103),
('Handlebar', 'Lightweight handlebar', 70.00, 50, 104);


INSERT INTO Purchase (Date, SupplierID, Total) VALUES 
('2023-02-15', 101, 2500.00),
('2022-07-30', 102, 3000.00),
('2021-10-20', 103, 3500.00),
('2020-11-10', 104, 2000.00);


INSERT INTO PurchaseDetail (PurchaseID, PartID, Quantity, UnitPrice) VALUES 
(1, 1, 100, 25.00),
(2, 2, 200, 15.00),
(3, 3, 70, 50.00),
(4, 4, 30, 70.00);
