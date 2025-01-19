CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.temp_suppliers;
DROP TABLE IF EXISTS staging.temp_carriers;
DROP TABLE IF EXISTS staging.temp_manufacturers;
DROP TABLE IF EXISTS staging.temp_warehouses;
DROP TABLE IF EXISTS staging.temp_stock;


CREATE TABLE staging.temp_suppliers (
    SupplierContractNumber VARCHAR(20),
    SupplierName VARCHAR(255),
    Phone VARCHAR(20),
    Email VARCHAR(255),
    Street VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100)
);


CREATE TABLE staging.temp_carriers (
    CarrierName VARCHAR(200),
    Phone VARCHAR(20),
    Email VARCHAR(255),
    Street VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100)
);


CREATE TABLE staging.temp_manufacturers (
    ManufacturerName VARCHAR(100),
    Phone VARCHAR(20),
    Email VARCHAR(255),
    Street VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100)
);


CREATE TABLE staging.temp_warehouses (
    WarehouseName VARCHAR(50),
    Phone VARCHAR(20),
    Street VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100)
);


CREATE TABLE staging.temp_stock (
    WarehouseName VARCHAR(50),
    ProductBarcode VARCHAR(20),
    ProductName VARCHAR(255),
    CategoryName VARCHAR(100),
    ManufacturerName VARCHAR(100),
    InvoiceNumber INT,
    SupplierContractNumber VARCHAR(20),
    CarrierName VARCHAR(100),
    ShipmentDate DATE,
    Quantity INT,
    PricePerUnit NUMERIC,
    UnitWeight NUMERIC
);

COPY staging.temp_carriers FROM 'C:/tmp/Carriers.csv' DELIMITER ';' CSV HEADER;
COPY staging.temp_suppliers FROM 'C:/tmp/Suppliers.csv' DELIMITER ';' CSV HEADER;
COPY staging.temp_manufacturers FROM 'C:/tmp/Manufactures.csv' DELIMITER ';' CSV HEADER;
COPY staging.temp_warehouses FROM 'C:/tmp/Warehouses.csv' DELIMITER ';' CSV HEADER;
COPY staging.temp_stock FROM 'C:/tmp/Stock.csv' DELIMITER ';' CSV HEADER;



-- Transfer adress data from temp_suppliers
INSERT INTO public.addresses (Street, City, State, PostalCode, Country)
SELECT DISTINCT Street, City, State, PostalCode, Country
FROM staging.temp_suppliers s
WHERE NOT EXISTS (
    SELECT 1
    FROM public.addresses a
    WHERE a.Street = s.Street AND a.City = s.City AND a.State = s.State 
          AND a.PostalCode = s.PostalCode AND a.Country = s.Country
);

-- Transfer data to suppliers using AddressID from addresses table
INSERT INTO public.suppliers (SupplierContractNumber, SupplierName, AddressID, Phone, Email)
SELECT s.SupplierContractNumber, s.SupplierName, a.AddressID, s.Phone, s.Email
FROM staging.temp_suppliers s
JOIN public.addresses a ON s.Street = a.Street AND s.City = a.City AND s.State = a.State 
                             AND s.PostalCode = a.PostalCode AND s.Country = a.Country
ON CONFLICT (SupplierContractNumber) DO UPDATE
SET SupplierName = EXCLUDED.SupplierName,
    AddressID = EXCLUDED.AddressID,
    Phone = EXCLUDED.Phone,
    Email = EXCLUDED.Email;


-- Transfer unique addresses for Carriers
INSERT INTO public.addresses (Street, City, State, PostalCode, Country)
SELECT DISTINCT Street, City, State, PostalCode, Country
FROM staging.temp_carriers c
WHERE NOT EXISTS (
    SELECT 1
    FROM public.addresses a
    WHERE a.Street = c.Street AND a.City = c.City AND a.State = c.State 
          AND a.PostalCode = c.PostalCode AND a.Country = c.Country
);

-- Update data for existing CarrierName
UPDATE public.carriers 
SET AddressID = a.AddressID, 
    Phone = c.Phone, 
    Email = c.Email
FROM staging.temp_carriers c
JOIN public.addresses a ON c.Street = a.Street AND c.City = a.City AND c.State = a.State
                         AND c.PostalCode = a.PostalCode AND c.Country = a.Country
WHERE public.carriers.CarrierName = c.CarrierName;

-- Transfer new data for Carriers
INSERT INTO public.carriers (CarrierName, AddressID, Phone, Email)
SELECT c.CarrierName, a.AddressID, c.Phone, c.Email
FROM staging.temp_carriers c
JOIN public.addresses a ON c.Street = a.Street AND c.City = a.City AND c.State = c.State
                         AND c.PostalCode = a.PostalCode AND c.Country = a.Country
WHERE NOT EXISTS (
    SELECT 1 FROM public.carriers
    WHERE CarrierName = c.CarrierName
);


-- Insert unique addresses for Warehouses
INSERT INTO public.addresses (Street, City, State, PostalCode, Country)
SELECT DISTINCT Street, City, State, PostalCode, Country
FROM staging.temp_warehouses
WHERE NOT EXISTS (
    SELECT 1
    FROM public.addresses a
    WHERE a.Street = staging.temp_warehouses.Street 
      AND a.City = staging.temp_warehouses.City 
      AND a.State = staging.temp_warehouses.State 
      AND a.PostalCode = staging.temp_warehouses.PostalCode 
      AND a.Country = staging.temp_warehouses.Country
);

