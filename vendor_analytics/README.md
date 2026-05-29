# Vendor Performance Analytics Platform

> End-to-end data analytics and machine learning platform for a multi-store liquor distribution business.
> Diagnoses vendor performance, forecasts demand, detects invoice anomalies, and delivers a quantified
> supplier portfolio rationalization backed by a full 2024 back-test.

---

## Project Overview

| Item | Detail |
|------|--------|
| **Business** | Multi-store liquor distribution |
| **Data** | 6 CSV source files, 500MB+, full 2024 |
| **Database** | MySQL 8.0, no downsampling |
| **Models** | Prophet, KMeans, RandomForest, IsolationForest |
| **Dashboard** | 4-page Power BI report |
| **Back-test savings** | $284,200 (statistically significant, p < 0.001) |

---

## Project Structure

```
vendor_analytics/
├── data/                             # Raw CSV source files (not committed to Git)
│   ├── purchases.csv
│   ├── end_inventory.csv
│   ├── purchase_prices.csv
│   ├── vendor_invoice.csv
│   └── ...
├── sql/
│   ├── 01_create_raw_tables.sql      # DDL for raw staging tables
│   ├── 02_load_data.sql              # LOAD DATA INFILE for all 6 CSVs
│   ├── 03_clean_and_model.sql        # Cleaning + star-schema creation
│   └── 04_powerbi_views.sql          # Pre-aggregated views for Power BI
├── notebooks/
│   ├── 01_data_loading.ipynb         # Load CSVs → MySQL, verify row counts
│   ├── 02_eda.ipynb                  # Exploratory data analysis
│   ├── 03_star_schema.ipynb          # Build 7 clean star-schema tables
│   ├── 04_kpis.ipynb                 # Revenue, COGS, margin, turnover, DoS
│   ├── 05_classification.ipynb       # ABC-XYZ, Pareto, vendor scorecard
│   ├── 06_statistics.ipynb           # t-tests, ANOVA, confidence intervals
│   ├── 07_vendor_clustering.ipynb    # KMeans vendor segmentation
│   ├── 08_deadstock_classifier.ipynb # RandomForest dead-stock prediction
│   ├── 09_invoice_anomalies.ipynb    # IsolationForest anomaly detection
│   ├── 10_forecasting.ipynb          # Prophet demand forecasting (500 SKUs)
│   ├── 11_backtest.ipynb             # Forecast-driven reorder back-test
│   └── 12_powerbi_prep.ipynb         # Create SQL views for Power BI
├── src/
│   ├── db_connection.py              # SQLAlchemy engine factory
│   ├── kpi_calculator.py             # KPI computation functions
│   ├── scorecard.py                  # Vendor scorecard logic
│   ├── forecasting.py                # Prophet training utilities
│   └── backtest.py                   # Back-test simulation engine
├── models/
│   ├── prophet_models.pkl            # 487 trained Prophet models
│   ├── kmeans_vendor.pkl             # KMeans vendor clustering model
│   ├── kmeans_scaler.pkl             # StandardScaler for clustering
│   ├── rf_deadstock.pkl              # RandomForest dead-stock classifier
│   ├── isoforest_anomaly.pkl         # IsolationForest anomaly detector
│   └── isoforest_scaler.pkl          # StandardScaler for anomaly detection
├── outputs/
│   ├── vendor_analytics.pbix         # Power BI dashboard (4 pages)
│   ├── vendor_analytics_report.docx  # Final written report (9 sections)
│   ├── forecast_mape_scores.csv      # Per-model MAPE results
│   ├── flagged_invoices.csv          # Anomaly detection output
│   ├── vendor_clusters_pca.png       # Cluster visualization
│   ├── vendor_clustering_elbow.png   # Elbow + silhouette plot
│   ├── deadstock_classifier.png      # Confusion matrix + feature importance
│   └── best_forecast.png             # Best Prophet forecast visualization
├── requirements.txt                  # Pinned Python dependencies
└── README.md                         # This file
```

---

## Prerequisites

Before you begin, make sure the following are installed on your machine:

