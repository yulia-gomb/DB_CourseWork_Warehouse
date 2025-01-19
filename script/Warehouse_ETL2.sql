CREATE EXTENSION postgres_fdw;

CREATE SERVER warehouse_fdw
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (dbname 'warehouse');

CREATE USER MAPPING FOR CURRENT_USER
SERVER warehouse_fdw
OPTIONS (USER 'postgres', password 'postgres');


-- Creating foreign tables
CREATE SCHEMA IF NOT EXISTS staging;

CREATE FOREIGN TABLE staging.warehouse_fdw_products (
    ProductBarcode VARCHAR(30),
    ProductName VARCHAR(255),
    CategoryID INT,
    ManufacturerID INT,
    PricePerUnit DECIMAL,
    UnitWeight DECIMAL,
    WarehouseID INT
)
SERVER warehouse_fdw
OPTIONS (schema_name 'public', table_name 'products');

CREATE FOREIGN TABLE staging.warehouse_fdw_categories (
    CategoryID INT,
    CategoryName VARCHAR(255)
)
SERVER warehouse_fdw
OPTIONS (schema_name 'public', table_name 'productcategories');

CREATE FOREIGN TABLE staging.warehouse_fdw_warehouses (
    WarehouseID INT,
    WarehouseName VARCHAR(50),
    AddressID INT,
    Phone VARCHAR(20)
)
SERVER warehouse_fdw
OPTIONS (schema_name 'public', table_name 'warehouses');

CREATE FOREIGN TABLE staging.warehouse_fdw_manufacturers (
    ManufacturerID INT,
    ManufacturerName VARCHAR(100),
    AddressID INT,
    Phone VARCHAR(20),
    Email VARCHAR(255)
)
SERVER warehouse_fdw
OPTIONS (schema_name 'public', table_name 'manufacturers');

CREATE FOREIGN TABLE staging.warehouse_fdw_addresses (
    AddressID INT,
    Street VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100)
)
SERVER warehouse_fdw
OPTIONS (schema_name 'public', table_name 'addresses');

CREATE FOREIGN TABLE staging.warehouse_fdw_suppliers (
    SupplierContractNumber VARCHAR(20),
    SupplierName VARCHAR(255),
    AddressID INT,
    Phone VARCHAR(20),
    Email VARCHAR(255)
)
SERVER warehouse_fdw
OPTIONS (schema_name 'public', table_name 'suppliers');

CREATE FOREIGN TABLE staging.warehouse_fdw_carriers (
    CarrierID INT,
    CarrierName VARCHAR(100),
    AddressID INT,
    Phone VARCHAR(20),
    Email VARCHAR(255)
)
SERVER warehouse_fdw
OPTIONS (schema_name 'public', table_name 'carriers');

CREATE FOREIGN TABLE staging.warehouse_fdw_shipments (
    InvoiceNumber INT,
    SupplierContractNumber VARCHAR(20),
    CarrierID INT,
    ShipmentDate DATE,
    ProductBarcode VARCHAR(30),
    Quantity INT,
    PricePerUnit DECIMAL
)
SERVER warehouse_fdw
OPTIONS (schema_name 'public', table_name 'shipments');


-- Inserting data to Dimension tables
INSERT INTO DimWarehouse (WarehouseID, WarehouseName)
SELECT WarehouseID, WarehouseName
FROM staging.warehouse_fdw_warehouses
ON CONFLICT (WarehouseID) DO NOTHING;


INSERT INTO DimCategory (CategoryID, CategoryName)
SELECT CategoryID, CategoryName 
FROM staging.warehouse_fdw_categories
ON CONFLICT (CategoryID) DO NOTHING;


INSERT INTO DimProduct (ProductBarcode, ProductName, CategoryID, ManufacturerID, PricePerUnit, UnitWeight)
SELECT ProductBarcode, ProductName, CategoryID, ManufacturerID, PricePerUnit, UnitWeight
FROM staging.warehouse_fdw_products
ON CONFLICT (ProductBarcode) DO NOTHING;

INSERT INTO DimManufacturer (ManufacturerID, ManufacturerName)
SELECT ManufacturerID, ManufacturerName
FROM staging.warehouse_fdw_manufacturers
ON CONFLICT (ManufacturerID) DO NOTHING;

