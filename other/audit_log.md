# 📋 Project Audit Log

<p align="center">
  <img src="https://img.shields.io/badge/Project-Optimus%20Pride-blue?style=for-the-badge" alt="Project">
  <img src="https://img.shields.io/badge/Canvas-Team%206-orange?style=for-the-badge" alt="Team">
  <img src="https://img.shields.io/badge/Total%20Checks-9-green?style=for-the-badge" alt="Total Checks">
  <img src="https://img.shields.io/badge/Dataset-Chicago%20Taxi-yellow?style=for-the-badge" alt="Dataset">
</p>

This log tracks all substantive data verification checks, pipeline adjustments, and analytical corrections performed by **Team Optimus Pride** on the Chicago Taxi Trips dataset (`bigquery-public-data.chicago_taxi_trips.taxi_trips`) in Google Cloud BigQuery project `big-query-509700`.

---

## 📊 Summary by Category

| Category | Description | Count | Quick Link |
|---|---|:---:|---|
| **Caught an error** | Detected data omissions, pipeline bugs, or misleading artifacts | 2 | [Jump to Section](#-1-caught-an-error) |
| **Verified a claim** | Confirmed data completeness, distribution shapes, or external IDs with ground truth | 3 | [Jump to Section](#-2-verified-a-claim) |
| **Separated fact from opinion** | Isolated empirical metrics from modeling assumptions and business interpretations | 2 | [Jump to Section](#-3-separated-fact-from-opinion) |
| **Changed the analysis** | Shifted methodological approach, baseline filters, or feature engineering | 1 | [Jump to Section](#-4-changed-the-analysis) |
| **Improved the agent's instructions** | Refined prompt guidance, analytical constraints, or documentation habits | 1 | [Jump to Section](#-5-improved-the-agents-instructions) |
| **Total** | | **9** | |

---

## 🚨 1. Caught an error

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 1 | Date range of the first copy of the data | Ran `MIN` and `MAX` on `trip_start_timestamp` | First trip was June 30, 2021, meaning January to June 2021 was completely missing from the public table | Switched the analysis window to the complete calendar years 2022 and 2023 |
| 2 | Outlier influence on neighborhood benchmarks | Inspected top fare-per-taxi rankings across pickup community areas | Pickup area 76 topped the results with revenue rates dramatically exceeding standard urban sectors | Excluded areas 76 and 56 from the neighborhood benchmark so airport demand spikes do not distort urban targets |

---

## ✅ 2. Verified a claim

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 3 | Date range and record count of the analytical table | Ran `MIN`, `MAX`, and `COUNT(*)` on `taxi_2022_2023` | Table spans January 1, 2022 to December 31, 2023 with exactly 12,782,991 trips | Confirmed the curated table is temporally complete and ready for downstream modeling |
| 4 | Existence of empirical earnings spread across zones | Evaluated fare per taxi by pickup area and hour (760 slots with 1,000+ trips) | Lowest was \$18.01, 25th percentile \$68.87, median \$108.41, 75th percentile \$160.84, and highest \$2,774.18 | Verified that a wide performance dispersion exists across areas, confirming an opportunity gap is mathematically possible |
| 5 | Official community area airport designations | Cross-referenced City of Chicago 77 Community Area GIS maps with area IDs 76 and 56 | Area 76 is officially **O'Hare**, and Area 56 is **Garfield Ridge** (location of Midway International Airport) | Validated that excluding areas 76 and 56 accurately isolates the two commercial airports from neighborhood benchmarks |

---

## ⚖️ 3. Separated fact from opinion

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 6 | Fair benchmarking across diurnal cycles | Evaluated whether lower nighttime earnings represented underperformance or natural demand drops | Comparing an area at 4:00 AM to a midday benchmark would falsely classify normal sleep cycles as lost revenue | Stratified benchmarks by hour of day (comparing areas only to peers within the exact same hour), setting the benchmark at the 75th percentile |
| 7 | Magnitude and nature of the opportunity gap | Calculated $\sum (\text{Benchmark} - \text{Actual}) \times \text{Taxis}$ for slots below benchmark | Calculated a \$22,696,763 gap against \$140,871,668 in total analyzed fares (16.1%) | Explicitly qualified the finding as **"up to \$22.7M"** because the gap is a theoretical ceiling contingent on benchmark choice and driver repositioning |

---

## 🔄 4. Changed the analysis

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 8 | Analytical granularity and fleet productivity metric | Rebuilt the analytical table with 11 columns, including `taxi_id` | Having `taxi_id` enabled calculating unique active vehicles per area-hour slot | Adopted **Fare per Taxi** rather than total area revenue as the core productivity metric to isolate vehicle yield from fleet density |

---

## 🛠️ 5. Improved the agent's instructions

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 9 | Audit protocol workflow and AI logging rules | Formalized the `project-audit` skill and verification procedure | Ad-hoc checks were uncataloged and lacked uniform category standards | Codified the 5-category taxonomy, required pre-commit reviews for additions, and enforced strict column consistency across all future checks |

---

## 📌 Next Steps & Open Items

- [ ] **Dual Benchmark Sensitivity:** Re-run gap estimation using the **50th percentile (median)** benchmark to establish a lower-bound conservative range alongside the 75th percentile.
- [ ] **Global Fare Reconciliation:** Compare aggregated slot fares to an unconditional `SUM(fare)` on the full `taxi_2022_2023` table to verify accounting reconciliation.
- [ ] **SQL Query Archiving:** Save the extraction, aggregation, and percentile calculation scripts into the [sql/](file:///c:/Users/nerly/busm410-optimuspride/sql/) folder.