| Tool | Version | Download |
|------|---------|----------|
| MySQL Server | 8.0 | https://dev.mysql.com/downloads/mysql/ |
| MySQL Workbench | 8.0 | https://dev.mysql.com/downloads/workbench/ |
| Python | 3.11 | https://www.python.org/downloads/ |
| VS Code | Latest | https://code.visualstudio.com/ |
| Power BI Desktop | Latest | https://powerbi.microsoft.com/desktop/ |
| Git | Latest | https://git-scm.com/downloads |

> **Important — Python install tip:**
> When installing Python, on the very first screen of the installer
> check the box that says **"Add Python to PATH"** before clicking Install.
> If you miss this, pip commands will not work in the terminal.

---

## Step-by-Step Setup

### Step 1 — Clone the Repository

Open Command Prompt (press `Windows + R`, type `cmd`, press Enter) and run:

```bash
cd Desktop
git clone https://github.com/YOUR_USERNAME/vendor-analytics-platform.git
cd vendor-analytics-platform
```

### Step 2 — Install Python Dependencies

In the same Command Prompt window (make sure you are inside the project folder):

```bash
pip install -r requirements.txt
```

This installs all required libraries at pinned versions. Takes 5–10 minutes.
If `pip` is not recognised, use `python -m pip install -r requirements.txt` instead.

---

### Step 3 — MySQL Database Setup

#### 3a — Create the database

Open **MySQL Workbench** and connect to your local instance.
Click in the query area and run:

```sql
CREATE DATABASE vendor_analytics;
USE vendor_analytics;
```

Click the **lightning bolt ⚡ button** to execute.
You should see "1 row(s) affected" at the bottom.

#### 3b — MySQL credentials you will need

Every notebook connects to MySQL using SQLAlchemy.
The connection string format is:

```
mysql+pymysql://USERNAME:PASSWORD@HOST/DATABASE
```

The default values for a local installation are:

| Setting | Default Value | Where to change it |
|---------|--------------|-------------------|
| USERNAME | `root` | Set during MySQL installation |
| PASSWORD | *(what you set during install)* | Set during MySQL installation |
| HOST | `localhost` | Do not change unless on a remote server |
| DATABASE | `vendor_analytics` | Must match what you created in Step 3a |

So your connection string will look like:

```python
engine = create_engine('mysql+pymysql://root:mysql123@localhost/vendor_analytics')
```

> **Forgot your MySQL password?**
> Open MySQL Workbench → click the gear icon next to your connection →
> you can reset or view credentials there. Alternatively reinstall MySQL
> and set a new password during setup.

#### 3c — Update password in all notebooks

your password is "mysql123"

#### 3d — Enable LOAD DATA INFILE in MySQL

Some MySQL installations disable local file loading by default.
Run this in MySQL Workbench to enable it:

```sql
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
-- Should show: local_infile | ON
```

#### 3e — Place your CSV files

Copy all 6 CSV source files into the `data/` folder of this project.
The notebooks expect them at these relative paths:

```
data/purchases.csv
data/end_inventory.csv
data/purchase_prices.csv
data/vendor_invoice.csv
data/begin_inventory.csv      (if available)
data/sales.csv                (if available)
```

---

### Step 4 — Run Notebooks in Order

Open VS Code. Click **File → Open Folder** and select the project folder.
Install the **Jupyter** and **Python** extensions if prompted.

Run each notebook **strictly in order** — each one depends on the previous:

| # | Notebook | Est. Time |
|---|----------|-----------|
| 01 | 01_data_loading.ipynb | 5–15 min |
| 02 | 02_eda.ipynb | 2 min |
| 03 | 03_star_schema.ipynb | 3 min |
| 04 | 04_kpis.ipynb | 2 min |
| 05 | 05_classification.ipynb | 2 min |
| 06 | 06_statistics.ipynb | 1 min |
| 07 | 07_vendor_clustering.ipynb | 2 min |
| 08 | 08_deadstock_classifier.ipynb | 3 min |
| 09 | 09_invoice_anomalies.ipynb | 2 min |
| 10 | 10_forecasting.ipynb | **20–40 min** |
| 11 | 11_backtest.ipynb | 3 min |
| 12 | 12_powerbi_prep.ipynb | 1 min |

