DROP TABLE IF EXISTS FactManufacturerShipments;
DROP TABLE IF EXISTS FactWarehouseStores;
DROP TABLE IF EXISTS DimProductPriceHistory;
DROP TABLE IF EXISTS DimTime;
DROP TABLE IF EXISTS DimWarehouse;
DROP TABLE IF EXISTS DimManufacturer;
DROP TABLE IF EXISTS DimCategory;
DROP TABLE IF EXISTS DimProduct;

-- Create Dimension Tables
CREATE TABLE DimProduct (
    ProductBarcode VARCHAR(30) PRIMARY KEY,
    ProductName VARCHAR(100),
    CategoryID INT,
    ManufacturerID INT,
    PricePerUnit DECIMAL(10,2),
    UnitWeight DECIMAL(10,3)
);

CREATE TABLE DimCategory (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100)
);

CREATE TABLE DimManufacturer (
    ManufacturerID INT PRIMARY KEY,
    ManufacturerName VARCHAR(150)
);

CREATE TABLE DimWarehouse (
    WarehouseID INT PRIMARY KEY,
    WarehouseName VARCHAR(100)
);

CREATE TABLE DimTime (
    ShipmentDate DATE PRIMARY KEY,
    Year INT,
    Quarter INT,
    Month INT,
    Date DATE
);

CREATE TABLE DimProductPriceHistory (
    ProductPriceID SERIAL PRIMARY KEY,
    ProductBarcode VARCHAR(30),
    DateEffective DATE,
    PricePerUnit DECIMAL(10,2),
    FOREIGN KEY (ProductBarcode) REFERENCES DimProduct(ProductBarcode)
);

-- Create Fact Tables
CREATE TABLE FactWarehouseStores (
    InvoiceNumber VARCHAR(50) PRIMARY KEY,
    WarehouseID INT,
    ProductBarcode VARCHAR(30),
    CategoryID INT,
    SupplierContractNumber VARCHAR(20),
    ShipmentDate DATE,
    QuantityShipped INT,
    PricePerUnit DECIMAL(10,2),
    ValueShipped DECIMAL(10,2),
    FOREIGN KEY (WarehouseID) REFERENCES DimWarehouse(WarehouseID),
    FOREIGN KEY (ProductBarcode) REFERENCES DimProduct(ProductBarcode),
    FOREIGN KEY (CategoryID) REFERENCES DimCategory(CategoryID),
    FOREIGN KEY (ShipmentDate) REFERENCES DimTime(ShipmentDate)
);

CREATE TABLE FactManufacturerShipments (
    InvoiceNumber VARCHAR(50) PRIMARY KEY,
    ManufacturerID INT,
    ProductBarcode VARCHAR(30),
    ShipmentDate DATE,
    QuantityShipped INT,
    PricePerUnit DECIMAL(10,2),
    ValueShipped DECIMAL(10,2),
    FOREIGN KEY (ManufacturerID) REFERENCES DimManufacturer(ManufacturerID),
    FOREIGN KEY (ProductBarcode) REFERENCES DimProduct(ProductBarcode),
    FOREIGN KEY (ShipmentDate) REFERENCES DimTime(ShipmentDate)
);