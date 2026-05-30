-- ============================================================
-- 01_create_raw_tables.sql
-- DDL for all 6 raw staging tables
-- ============================================================

CREATE DATABASE IF NOT EXISTS vendor_analytics;
USE vendor_analytics;

DROP TABLE IF EXISTS raw_purchases;
CREATE TABLE raw_purchases (
    InventoryId     VARCHAR(50),
    Store           VARCHAR(20),
    Brand           VARCHAR(100),
    Description     VARCHAR(200),
    Size            VARCHAR(50),
    VendorNumber    VARCHAR(20),
    VendorName      VARCHAR(200),
    PONumber        VARCHAR(50),
    PODate          VARCHAR(30),
    ReceivingDate   VARCHAR(30),
    InvoiceDate     VARCHAR(30),
    PayDate         VARCHAR(30),
    PurchasePrice   DECIMAL(10,2),
    Quantity        INT,
    Dollars         DECIMAL(12,2),
    Classification  VARCHAR(50)
);

DROP TABLE IF EXISTS raw_end_inventory;
CREATE TABLE raw_end_inventory (
    InventoryId   VARCHAR(50),
    Store         VARCHAR(20),
    City          VARCHAR(100),
    Brand         VARCHAR(100),
    Description   VARCHAR(200),
    Size          VARCHAR(50),
    onHand        INT,
    Price         DECIMAL(10,2),
    endDate       VARCHAR(30)
);

DROP TABLE IF EXISTS raw_begin_inventory;
CREATE TABLE raw_begin_inventory (
    InventoryId   VARCHAR(50),
    Store         VARCHAR(20),
    City          VARCHAR(100),
    Brand         VARCHAR(100),
    Description   VARCHAR(200),
    Size          VARCHAR(50),
    onHand        INT,
    Price         DECIMAL(10,2),
    startDate     VARCHAR(30)
);

DROP TABLE IF EXISTS raw_purchase_prices;
CREATE TABLE raw_purchase_prices (
    Brand          VARCHAR(100),
    Description    VARCHAR(200),
    Price          DECIMAL(10,2),
    Size           VARCHAR(50),
    Volume         INT,
    Classification VARCHAR(50),
    PurchasePrice  DECIMAL(10,2)
);

DROP TABLE IF EXISTS raw_vendor_invoice;
CREATE TABLE raw_vendor_invoice (
    VendorNumber  VARCHAR(20),
    VendorName    VARCHAR(200),
    InvoiceDate   VARCHAR(30),
    PONumber      VARCHAR(50),
    PayDate       VARCHAR(30),
    Quantity      INT,
    Dollars       DECIMAL(12,2),
    Freight       DECIMAL(10,2),
    Approval      VARCHAR(10)
);

DROP TABLE IF EXISTS raw_sales;
CREATE TABLE raw_sales (
    InventoryId   VARCHAR(50),
    Store         VARCHAR(20),
    Brand         VARCHAR(100),
    Description   VARCHAR(200),
    Size          VARCHAR(50),
    SalesQuantity INT,
    SalesPrice    DECIMAL(10,2),
    SalesDollars  DECIMAL(12,2),
    SalesDate     VARCHAR(30)
);

SELECT 'All raw tables created successfully' AS Status;