-- Update existing data for Warehouses
UPDATE public.warehouses
SET AddressID = a.AddressID,
    Phone = w.Phone
FROM staging.temp_warehouses w
JOIN public.addresses a ON w.Street = a.Street AND w.City = a.City AND w.State = a.State
                         AND w.PostalCode = a.PostalCode AND w.Country = a.Country
WHERE public.warehouses.WarehouseName = w.WarehouseName;


-- Insert new warehouse records into Warehouses
INSERT INTO public.warehouses (WarehouseName, AddressID, Phone)
SELECT w.WarehouseName, a.AddressID, w.Phone
FROM staging.temp_warehouses w
JOIN public.addresses a ON w.Street = a.Street AND w.City = a.City AND w.State = a.State
                         AND w.PostalCode = a.PostalCode AND w.Country = a.Country
WHERE NOT EXISTS (
    SELECT 1 FROM public.warehouses
    WHERE WarehouseName = w.WarehouseName
);


-- Insert unique addresses for Manufacturers
INSERT INTO public.addresses (Street, City, State, PostalCode, Country)
SELECT DISTINCT Street, City, State, PostalCode, Country
FROM staging.temp_manufacturers
WHERE NOT EXISTS (
    SELECT 1
    FROM public.addresses a
    WHERE a.Street = staging.temp_manufacturers.Street 
      AND a.City = staging.temp_manufacturers.City 
      AND a.State = staging.temp_manufacturers.State 
      AND a.PostalCode = staging.temp_manufacturers.PostalCode 
      AND a.Country = staging.temp_manufacturers.Country
);


-- Update existing data for Manufacturers
UPDATE public.manufacturers
SET AddressID = a.AddressID,
    Phone = m.Phone,
    Email = m.Email
FROM staging.temp_manufacturers m
JOIN public.addresses a ON m.Street = a.Street AND m.City = a.City AND m.State = a.State
                         AND m.PostalCode = a.PostalCode AND m.Country = a.Country
WHERE public.manufacturers.ManufacturerName = m.ManufacturerName;


-- Insert new manufacturer records into Manufacturers
INSERT INTO public.manufacturers (ManufacturerName, AddressID, Phone, Email)
SELECT m.ManufacturerName, a.AddressID, m.Phone, m.Email
FROM staging.temp_manufacturers m
JOIN public.addresses a ON m.Street = a.Street AND m.City = a.City AND m.State = a.State
                         AND m.PostalCode = a.PostalCode AND m.Country = a.Country
WHERE NOT EXISTS (
    SELECT 1 FROM public.manufacturers
    WHERE ManufacturerName = m.ManufacturerName
);


-- Insert unique product categories into Product Categories
INSERT INTO public.productcategories (CategoryName)
SELECT DISTINCT CategoryName
FROM staging.temp_stock
WHERE NOT EXISTS (
    SELECT 1 
    FROM public.productcategories pc 
    WHERE pc.CategoryName = staging.temp_stock.CategoryName
);


-- Insert products into Products table
INSERT INTO public.products (
    ProductBarcode, 
    ProductName, 
    CategoryID, 
    ManufacturerID, 
    PricePerUnit, 
    UnitWeight, 
    WarehouseID
)
SELECT 
    ts.ProductBarcode, 
    ts.ProductName, 
    pc.CategoryID, 
    m.ManufacturerID, 
    ts.PricePerUnit, 
    ts.UnitWeight, 
    w.WarehouseID
FROM staging.temp_stock ts
JOIN public.productcategories pc ON ts.CategoryName = pc.CategoryName
JOIN public.manufacturers m ON ts.ManufacturerName = m.ManufacturerName
JOIN public.warehouses w ON ts.WarehouseName = w.WarehouseName
ON CONFLICT (ProductBarcode) DO NOTHING;


-- Insert shipments into Shipments table
INSERT INTO public.shipments (
    InvoiceNumber,
    SupplierContractNumber,
    CarrierID,
    ShipmentDate,
    ProductBarcode,
    Quantity,
	PricePerUnit
)
SELECT 
    ts.InvoiceNumber,
    ts.SupplierContractNumber,
    c.CarrierID,
    ts.ShipmentDate,
    ts.ProductBarcode,
    ts.Quantity,
	ts.PricePerUnit
FROM staging.temp_stock ts
JOIN public.carriers c ON ts.CarrierName = c.CarrierName
WHERE NOT EXISTS (
    SELECT 1
    FROM public.shipments s
    WHERE s.InvoiceNumber = ts.InvoiceNumber
);


SELECT * FROM public.addresses
ORDER BY addressid ASC;

SELECT * FROM public.suppliers
ORDER BY suppliercontractnumber ASC;

SELECT * FROM public.carriers
ORDER BY carrierid ASC;

SELECT * FROM public.warehouses
ORDER BY warehouseid ASC;

SELECT * FROM public.manufacturers
ORDER BY manufacturerid ASC;

SELECT * FROM public.productcategories
ORDER BY categoryid ASC;

SELECT * FROM public.products
ORDER BY productbarcode ASC;

SELECT * FROM public.shipments
ORDER BY invoicenumber ASC;