INSERT INTO DimTime (ShipmentDate, Year, Quarter, Month, Date)
SELECT DISTINCT ShipmentDate,
    EXTRACT(YEAR FROM ShipmentDate) AS Year,
    EXTRACT(QUARTER FROM ShipmentDate) AS Quarter,
    EXTRACT(MONTH FROM ShipmentDate) AS Month,
    ShipmentDate AS Date
FROM staging.warehouse_fdw_shipments
ON CONFLICT (ShipmentDate) DO NOTHING;

INSERT INTO FactWarehouseStores (InvoiceNumber, WarehouseID, ProductBarcode, CategoryID, SupplierContractNumber, ShipmentDate, QuantityShipped, PricePerUnit, ValueShipped)
SELECT 
    s.InvoiceNumber,
    p.WarehouseID,
    s.ProductBarcode,
    p.CategoryID,
    s.SupplierContractNumber,
    s.ShipmentDate,
    s.Quantity,
    s.PricePerUnit,
    s.Quantity * s.PricePerUnit
FROM staging.warehouse_fdw_shipments s
JOIN staging.warehouse_fdw_products p ON s.ProductBarcode = p.ProductBarcode
ON CONFLICT (InvoiceNumber) DO NOTHING;

INSERT INTO FactManufacturerShipments (InvoiceNumber, ManufacturerID, ProductBarcode, ShipmentDate, QuantityShipped, PricePerUnit, ValueShipped)
SELECT 
    s.InvoiceNumber,
    m.ManufacturerID,
    s.ProductBarcode,
    s.ShipmentDate,
    s.Quantity AS QuantityShipped,
    s.PricePerUnit,
    s.Quantity * s.PricePerUnit AS ValueShipped
FROM staging.warehouse_fdw_shipments s
JOIN staging.warehouse_fdw_products p ON s.ProductBarcode = p.ProductBarcode
JOIN staging.warehouse_fdw_manufacturers m ON p.ManufacturerID = m.ManufacturerID
ON CONFLICT (InvoiceNumber) DO NOTHING;

----DimProductPriceHistory

WITH UniquePriceDatePairs AS (
    SELECT 
        pph.ProductBarcode, 
        ARRAY_AGG(DISTINCT (pph.PricePerUnit, pph.DateEffective)) AS UniquePairs
    FROM DimProductPriceHistory pph
    GROUP BY pph.ProductBarcode
)
INSERT INTO DimProductPriceHistory (ProductBarcode, DateEffective, PricePerUnit)
SELECT 
    s.ProductBarcode,
    s.ShipmentDate AS DateEffective,
    s.PricePerUnit
FROM staging.warehouse_fdw_shipments s
LEFT JOIN UniquePriceDatePairs lp ON s.ProductBarcode = lp.ProductBarcode
WHERE lp.UniquePairs IS NULL OR NOT ((s.PricePerUnit, s.ShipmentDate) = ANY (lp.UniquePairs));

----- чистка дубликатов после начального запуска

WITH RankedEntries AS (
    SELECT 
        ProductBarcode,
        PricePerUnit,
        DateEffective,
        ROW_NUMBER() OVER (PARTITION BY ProductBarcode, PricePerUnit ORDER BY DateEffective DESC) AS rn
    FROM DimProductPriceHistory
)
DELETE FROM DimProductPriceHistory
WHERE (ProductBarcode, PricePerUnit, DateEffective) IN (
    SELECT ProductBarcode, PricePerUnit, DateEffective
    FROM RankedEntries
    WHERE rn > 1
);

-----------

SELECT * FROM public.dimwarehouse
ORDER BY warehouseid ASC;

SELECT * FROM public.dimcategory
ORDER BY categoryid ASC;

SELECT * FROM public.dimproduct
ORDER BY productbarcode ASC;

SELECT * FROM public.dimmanufacturer
ORDER BY manufacturerid ASC;

SELECT * FROM public.dimtime
ORDER BY shipmentdate ASC;

SELECT * FROM public.factwarehousestores
ORDER BY invoicenumber ASC;

SELECT * FROM public.factmanufacturershipments
ORDER BY invoicenumber ASC;

SELECT * FROM public.dimproductpricehistory
ORDER BY productpriceid ASC;




