# history — Historical Capacity Rollups
This folder stores **time‑series capacity rollup snapshots** used by:
- [`capacity-trend-analysis.py`](../capacity-trend-analysis.py)
- [`capacity-trend-forecast.py`](../capacity-trend-forecast.py)
Each file represents a **single point in time** and contains:
- Compute capacity (cores, RAM)
- Storage capacity (GB)
- Network capacity (bandwidth)
## 📁 Structure
history/
2025-01-01.json
2025-01-02.json
...
2025-01-10.json
## 📊 Usage
Run trend analysis:
ROLLUP_INPUT_DIR=./history python3 ../capacity-trend-analysis.py
Run forecasting:
ROLLUP_INPUT_DIR=./history FORECAST_INTERVALS=12 python3 ../capacity-trend-forecast.py
## 📦 Notes
- Files must be valid JSON.
- Filenames should sort chronologically.
- Additional datasets (e.g., anomalies) can be stored in sibling folders.
