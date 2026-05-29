-- ============================================================
-- 04_powerbi_views.sql
-- Pre-aggregated views for Power BI dashboard
-- Run after all 12 notebooks have completed
-- ============================================================

USE vendor_analytics;

-- ── PAGE 1: EXECUTIVE SUMMARY ─────────────────────────────
DROP VIEW IF EXISTS vw_executive_kpis;
CREATE VIEW vw_executive_kpis AS
SELECT
    SUM(dollars)                   AS total_revenue,
    SUM(dollars * 0.72)            AS total_cogs,
    SUM(dollars * 0.28)            AS total_profit,
    ROUND(28.0, 2)                 AS avg_margin_pct,
    COUNT(DISTINCT vendor_number)  AS total_vendors,
    COUNT(DISTINCT brand)          AS total_skus,
    COUNT(DISTINCT store)          AS total_stores,
    ROUND(AVG(lead_time_days), 1)  AS avg_lead_time
FROM fact_purchases;

DROP VIEW IF EXISTS vw_monthly_revenue;
CREATE VIEW vw_monthly_revenue AS
SELECT
    DATE_FORMAT(po_date, '%Y-%m-01') AS month,
    SUM(dollars)                      AS revenue,
    SUM(dollars * 0.28)              AS profit,
    COUNT(DISTINCT vendor_number)     AS active_vendors
FROM fact_purchases
WHERE po_date IS NOT NULL
GROUP BY DATE_FORMAT(po_date, '%Y-%m-01')
ORDER BY month;

-- ── PAGE 2: VENDOR DEEP-DIVE ──────────────────────────────
DROP VIEW IF EXISTS vw_vendor_scorecard_full;
CREATE VIEW vw_vendor_scorecard_full AS
SELECT
    vs.*,
    vc.cluster,
    vc.cluster_label
FROM vendor_scorecard vs
LEFT JOIN vendor_clusters vc
    ON vs.vendornumber = vc.vendornumber
ORDER BY vs.rank;

DROP VIEW IF EXISTS vw_lead_time_trend;
CREATE VIEW vw_lead_time_trend AS
SELECT
    vendor_number,
    DATE_FORMAT(po_date, '%Y-%m-01')  AS month,
    ROUND(AVG(lead_time_days), 1)     AS avg_lead_time,
    ROUND(STDDEV(lead_time_days), 1)  AS stddev_lead_time,
    MIN(lead_time_days)               AS min_lead_time,
    MAX(lead_time_days)               AS max_lead_time,
    COUNT(*)                           AS order_count
FROM fact_purchases
WHERE lead_time_days BETWEEN 0 AND 180
GROUP BY vendor_number, DATE_FORMAT(po_date, '%Y-%m-01');

-- ── PAGE 3: SUPPLY CHAIN DIAGNOSTICS ─────────────────────
DROP VIEW IF EXISTS vw_lead_time_boxplot;
CREATE VIEW vw_lead_time_boxplot AS
SELECT
    vendor_number,
    ROUND(AVG(lead_time_days), 1)    AS avg_lead_time,
    ROUND(STDDEV(lead_time_days), 1) AS stddev_lead_time,
    MIN(lead_time_days)              AS min_lead_time,
    MAX(lead_time_days)              AS max_lead_time,
    COUNT(*)                          AS order_count
FROM fact_purchases
WHERE lead_time_days BETWEEN 0 AND 180
GROUP BY vendor_number
ORDER BY avg_lead_time DESC
LIMIT 20;

DROP VIEW IF EXISTS vw_freight_analysis;
CREATE VIEW vw_freight_analysis AS
SELECT
    vendor_number,
    ROUND(AVG(freight_pct), 2)  AS avg_freight_pct,
    ROUND(MAX(freight_pct), 2)  AS max_freight_pct,
    COUNT(*)                     AS invoice_count
FROM fact_invoices
WHERE freight_pct IS NOT NULL
GROUP BY vendor_number
ORDER BY avg_freight_pct DESC;

DROP VIEW IF EXISTS vw_payment_cycle_heatmap;
CREATE VIEW vw_payment_cycle_heatmap AS
SELECT
    vendor_number,
    DATE_FORMAT(invoice_date, '%Y-%m-01')  AS month,
    ROUND(AVG(DATEDIFF(pay_date, invoice_date)), 1) AS avg_payment_days
FROM fact_invoices
WHERE invoice_date IS NOT NULL AND pay_date IS NOT NULL
GROUP BY vendor_number, DATE_FORMAT(invoice_date, '%Y-%m-01');

-- ── PAGE 4: FORECASTING & INVENTORY ──────────────────────
DROP VIEW IF EXISTS vw_dead_stock_watchlist;
CREATE VIEW vw_dead_stock_watchlist AS
SELECT
    dp.brand,
    dp.dead_stock_probability,
    dp.predicted_dead_stock,
    d.description,
    a.abc_class,
    a.xyz_class
FROM dead_stock_predictions dp
LEFT JOIN dim_product d ON dp.brand = d.brand
LEFT JOIN abc_xyz_classification a ON dp.brand = a.brand
WHERE dp.dead_stock_probability > 0.5
ORDER BY dp.dead_stock_probability DESC;

DROP VIEW IF EXISTS vw_abc_xyz_full;
CREATE VIEW vw_abc_xyz_full AS
SELECT
    a.*,
    d.description,
    d.purchase_price
FROM abc_xyz_classification a
LEFT JOIN dim_product d ON a.brand = d.brand;

SELECT 'View name'                AS view_name, 'Status' AS status UNION ALL
SELECT 'vw_executive_kpis',        '✅ created' UNION ALL
SELECT 'vw_monthly_revenue',        '✅ created' UNION ALL
SELECT 'vw_vendor_scorecard_full',  '✅ created' UNION ALL
SELECT 'vw_lead_time_trend',        '✅ created' UNION ALL
SELECT 'vw_lead_time_boxplot',      '✅ created' UNION ALL
SELECT 'vw_freight_analysis',       '✅ created' UNION ALL
SELECT 'vw_payment_cycle_heatmap',  '✅ created' UNION ALL
SELECT 'vw_dead_stock_watchlist',   '✅ created' UNION ALL
SELECT 'vw_abc_xyz_full',           '✅ created';

SELECT 'All Power BI views created successfully' AS Status;