To run a notebook: open it, click **Select Kernel → Python 3.11**,
then press **Run All** (double arrow button at the top).

> **Tip:** Start Notebook 10 (Prophet forecasting) running and
> work on the Power BI dashboard while it completes in the background.

---

### Step 5 — Power BI Dashboard Setup

1. Open `outputs/vendor_analytics.pbix` in **Power BI Desktop**
2. You will see a connection error — this is expected on a new machine
3. Click **Transform Data → Data Source Settings**
4. Click **Change Source** and update:
   - Server: `localhost`
   - Database: `vendor_analytics`
5. Click **OK**, then click **Apply Changes**
6. When prompted for credentials:
   - Authentication type: **Database**
   - Username: `root`
   - Password: *mysql123*
7. Click **Connect**, then **Refresh All**

All four pages should now populate with your data.

---

## Troubleshooting

### "pip is not recognised"
Python was not added to PATH during installation.
Fix: reinstall Python and check **"Add Python to PATH"** on the first screen.
Or run: `python -m pip install -r requirements.txt`

### "Access denied for user root"
Your MySQL password is wrong in the connection string.
Fix: open MySQL Workbench, right-click your connection → Edit Connection
→ check the stored password. Update `your_password` in the notebooks.

### "Can't connect to MySQL server on localhost"
MySQL service is not running.
Fix: press `Windows + R` → type `services.msc` → find **MySQL80** →
right-click → Start.

### "Table doesn't exist" error in a notebook
You skipped a previous notebook or it did not complete successfully.
Fix: go back and re-run notebooks in order starting from the one that failed.

### Prophet notebook takes too long
This is expected — 487 models take 20–40 minutes.
Do not interrupt it. Let it run to completion.

### Power BI shows blank visuals
The MySQL views may not have been created yet.
Fix: run Notebook 12 first, then refresh Power BI.

---

## Tech Stack

| Layer | Tool | Version |
|-------|------|---------|
| Database | MySQL | 8.0 |
| SQL IDE | MySQL Workbench | 8.0 |
| Language | Python | 3.11 |
| Data manipulation | pandas | 2.2.2 |
| SQL bridge | SQLAlchemy + PyMySQL | 2.0.30 + 1.1.0 |
| Statistical testing | scipy.stats | 1.13.0 |
| ML framework | scikit-learn | 1.4.2 |
| Forecasting | Prophet | 1.1.5 |
| Visualization | matplotlib + seaborn | 3.8.4 + 0.13.2 |
| Model persistence | joblib | 1.4.2 |
| IDE | VS Code + Jupyter | latest |
| Dashboard | Power BI Desktop | latest |
| Report | Microsoft Word | .docx |

---

## Key Results

| Acceptance Criterion | Target | Result | Status |
|----------------------|--------|--------|--------|
| Prophet MAPE — top 100 SKUs | < 25% | 18.4% | ✅ MET |
| KMeans silhouette score | > 0.40 | 0.52 | ✅ MET |
| RandomForest F1 score | > 0.70 | 0.74 | ✅ MET |
| Significant statistical tests | ≥ 3 | 4 | ✅ MET |
| Back-test net savings (p < 0.05) | > $0 | $284,200 | ✅ MET |
| Power BI pages populated | 4 of 4 | 4 of 4 | ✅ MET |
| Notebook reproducibility | 100% | 100% | ✅ MET |
| Source data loaded (no sampling) | 100% | 100% | ✅ MET |

---

## Reproducibility

All notebooks use `random_state=42` for fully deterministic results.
Run notebooks in order 01 → 12 on a fresh MySQL database for identical output.

```python
# Deterministic seeds used throughout
RANDOM_STATE = 42   # KMeans, RandomForest, IsolationForest, train_test_split
```

---

## Data Notes

- Raw CSV files are **not committed** to this repository (too large)
- Place your 6 CSV files in the `data/` folder before running Notebook 01
- Dead-stock definition: zero purchase activity in final 60 days of 2024
- All text fields normalised (trimmed + uppercased) to prevent join failures
- Single-currency dataset — no multi-currency conversion required

---

## Author

Ejaz | Vendor Performance Analytics Project | 2024

---

## License

This project is for internal business use only. Not for public distribution.
