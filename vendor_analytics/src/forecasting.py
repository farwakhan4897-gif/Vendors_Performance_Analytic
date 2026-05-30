import numpy as np
import warnings
import logging
warnings.filterwarnings('ignore')
logging.getLogger('prophet').setLevel(logging.ERROR)
logging.getLogger('cmdstanpy').setLevel(logging.ERROR)
from prophet import Prophet

def train_prophet_model(ts_df, cutoff=0.75):
    """
    Train a Prophet model on a time series DataFrame with columns [ds, y].
    Returns (model, forecast_df, mape_score).
    Returns (None, None, None) if not enough data.
    """
    if len(ts_df) < 15:
        return None, None, None

    split = int(len(ts_df) * cutoff)
    train = ts_df.iloc[:split].copy()
    test  = ts_df.iloc[split:].copy()

    if len(train) < 10 or len(test) < 3:
        return None, None, None

    m = Prophet(
        yearly_seasonality='auto',
        weekly_seasonality='auto',
        daily_seasonality=False,
        interval_width=0.80,
        changepoint_prior_scale=0.05
    )
    m.fit(train)

    future   = m.make_future_dataframe(periods=len(test))
    forecast = m.predict(future)

    y_true = test['y'].values
    y_pred = forecast.tail(len(test))['yhat'].clip(lower=0).values
    mask   = y_true > 0

    if mask.sum() < 3:
        return m, forecast, 99.0

    mape = np.mean(np.abs((y_true[mask] - y_pred[mask]) / y_true[mask])) * 100
    return m, forecast, round(min(mape, 999), 2)