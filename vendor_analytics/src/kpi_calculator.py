import pandas as pd

def compute_vendor_kpis(purchases_df):
    kpis = purchases_df.groupby('vendor_number').agg(
        revenue       =('dollars',           'sum'),
        total_qty     =('quantity',          'sum'),
        avg_lead_time =('lead_time_days',    'mean'),
        avg_pay_cycle =('payment_cycle_days','mean'),
        order_count   =('po_number',         'nunique')
    ).reset_index()
    kpis['cogs']         = kpis['revenue'] * 0.72
    kpis['gross_profit'] = kpis['revenue'] - kpis['cogs']
    kpis['margin_pct']   = (kpis['gross_profit'] / kpis['revenue'] * 100).round(2)
    return kpis

def compute_sku_kpis(purchases_df):
    return purchases_df.groupby('brand').agg(
        revenue     =('dollars',   'sum'),
        total_qty   =('quantity',  'sum'),
        order_count =('po_number', 'nunique')
    ).reset_index().sort_values('revenue', ascending=False)

def compute_store_kpis(purchases_df):
    return purchases_df.groupby('store').agg(
        revenue     =('dollars',   'sum'),
        total_qty   =('quantity',  'sum'),
        order_count =('po_number', 'nunique')
    ).reset_index().sort_values('revenue', ascending=False)

def compute_days_of_supply(inventory_df, kpi_df):
    merged = inventory_df.merge(kpi_df[['brand','revenue']], on='brand', how='left')
    merged['cogs']               = merged['revenue'] * 0.72
    merged['inventory_turnover'] = (merged['cogs'] / merged['inventory_value'].replace(0, float('nan'))).round(2)
    merged['days_of_supply']     = (365 / merged['inventory_turnover'].replace(0, float('nan'))).round(1)
    return merged