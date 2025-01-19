DROP TABLE IF EXISTS Addresses CASCADE;
CREATE TABLE Addresses (
    AddressID SERIAL PRIMARY KEY,
    Street VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100) NOT NULL,
    PostalCode VARCHAR(20) NOT NULL,
    Country VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS ProductCategories CASCADE;
CREATE TABLE ProductCategories (
    CategoryID SERIAL PRIMARY KEY,
    CategoryName VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS Manufacturers CASCADE;
CREATE TABLE Manufacturers (
    ManufacturerID SERIAL PRIMARY KEY,
    ManufacturerName VARCHAR(100) NOT NULL,
    AddressID INT UNIQUE NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    FOREIGN KEY (AddressID) REFERENCES Addresses (AddressID)
);

DROP TABLE IF EXISTS Warehouses CASCADE;
CREATE TABLE Warehouses (
    WarehouseID SERIAL PRIMARY KEY,
    WarehouseName VARCHAR(50) NOT NULL,
    AddressID INT UNIQUE NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    FOREIGN KEY (AddressID) REFERENCES Addresses (AddressID)
);

DROP TABLE IF EXISTS Suppliers CASCADE;
CREATE TABLE Suppliers (
    SupplierContractNumber VARCHAR(20) PRIMARY KEY,
    SupplierName VARCHAR(255) NOT NULL,
    AddressID INT UNIQUE NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    FOREIGN KEY (AddressID) REFERENCES Addresses (AddressID)
);

DROP TABLE IF EXISTS Carriers CASCADE;
CREATE TABLE Carriers (
    CarrierID SERIAL PRIMARY KEY,
    CarrierName VARCHAR(100) NOT NULL,
    AddressID INT UNIQUE NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    FOREIGN KEY (AddressID) REFERENCES Addresses (AddressID)
);

DROP TABLE IF EXISTS Products CASCADE;
CREATE TABLE Products (
    ProductBarcode VARCHAR(30) PRIMARY KEY,
    ProductName VARCHAR(255) NOT NULL,
    CategoryID INT NOT NULL,
    ManufacturerID INT NOT NULL,
    PricePerUnit DECIMAL NOT NULL,
    UnitWeight DECIMAL NOT NULL,
    WarehouseID INT NOT NULL,
    FOREIGN KEY (CategoryID) REFERENCES ProductCategories (CategoryID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers (ManufacturerID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses (WarehouseID)
);

DROP TABLE IF EXISTS Shipments CASCADE;
CREATE TABLE Shipments (
    InvoiceNumber SERIAL PRIMARY KEY,
    SupplierContractNumber VARCHAR(20) NOT NULL,
    CarrierID INT NOT NULL,
    ShipmentDate DATE NOT NULL,
    ProductBarcode VARCHAR(30) NOT NULL,
    Quantity INT NOT NULL,
	PricePerUnit DECIMAL NOT NULL,
    FOREIGN KEY (SupplierContractNumber) REFERENCES Suppliers (SupplierContractNumber),
    FOREIGN KEY (CarrierID) REFERENCES Carriers (CarrierID),
    FOREIGN KEY (ProductBarcode) REFERENCES Products (ProductBarcode)
);