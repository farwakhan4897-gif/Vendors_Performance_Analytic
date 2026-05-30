import pandas as pd

def normalize(series, higher_is_better=True):
    """Normalize a series to 0-100 scale."""
    mn, mx = series.min(), series.max()
    if mx == mn:
        return pd.Series([50] * len(series), index=series.index)
    n = (series - mn) / (mx - mn) * 100
    return n if higher_is_better else 100 - n

def build_scorecard(vendor_kpis_df):
    """
    Build composite vendor scorecard.
    Weights: margin 25%, lead time 25%, revenue 20%, pay cycle 15%, orders 15%
    """
    df = vendor_kpis_df.copy()
    df['score_margin']   = normalize(df['margin_pct'],    higher_is_better=True)
    df['score_leadtime'] = normalize(df['avg_lead_time'], higher_is_better=False)
    df['score_paycycle'] = normalize(df['avg_pay_cycle'], higher_is_better=False)
    df['score_revenue']  = normalize(df['revenue'],       higher_is_better=True)
    df['score_orders']   = normalize(df['order_count'],   higher_is_better=True)

    df['composite_score'] = (
        df['score_margin']   * 0.25 +
        df['score_leadtime'] * 0.25 +
        df['score_revenue']  * 0.20 +
        df['score_paycycle'] * 0.15 +
        df['score_orders']   * 0.15
    ).round(2)

    df['rank'] = df['composite_score'].rank(ascending=False).astype(int)
    return df.sort_values('rank').reset_index(drop=True)