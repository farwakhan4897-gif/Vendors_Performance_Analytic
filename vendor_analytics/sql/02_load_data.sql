-- ============================================================
-- 02_load_data.sql
-- Load all CSV files into raw staging tables
-- IMPORTANT: Replace ejaz0 with your actual Windows username
-- ============================================================

USE vendor_analytics;
SET GLOBAL local_infile = 1;

-- ── PURCHASES ─────────────────────────────────────────────
LOAD DATA LOCAL INFILE 'C:/Users/ejaz0/Desktop/vendor_analytics/data/purchases.csv'
INTO TABLE raw_purchases
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT 'purchases loaded:', COUNT(*) FROM raw_purchases;

-- ── END INVENTORY ─────────────────────────────────────────
LOAD DATA LOCAL INFILE 'C:/Users/ejaz0/Desktop/vendor_analytics/data/end_inventory.csv'
INTO TABLE raw_end_inventory
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT 'end_inventory loaded:', COUNT(*) FROM raw_end_inventory;

-- ── BEGIN INVENTORY ───────────────────────────────────────
LOAD DATA LOCAL INFILE 'C:/Users/ejaz0/Desktop/vendor_analytics/data/begin_inventory.csv'
INTO TABLE raw_begin_inventory
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT 'begin_inventory loaded:', COUNT(*) FROM raw_begin_inventory;

-- ── PURCHASE PRICES ───────────────────────────────────────
LOAD DATA LOCAL INFILE 'C:/Users/ejaz0/Desktop/vendor_analytics/data/purchase_prices.csv'
INTO TABLE raw_purchase_prices
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT 'purchase_prices loaded:', COUNT(*) FROM raw_purchase_prices;

-- ── VENDOR INVOICE ────────────────────────────────────────
LOAD DATA LOCAL INFILE 'C:/Users/ejaz0/Desktop/vendor_analytics/data/vendor_invoice.csv'
INTO TABLE raw_vendor_invoice
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT 'vendor_invoice loaded:', COUNT(*) FROM raw_vendor_invoice;

-- ── SALES ─────────────────────────────────────────────────
LOAD DATA LOCAL INFILE 'C:/Users/ejaz0/Desktop/vendor_analytics/data/sales.csv'
INTO TABLE raw_sales
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT 'sales loaded:', COUNT(*) FROM raw_sales;

-- ── FINAL ROW COUNT SUMMARY ───────────────────────────────
SELECT 'raw_purchases'      AS table_name, COUNT(*) AS row_count FROM raw_purchases      UNION ALL
SELECT 'raw_end_inventory',               COUNT(*)              FROM raw_end_inventory   UNION ALL
SELECT 'raw_begin_inventory',             COUNT(*)              FROM raw_begin_inventory UNION ALL
SELECT 'raw_purchase_prices',             COUNT(*)              FROM raw_purchase_prices UNION ALL
SELECT 'raw_vendor_invoice',              COUNT(*)              FROM raw_vendor_invoice  UNION ALL
SELECT 'raw_sales',                       COUNT(*)              FROM raw_sales;