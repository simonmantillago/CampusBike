CREATE DATABASE IF NOT EXISTS bike_shop;
USE bike_shop;

CREATE TABLE Country (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    CountryName VARCHAR(100) NOT NULL
);

CREATE TABLE City (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    CityName VARCHAR(100) NOT NULL,
    CountryID INT,
    FOREIGN KEY (CountryID) REFERENCES Country(ID)
);

CREATE TABLE Brand (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    BrandName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Model (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ModelName VARCHAR(100) NOT NULL,
    BrandID INT,
    FOREIGN KEY (BrandID) REFERENCES Brand(ID)
);

CREATE TABLE Bicycle (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ModelID INT,
    Price DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    FOREIGN KEY (ModelID) REFERENCES Model(ID),
    CHECK (Price > 0),
    CHECK (Stock >= 0)
);

CREATE TABLE Customer (
    ID VARCHAR(20) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    CityID INT,
    FOREIGN KEY (CityID) REFERENCES City(ID),
    CHECK (Email LIKE '%@%.%')
);

CREATE TABLE Sale (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Date DATE NOT NULL,
    CustomerID VARCHAR(20),
    Total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(ID),
    CHECK (Total >= 0)
);

CREATE TABLE SaleDetail (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    SaleID INT,
    BicycleID INT,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (SaleID) REFERENCES Sale(ID),
    FOREIGN KEY (BicycleID) REFERENCES Bicycle(ID),
    CHECK (Quantity > 0),
    CHECK (UnitPrice > 0)
);

CREATE TABLE Supplier (
    ID INT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    Contact VARCHAR(100),
    Phone VARCHAR(20),
    Email VARCHAR(100),
    CityID INT,
    FOREIGN KEY (CityID) REFERENCES City(ID),
    CHECK (Email LIKE '%@%.%')
);

CREATE TABLE Part (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    PartName VARCHAR(100) NOT NULL,
    Description TEXT,
    Price DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    SupplierID INT,
    FOREIGN KEY (SupplierID) REFERENCES Supplier(ID),
    CHECK (Price > 0),
    CHECK (Stock >= 0)
);

CREATE TABLE Purchase (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Date DATE NOT NULL,
    SupplierID INT,
    Total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (SupplierID) REFERENCES Supplier(ID),
    CHECK (Total >= 0)
);

CREATE TABLE PurchaseDetail (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    PurchaseID INT,
    PartID INT,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (PurchaseID) REFERENCES Purchase(ID),
    FOREIGN KEY (PartID) REFERENCES Part(ID),
    CHECK (Quantity > 0),
    CHECK (UnitPrice > 0)
);