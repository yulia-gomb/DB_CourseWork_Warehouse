-- Selects supplier name, year, quarter, and aggregates total quantity, weight in kilograms, and monetary value of goods delivered
-- This query helps in analyzing the delivery metrics by each supplier broken down by quarters, which aids in seasonal trend analysis and strategic planning
SELECT 
    s.SupplierName,
    EXTRACT(YEAR FROM sh.ShipmentDate) AS Year,
    EXTRACT(QUARTER FROM sh.ShipmentDate) AS Quarter,
    SUM(sh.Quantity) AS TotalQuantity,
    SUM(sh.Quantity * p.UnitWeight) AS TotalWeightKg,
    SUM(sh.Quantity * sh.PricePerUnit) AS TotalValue
FROM 
    Suppliers s
JOIN 
    Shipments sh ON s.SupplierContractNumber = sh.SupplierContractNumber
JOIN 
    Products p ON sh.ProductBarcode = p.ProductBarcode
GROUP BY 
    s.SupplierName,
    Year,
    Quarter
ORDER BY 
    s.SupplierName, Year, Quarter;


-- Aggregate shipments by product categories and quarters
-- This query is useful for analyzing the performance and trends of product categories throughout different quarters
SELECT 
    pc.CategoryName,
    EXTRACT(YEAR FROM sh.ShipmentDate) AS Year,
    EXTRACT(QUARTER FROM sh.ShipmentDate) AS Quarter,
    SUM(sh.Quantity) AS TotalQuantity,
    SUM(sh.Quantity * sh.PricePerUnit) AS TotalValue
FROM 
    Shipments sh
JOIN 
    Products p ON sh.ProductBarcode = p.ProductBarcode
JOIN 
    ProductCategories pc ON p.CategoryID = pc.CategoryID
GROUP BY 
    pc.CategoryName, Year, Quarter
ORDER BY 
    pc.CategoryName, Year, Quarter;


-- Aggregate shipments by warehouse and months
-- This query helps track shipment volumes and values delivered to different warehouses, analyzed monthly
SELECT 
    w.WarehouseName,
    EXTRACT(YEAR FROM sh.ShipmentDate) AS Year,
    EXTRACT(MONTH FROM sh.ShipmentDate) AS Month,
    SUM(sh.Quantity) AS TotalQuantity,
    SUM(sh.Quantity * sh.PricePerUnit) AS TotalValue
FROM 
    Shipments sh
JOIN 
    Products p ON sh.ProductBarcode = p.ProductBarcode
JOIN 
    Warehouses w ON p.WarehouseID = w.WarehouseID
GROUP BY 
    w.WarehouseName, Year, Month
ORDER BY 
    w.WarehouseName, Year, Month;


-- Aggregate shipments by product names and months
-- This query is useful for analyzing monthly product delivery volumes and for inventory management
SELECT 
    p.ProductName,
    EXTRACT(YEAR FROM sh.ShipmentDate) AS Year,
    EXTRACT(MONTH FROM sh.ShipmentDate) AS Month,
    SUM(sh.Quantity) AS TotalQuantity 
FROM 
    Shipments sh
JOIN 
    Products p ON sh.ProductBarcode = p.ProductBarcode
GROUP BY 
    p.ProductName, Year, Month 
ORDER BY 
    p.ProductName, Year, Month; 

