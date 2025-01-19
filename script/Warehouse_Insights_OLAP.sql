-- Selects supplier name, year, quarter, and aggregates total quantity, weight in kilograms, and monetary value of goods delivered
-- This query helps in analyzing the delivery metrics by each supplier broken down by quarters, which aids in seasonal trend analysis and strategic planning
SELECT 
    m.ManufacturerName,
    t.Year,
    t.Quarter,
    SUM(f.QuantityShipped) AS TotalQuantity,
    SUM(f.QuantityShipped * p.UnitWeight) AS TotalWeightKg,
    SUM(f.QuantityShipped * f.PricePerUnit) AS TotalValue
FROM 
    FactManufacturerShipments f
JOIN 
    DimProduct p ON f.ProductBarcode = p.ProductBarcode
JOIN 
    DimManufacturer m ON p.ManufacturerID = m.ManufacturerID
JOIN 
    DimTime t ON f.ShipmentDate = t.ShipmentDate
GROUP BY 
    m.ManufacturerName, t.Year, t.Quarter
ORDER BY 
    m.ManufacturerName, t.Year, t.Quarter;


-- Aggregate shipments by product categories and quarters
-- This query is useful for analyzing the performance and trends of product categories throughout different quarters
SELECT 
    c.CategoryName,
    t.Year,
    t.Quarter,
    SUM(f.QuantityShipped) AS TotalQuantity,
    SUM(f.QuantityShipped * p.UnitWeight) AS TotalWeightKg,
    SUM(f.QuantityShipped * f.PricePerUnit) AS TotalValue
FROM 
    FactManufacturerShipments f
JOIN 
    DimProduct p ON f.ProductBarcode = p.ProductBarcode
JOIN 
    DimCategory c ON p.CategoryID = c.CategoryID
JOIN 
    DimTime t ON f.ShipmentDate = t.ShipmentDate
GROUP BY 
    c.CategoryName, t.Year, t.Quarter
ORDER BY 
    c.CategoryName, t.Year, t.Quarter;


-- Aggregate shipments by warehouse and months
-- This query helps track shipment volumes and values delivered to different warehouses, analyzed monthly
SELECT 
    w.WarehouseName,
    t.Year,
    t.Month,
    SUM(f.QuantityShipped) AS TotalQuantity,
    SUM(f.QuantityShipped * f.PricePerUnit) AS TotalValue
FROM 
    FactWarehouseStores f
JOIN 
    DimWarehouse w ON f.WarehouseID = w.WarehouseID
JOIN 
    DimTime t ON f.ShipmentDate = t.ShipmentDate
GROUP BY 
    w.WarehouseName, t.Year, t.Month
ORDER BY 
    w.WarehouseName, t.Year, t.Month;


-- Aggregate shipments by product names and months
-- This query is useful for analyzing monthly product delivery volumes and for inventory management
SELECT 
    p.ProductName,
    t.Year,
    t.Month,
    SUM(f.QuantityShipped) AS TotalQuantity
FROM 
    FactWarehouseStores f
JOIN 
    DimProduct p ON f.ProductBarcode = p.ProductBarcode
JOIN 
    DimTime t ON f.ShipmentDate = t.ShipmentDate
GROUP BY 
    p.ProductName, t.Year, t.Month
ORDER BY 
    p.ProductName, t.Year, t.Month;