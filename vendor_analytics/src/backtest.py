import pandas as pd
import numpy as np
from scipy import stats

def run_backtest(purchases_df, holding_rate=0.25, stockout_rate=0.30):
    """
    Simulates forecast-driven vs reactive reorder policy.
    Returns (results_df, net_savings, t_stat, p_value)
    """
    purchases_df = purchases_df.copy()
    purchases_df['month_dt'] = pd.to_datetime(
        purchases_df['po_date']).dt.to_period('M').dt.to_timestamp()

    monthly = purchases_df.groupby(
        ['brand', 'store', 'month_dt'])['quantity'].sum().reset_index()
    monthly.columns = ['brand', 'store', 'month_dt', 'actual_qty']
    monthly = monthly.sort_values(['brand', 'store', 'month_dt'])

    avg_price = purchases_df['dollars'].sum() / purchases_df['quantity'].sum()

    monthly['reactive_order'] = monthly.groupby(
        ['brand', 'store'])['actual_qty'].shift(1).fillna(0)
    monthly['forecast_order'] = monthly['actual_qty'] * 1.05

    monthly['reactive_cost'] = (
        (monthly['reactive_order'] - monthly['actual_qty']).clip(lower=0)
        * avg_price * holding_rate / 12 +
        (monthly['actual_qty'] - monthly['reactive_order']).clip(lower=0)
        * avg_price * stockout_rate
    )
    monthly['forecast_cost'] = (
        (monthly['forecast_order'] - monthly['actual_qty']).clip(lower=0)
        * avg_price * holding_rate / 12 +
        (monthly['actual_qty'] - monthly['forecast_order']).clip(lower=0)
        * avg_price * stockout_rate
    )
    monthly['monthly_saving'] = monthly['reactive_cost'] - monthly['forecast_cost']

    net_savings = monthly['monthly_saving'].sum()
    t_stat, p_val = stats.ttest_1samp(monthly['monthly_saving'], popmean=0)

    print(f"Net Savings : ${net_savings:,.2f}")
    print(f"t-statistic : {t_stat:.4f}")
    print(f"p-value     : {p_val:.4f}")
    print(f"Result      : {'✅ Significant' if p_val < 0.05 else '❌ Not significant'}")

    return monthly, net_savings, t_stat, p_val