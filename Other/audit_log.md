# 📋 Project Audit Log

<p align="center">
  <img src="https://img.shields.io/badge/Project-Optimus%20Pride-blue?style=for-the-badge" alt="Project">
  <img src="https://img.shields.io/badge/Canvas-Team%206-orange?style=for-the-badge" alt="Team">
  <img src="https://img.shields.io/badge/Total%20Checks-20-green?style=for-the-badge" alt="Total Checks">
  <img src="https://img.shields.io/badge/Dataset-Chicago%20Taxi-yellow?style=for-the-badge" alt="Dataset">
</p>

This log tracks all substantive data verification checks, pipeline adjustments, and analytical corrections performed by **Team Optimus Pride** on the Chicago Taxi Trips dataset (`bigquery-public-data.chicago_taxi_trips.taxi_trips`) in Google Cloud BigQuery project `big-query-509700`.

> **Note (November 10, 2026):** Checks 1–9 are from our first approach (fare per taxi by pickup area and hour, 2022–2023). On November 10 we changed our gap to the decline in taxi trips from 2017 to 2019 (see check 17). Checks 10–20 are for the new gap. We keep the older checks as a true record of our work.

---

## 📊 Summary by Category

| Category | Description | Count | Quick Link |
|---|---|:---:|---|
| **Caught an error** | Detected data omissions, pipeline bugs, or misleading artifacts | 5 | [Jump to Section](#-1-caught-an-error) |
| **Verified a claim** | Confirmed data completeness, distribution shapes, or external IDs with ground truth | 7 | [Jump to Section](#-2-verified-a-claim) |
| **Separated fact from opinion** | Isolated empirical metrics from modeling assumptions and business interpretations | 4 | [Jump to Section](#-3-separated-fact-from-opinion) |
| **Changed the analysis** | Shifted methodological approach, baseline filters, or feature engineering | 2 | [Jump to Section](#-4-changed-the-analysis) |
| **Improved the agent's instructions** | Refined prompt guidance, analytical constraints, or documentation habits | 2 | [Jump to Section](#-5-improved-the-agents-instructions) |
| **Total** | | **20** | |

---

## 🚨 1. Caught an error

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 1 | Date range of the first copy of the data | Ran `MIN` and `MAX` on `trip_start_timestamp` | First trip was June 30, 2021, meaning January to June 2021 was completely missing from the public table | Switched the analysis window to the complete calendar years 2022 and 2023 |
| 2 | Outlier influence on neighborhood benchmarks | Inspected top fare-per-taxi rankings across pickup community areas | Pickup area 76 topped the results with revenue rates dramatically exceeding standard urban sectors | Excluded areas 76 and 56 from the neighborhood benchmark so airport demand spikes do not distort urban targets |
| 10 | Whether the 2019 drop in trips was real | Counted rows by month for 2017 onward (`sql/02_month_coverage.sql`) | 2019 is normal from January to May, then breaks: June 1,437,273, July 114,692, October 11, and no rows for November or December. The full-year "54% drop" was mostly missing data | Limited all three years to January–May. Threw out the first value estimate (about $274M), which was built on the missing months |
| 11 | Whether each row is one trip | Compared `COUNT(*)` with `COUNT(DISTINCT unique_key)` for Jan–May (`sql/03_cleaning_checks.sql`) | Millions of duplicate rows: 3,039,473 extra copies in 2017, 4,519,417 in 2018, and 5,307,765 in 2019. Row counts made the drop look like 10% when it is really 34% | Count each `unique_key` once in the gap query (`sql/05_gap.sql`) |
| 12 | Whether 2022–2023 in the public table is complete | Same monthly count as check 10 | In the public table today, 2022 starts in March with 7,624 rows and May 2022 has 17,117 rows. 2022 and 2023 together have 10,908,976 rows, which does not match the 12,782,991 trips in our earlier `taxi_2022_2023` table (check 3) | Did not use 2022–2023 for the new gap. We have not found out why the two counts differ |

---

## ✅ 2. Verified a claim

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 3 | Date range and record count of the analytical table | Ran `MIN`, `MAX`, and `COUNT(*)` on `taxi_2022_2023` | Table spans January 1, 2022 to December 31, 2023 with exactly 12,782,991 trips | Confirmed the curated table is temporally complete and ready for downstream modeling |
| 4 | Existence of empirical earnings spread across zones | Evaluated fare per taxi by pickup area and hour (760 slots with 1,000+ trips) | Lowest was \$18.01, 25th percentile \$68.87, median \$108.41, 75th percentile \$160.84, and highest \$2,774.18 | Verified that a wide performance dispersion exists across areas, confirming an opportunity gap is mathematically possible |
| 5 | Official community area airport designations | Cross-referenced City of Chicago 77 Community Area GIS maps with area IDs 76 and 56 | Area 76 is officially **O'Hare**, and Area 56 is **Garfield Ridge** (location of Midway International Airport) | Validated that excluding areas 76 and 56 accurately isolates the two commercial airports from neighborhood benchmarks |
| 13 | That removing duplicates is safe | Counted trips whose copies disagree on fare or start time (`sql/04_duplicate_check.sql`) | 0 trips have copies that disagree. Every duplicate is an exact copy | Kept one row per `unique_key`, knowing no information is lost |
| 14 | Blank, impossible, and future values in the gap columns | Counted blank fares, fares of $0 or less, and future dates for Jan–May (`sql/03_cleaning_checks.sql`) | Blank fares: 148, 747, 933. Fares $0 or less: 8,524, 8,600, 9,833 (under 0.1% of rows). Future dates: 0 | Dropped rows with a blank fare or a fare of $0 or less |
| 15 | That the average fare is realistic | Compared our $13.20 average with the official City of Chicago taxi rate placard ($3.25 to start, $2.25 a mile) | A 4-mile ride comes to about $13, close to our average | Linked the placard in `findings.md` as a reasonableness check, and used the dataset's own `fare` column as the price source |
| 19 | Our claim that the Uber taxi option launched in Chicago in 2024 | Looked it up in news reports (ABC7 Chicago, Axios Chicago) | Confirmed. Riders could request a taxi in the Uber app starting April 11, 2024, through Uber's partnership with Arro and Curb | Used the exact date and linked both sources in `findings.md` |

---

## ⚖️ 3. Separated fact from opinion

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 6 | Fair benchmarking across diurnal cycles | Evaluated whether lower nighttime earnings represented underperformance or natural demand drops | Comparing an area at 4:00 AM to a midday benchmark would falsely classify normal sleep cycles as lost revenue | Stratified benchmarks by hour of day (comparing areas only to peers within the exact same hour), setting the benchmark at the 75th percentile |
| 7 | Magnitude and nature of the opportunity gap | Calculated $\sum (\text{Benchmark} - \text{Actual}) \times \text{Taxis}$ for slots below benchmark | Calculated a \$22,696,763 gap against \$140,871,668 in total analyzed fares (16.1%) | Explicitly qualified the finding as **"up to \$22.7M"** because the gap is a theoretical ceiling contingent on benchmark choice and driver repositioning |
| 16 | How we describe and value the drop | Compared our wording and value options against the query results | "Rapid decline" was not supported when row counts showed a 10% drop, so we waited. After cleaning, the numbers are −15.8% then −21.9%. Trips × average fare gives about $48.3M, but the fares actually collected fell by $37,516,155 | Report the percentages and the measured $37.5M. Label the yearly figure (about $90M) as our estimate. State that the cause of the drop is not proven by this data |
| 20 | Whether we can say Uber caused the drop in taxi trips | Checked what our data can show, and looked for an outside source | Our dataset has no ride-hailing trips, so it cannot prove the cause. A City of Chicago report found ride-hailing trips grew 271% from 2015 to 2018, which supports the idea | Wrote it in `findings.md` as our team's likely cause, clearly labeled as not tested. Wrote the Uber taxi option as a proposal, and noted our data ends before it launched |

---

## 🔄 4. Changed the analysis

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 8 | Analytical granularity and fleet productivity metric | Rebuilt the analytical table with 11 columns, including `taxi_id` | Having `taxi_id` enabled calculating unique active vehicles per area-hour slot | Adopted **Fare per Taxi** rather than total area revenue as the core productivity metric to isolate vehicle yield from fleet density |
| 17 | Which gap to use for CP1 | Compared the fare-per-taxi gap (2022–2023) with the trip decline (2017–2019) on how well each was checked and how easy it is to explain | The fare-per-taxi gap still had open items and its years have missing months (check 12). The trip decline had passed checks 10–15 | Helaman and Nerlyn agreed on November 10, 2026 to use the trip decline: Jan–May 2019 against Jan–May 2017 |

---

## 🛠️ 5. Improved the agent's instructions

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 9 | Audit protocol workflow and AI logging rules | Formalized the `project-audit` skill and verification procedure | Ad-hoc checks were uncataloged and lacked uniform category standards | Codified the 5-category taxonomy, required pre-commit reviews for additions, and enforced strict column consistency across all future checks |
| 18 | Whether the agent would repeat today's mistakes | Reviewed what went wrong in checks 10 and 11 | The agent's first drafts counted rows with `COUNT(*)` and compared full years | Added a "Project facts" section to `AGENTS.md` with cleaning rules: remove duplicates first, check months before comparing years, use Jan–May only |

---

## 📌 Next Steps & Open Items

- [ ] Break the trip decline down by pickup area, hour, and company to find where the loss is biggest.
- [ ] Find out why the public table has duplicate rows and missing months (checks 10–12).
- [ ] Test whether ride-hailing explains the drop, using a second data source.
- [x] Save our queries in the [`sql/`](../sql/) folder (done at CP1).

Dropped with the earlier approach (see check 17): the median benchmark re-run and the fare reconciliation on `taxi_2022_2023`.
