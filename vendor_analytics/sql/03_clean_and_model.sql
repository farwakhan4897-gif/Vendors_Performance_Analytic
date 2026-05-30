-- ============================================================
-- 03_clean_and_model.sql
-- Builds 7 clean star-schema tables from raw staging tables
-- Note: full cleaning logic runs in notebook 03_star_schema.ipynb
-- ============================================================

USE vendor_analytics;

-- ── DIM_VENDOR ────────────────────────────────────────────
DROP TABLE IF EXISTS dim_vendor;
CREATE TABLE dim_vendor AS
SELECT DISTINCT
    TRIM(UPPER(VendorNumber)) AS vendor_number,
    TRIM(UPPER(VendorName))   AS vendor_name
FROM raw_purchases
WHERE VendorNumber IS NOT NULL AND VendorNumber != '';

ALTER TABLE dim_vendor ADD PRIMARY KEY (vendor_number);
SELECT 'dim_vendor:', COUNT(*) FROM dim_vendor;

-- ── DIM_PRODUCT ───────────────────────────────────────────
DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product AS
SELECT DISTINCT
    TRIM(UPPER(p.Brand))   AS brand,
    TRIM(p.Description)    AS description,
    p.Size                 AS size,
    p.PurchasePrice        AS purchase_price,
    COALESCE(pp.Price, p.PurchasePrice * 1.40) AS sale_price
FROM raw_purchases p
LEFT JOIN raw_purchase_prices pp
    ON TRIM(UPPER(p.Brand)) = TRIM(UPPER(pp.Brand))
WHERE p.Brand IS NOT NULL;

ALTER TABLE dim_product ADD PRIMARY KEY (brand);
SELECT 'dim_product:', COUNT(*) FROM dim_product;

-- ── DIM_STORE ─────────────────────────────────────────────
DROP TABLE IF EXISTS dim_store;
CREATE TABLE dim_store AS
SELECT DISTINCT
    TRIM(UPPER(Store)) AS store,
    TRIM(UPPER(City))  AS city
FROM raw_end_inventory
WHERE Store IS NOT NULL;

ALTER TABLE dim_store ADD PRIMARY KEY (store);
SELECT 'dim_store:', COUNT(*) FROM dim_store;

-- ── FACT_PURCHASES ────────────────────────────────────────
DROP TABLE IF EXISTS fact_purchases;
CREATE TABLE fact_purchases AS
SELECT
    TRIM(UPPER(InventoryId))  AS inventory_id,
    TRIM(UPPER(Store))        AS store,
    TRIM(UPPER(Brand))        AS brand,
    TRIM(UPPER(VendorNumber)) AS vendor_number,
    PONumber                  AS po_number,
    STR_TO_DATE(PODate,        '%Y-%m-%d') AS po_date,
    STR_TO_DATE(ReceivingDate, '%Y-%m-%d') AS receiving_date,
    STR_TO_DATE(InvoiceDate,   '%Y-%m-%d') AS invoice_date,
    STR_TO_DATE(PayDate,       '%Y-%m-%d') AS pay_date,
    PurchasePrice              AS purchase_price,
    Quantity                   AS quantity,
    Dollars                    AS dollars,
    DATEDIFF(
        STR_TO_DATE(ReceivingDate, '%Y-%m-%d'),
        STR_TO_DATE(PODate,        '%Y-%m-%d')
    ) AS lead_time_days,
    DATEDIFF(
        STR_TO_DATE(PayDate,     '%Y-%m-%d'),
        STR_TO_DATE(InvoiceDate, '%Y-%m-%d')
    ) AS payment_cycle_days
FROM raw_purchases
WHERE PODate IS NOT NULL AND PODate != '';

CREATE INDEX idx_fp_vendor ON fact_purchases (vendor_number);
CREATE INDEX idx_fp_brand  ON fact_purchases (brand);
CREATE INDEX idx_fp_store  ON fact_purchases (store);
CREATE INDEX idx_fp_date   ON fact_purchases (po_date);
SELECT 'fact_purchases:', COUNT(*) FROM fact_purchases;

-- ── FACT_INVENTORY_END ────────────────────────────────────
DROP TABLE IF EXISTS fact_inventory_end;
CREATE TABLE fact_inventory_end AS
SELECT
    TRIM(UPPER(InventoryId)) AS inventory_id,
    TRIM(UPPER(Store))       AS store,
    TRIM(UPPER(Brand))       AS brand,
    onHand                   AS on_hand,
    Price                    AS price,
    (onHand * Price)         AS inventory_value,
    STR_TO_DATE(endDate, '%Y-%m-%d') AS end_date
FROM raw_end_inventory;

SELECT 'fact_inventory_end:', COUNT(*) FROM fact_inventory_end;

-- ── FACT_INVENTORY_BEGIN ──────────────────────────────────
DROP TABLE IF EXISTS fact_inventory_begin;
CREATE TABLE fact_inventory_begin AS
SELECT
    TRIM(UPPER(InventoryId)) AS inventory_id,
    TRIM(UPPER(Store))       AS store,
    TRIM(UPPER(Brand))       AS brand,
    onHand                   AS on_hand,
    Price                    AS price,
    (onHand * Price)         AS inventory_value,
    STR_TO_DATE(startDate, '%Y-%m-%d') AS start_date
FROM raw_begin_inventory;

SELECT 'fact_inventory_begin:', COUNT(*) FROM fact_inventory_begin;

-- ── FACT_INVOICES ─────────────────────────────────────────
DROP TABLE IF EXISTS fact_invoices;
CREATE TABLE fact_invoices AS
SELECT
    TRIM(UPPER(VendorNumber)) AS vendor_number,
    PONumber                  AS po_number,
    STR_TO_DATE(InvoiceDate, '%Y-%m-%d') AS invoice_date,
    STR_TO_DATE(PayDate,     '%Y-%m-%d') AS pay_date,
    Quantity                  AS quantity,
    Dollars                   AS dollars,
    COALESCE(Freight, 0)      AS freight,
    ROUND(COALESCE(Freight,0) / NULLIF(Dollars,0) * 100, 2) AS freight_pct
FROM raw_vendor_invoice;

SELECT 'fact_invoices:', COUNT(*) FROM fact_invoices;

-- ── FINAL SUMMARY ─────────────────────────────────────────
SELECT 'dim_vendor'           AS table_name, COUNT(*) AS rows FROM dim_vendor           UNION ALL
SELECT 'dim_product',                        COUNT(*)          FROM dim_product          UNION ALL
SELECT 'dim_store',                          COUNT(*)          FROM dim_store            UNION ALL
SELECT 'fact_purchases',                     COUNT(*)          FROM fact_purchases       UNION ALL
SELECT 'fact_inventory_end',                 COUNT(*)          FROM fact_inventory_end   UNION ALL
SELECT 'fact_inventory_begin',               COUNT(*)          FROM fact_inventory_begin UNION ALL
SELECT 'fact_invoices',                      COUNT(*)          FROM fact_invoices;

SELECT 'Star schema complete' AS Status;