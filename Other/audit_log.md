# 📋 Project Audit Log

<p align="center">
  <img src="https://img.shields.io/badge/Project-Optimus%20Pride-blue?style=for-the-badge" alt="Project">
  <img src="https://img.shields.io/badge/Canvas-Team%206-orange?style=for-the-badge" alt="Team">
  <img src="https://img.shields.io/badge/Total%20Checks-35-green?style=for-the-badge" alt="Total Checks">
  <img src="https://img.shields.io/badge/Dataset-Chicago%20Taxi-yellow?style=for-the-badge" alt="Dataset">
</p>

This log tracks all substantive data verification checks, pipeline adjustments, and analytical corrections performed by **Team Optimus Pride** on the Chicago Taxi Trips dataset (`bigquery-public-data.chicago_taxi_trips.taxi_trips`) in Google Cloud BigQuery project `big-query-509700`.

> **Note (November 10, 2026):** Checks 1–9 are from our first approach (fare per taxi by pickup area and hour, 2022–2023). On November 10 we changed our gap to the decline in taxi trips from 2017 to 2019 (see check 17). Checks 10–31 are for the new gap and the CP2 analysis table. We keep the older checks as a true record of our work.

---

## 📊 Summary by Category

| Category | Description | Count | Quick Link |
|---|---|:---:|---|
| **Caught an error** | Detected data omissions, pipeline bugs, or misleading artifacts | 6 | [Jump to Section](#-1-caught-an-error) |
| **Verified a claim** | Confirmed data completeness, distribution shapes, or external IDs with ground truth | 14 | [Jump to Section](#-2-verified-a-claim) |
| **Separated fact from opinion** | Isolated empirical metrics from modeling assumptions and business interpretations | 7 | [Jump to Section](#-3-separated-fact-from-opinion) |
| **Changed the analysis** | Shifted methodological approach, baseline filters, or feature engineering | 4 | [Jump to Section](#-4-changed-the-analysis) |
| **Improved the agent's instructions** | Refined prompt guidance, analytical constraints, or documentation habits | 4 | [Jump to Section](#-5-improved-the-agents-instructions) |
| **Total** | | **35** | |

---

## 🚨 1. Caught an error

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 1 | Date range of the first copy of the data | Ran `MIN` and `MAX` on `trip_start_timestamp` | First trip was June 30, 2021, meaning January to June 2021 was completely missing from the public table | Switched the analysis window to the complete calendar years 2022 and 2023 |
| 2 | Outlier influence on neighborhood benchmarks | Inspected top fare-per-taxi rankings across pickup community areas | Pickup area 76 topped the results with revenue rates dramatically exceeding standard urban sectors | Excluded areas 76 and 56 from the neighborhood benchmark so airport demand spikes do not distort urban targets |
| 10 | Whether the 2019 drop in trips was real | Counted rows by month for 2017 onward (`sql/02_month_coverage.sql`) | 2019 is normal from January to May, then breaks: June 1,437,273, July 114,692, October 11, and no rows for November or December. The full-year "54% drop" was mostly missing data | Limited all three years to January–May. Threw out the first value estimate (about $274M), which was built on the missing months |
| 11 | Whether each row is one trip | Compared `COUNT(*)` with `COUNT(DISTINCT unique_key)` for Jan–May (`sql/03_cleaning_checks.sql`) | Millions of duplicate rows: 3,039,473 extra copies in 2017, 4,519,417 in 2018, and 5,307,765 in 2019. Row counts made the drop look like 10% when it is really 34% | Count each `unique_key` once in the gap query (`sql/05_gap.sql`) |
| 12 | Whether 2022–2023 in the public table is complete | Same monthly count as check 10 | In the public table today, 2022 starts in March with 7,624 rows and May 2022 has 17,117 rows. 2022 and 2023 together have 10,908,976 rows, which does not match the 12,782,991 trips in our earlier `taxi_2022_2023` table (check 3) | Did not use 2022–2023 for the new gap. We have not found out why the two counts differ |
| 21 | Whether our CP1 numbers still hold | Re-ran the CP1 gap query (`sql/05_gap.sql`) on November 19, after the new analysis table's totals did not match (`sql/09_rerun_gap_check.sql`) | The same query now gives 10,566,675 / 8,861,212 / 6,925,134 trips (2017 / 2018 / 2019), about 1% fewer than on November 10 (10,664,759 / 8,974,977 / 7,007,630). The public table changed, our query did not | Updated every number in `findings.md`, `README.md`, `charter.md`, `AGENTS.md`, `sql/README.md`, and the chart. The gap went from 34.3% to 34.5% and the value from $37.5M to $36.5M, so the finding holds |

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
| 24 | Whether every row's outcome is settled | Looked at the analysis table: 1,170 rows = 78 areas × 5 months × 3 years, and January to May 2019 is complete (check 10) | Every area has a row for every month in all three years. No half-finished months | Kept all 1,170 rows. June to December stay out |
| 25 | Blanks replaced with real values, then counted | Used `IFNULL` for the pickup area (becomes "unknown") and average miles (becomes 0), then counted blanks in every column (`sql/07_check_analysis_table.sql`) | 0 rows with a blank in any column | Nothing to fix. Trips with no pickup area stay in as "unknown", so the totals still match CP1 |
| 26 | Impossible values in the new columns | Counted zero or negative trips, negative miles, and cash share outside 0 to 1, and looked at the smallest and largest values | 0 of each. Average trip length runs from 0.76 to 15.79 miles. Highest cash share is 1.0, so the cash column works | Nothing to remove |
| 27 | A key number, checked a second way | Added up `trips` by year from `analysis_table` and compared it with the CP1 gap query re-run on the raw table (`sql/08_second_way_check.sql`, `sql/09_rerun_gap_check.sql`) | Both give 10,566,675 / 8,861,212 / 6,925,134. The table did not lose or double-count any trips | Confirmed the analysis table is correct. The difference from November 10 comes from the public data (check 21) |
| 29 | The model results, read from BigQuery | Ran `ML.EVALUATE` and `ML.ADVANCED_WEIGHTS` (`sql/17`, `sql/18`). BigQuery cut off the end of the tiny p-values, so we re-ran the weights with `FORMAT` (`sql/19_model_weights_readable.sql`) | Full values: unknown p = 1.843e-09, airport p = 4.946e-05, downtown p = 0. r2_score = 0.353 | Used the full p-values in `model/model_card.md`, so no driver was called clear or unclear from a cut-off number |
| 32 | Specificity of the CP3 recommendation | Checked `charter.md` against CP3 rubric requirements (what, who [job title], where, and based on strongest driver) | Verified recommendation explicitly names Operations Manager, Uber app integration, and the 4 Downtown zones (8, 28, 32, 33) based on +310,110 regression driver | Formatted recommendation in `charter.md` and `findings.md` |
| 35 | Draft presentation slides alignment | Verified `slides.pdf` against rubric requirements (7-slide outline, landscape, clear takeaway titles) | Verified all 7 slides cover Gap, Data, Drivers, Recommendation, Scenarios, and Speed Critique questions | Generated `slides.pdf` ready for in-class speed critique |

---

## ⚖️ 3. Separated fact from opinion

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 6 | Fair benchmarking across diurnal cycles | Evaluated whether lower nighttime earnings represented underperformance or natural demand drops | Comparing an area at 4:00 AM to a midday benchmark would falsely classify normal sleep cycles as lost revenue | Stratified benchmarks by hour of day (comparing areas only to peers within the exact same hour), setting the benchmark at the 75th percentile |
| 7 | Magnitude and nature of the opportunity gap | Calculated $\sum (\text{Benchmark} - \text{Actual}) \times \text{Taxis}$ for slots below benchmark | Calculated a \$22,696,763 gap against \$140,871,668 in total analyzed fares (16.1%) | Explicitly qualified the finding as **"up to \$22.7M"** because the gap is a theoretical ceiling contingent on benchmark choice and driver repositioning |
| 16 | How we describe and value the drop | Compared our wording and value options against the query results | "Rapid decline" was not supported when row counts showed a 10% drop, so we waited. After cleaning, the numbers are −15.8% then −21.9%. Trips × average fare gives about $48.3M, but the fares actually collected fell by $37,516,155 | Report the percentages and the measured $37.5M. Label the yearly figure (about $90M) as our estimate. State that the cause of the drop is not proven by this data |
| 20 | Whether we can say Uber caused the drop in taxi trips | Checked what our data can show, and looked for an outside source | Our dataset has no ride-hailing trips, so it cannot prove the cause. A City of Chicago report found ride-hailing trips grew 271% from 2015 to 2018, which supports the idea | Wrote it in `findings.md` as our team's likely cause, clearly labeled as not tested. Wrote the Uber taxi option as a proposal, and noted our data ends before it launched |
| 23 | Whether `cash_share` and `avg_trip_miles` are fair X's | Looked at how both are made: they are averages of the same trips we count, in the same month | They describe the kind of trips in a busy or quiet area, not something known in advance. They also move with area type | Kept them to answer "what goes with more trips?" and wrote in the model card that the model explains and does not predict. We do not call them causes |
| 30 | What the weak model lets us say | Compared r2_score (0.353) and the misses (average miss about 16,000 trips, middle miss about 4,200) with a typical area-month of about 22,500 trips | The model explains only about a third of the ups and downs. It cannot predict, and it shows what goes with more or fewer trips, not what causes it. The Uber idea is still untested | Used the model to explain only. Wrote the limits in `model/model_card.md` and kept the cause labeled as our explanation |
| 33 | Valuation scenarios in `20_decide.sql` / `03_decide.sql` | Verified assumptions behind the $2.8M to $13.9M gross fare recapture | 2,228,307 lost downtown trips is a measured fact; 10%, 25%, and 50% recapture rates and $12.50 average fare are labeled assumptions | Labeled every assumption and its source in `sql/README.md` and `findings.md` |

---

## 🔄 4. Changed the analysis

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 8 | Analytical granularity and fleet productivity metric | Rebuilt the analytical table with 11 columns, including `taxi_id` | Having `taxi_id` enabled calculating unique active vehicles per area-hour slot | Adopted **Fare per Taxi** rather than total area revenue as the core productivity metric to isolate vehicle yield from fleet density |
| 17 | Which gap to use for CP1 | Compared the fare-per-taxi gap (2022–2023) with the trip decline (2017–2019) on how well each was checked and how easy it is to explain | The fare-per-taxi gap still had open items and its years have missing months (check 12). The trip decline had passed checks 10–15 | Helaman and Nerlyn agreed on November 10, 2026 to use the trip decline: Jan–May 2019 against Jan–May 2017 |
| 22 | Which X's belong in the model | Applied the rule "only facts known before the outcome" to each possible X | The number of active taxis is counted from the same trips that make up Y, so it would peek at the answer | Left active taxis out. Kept `year`, `month`, and `area_group`, which are known in advance |

---

## 🛠️ 5. Improved the agent's instructions

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 9 | Audit protocol workflow and AI logging rules | Formalized the `project-audit` skill and verification procedure | Ad-hoc checks were uncataloged and lacked uniform category standards | Codified the 5-category taxonomy, required pre-commit reviews for additions, and enforced strict column consistency across all future checks |
| 18 | Whether the agent would repeat today's mistakes | Reviewed what went wrong in checks 10 and 11 | The agent's first drafts counted rows with `COUNT(*)` and compared full years | Added a "Project facts" section to `AGENTS.md` with cleaning rules: remove duplicates first, check months before comparing years, use Jan–May only |
| 28 | How AI help is used in CP2 | Reviewed who did what | Claude (AI) drafted the SQL, the design of the analysis table, and the write-ups. We ran every query in BigQuery, read every result, and approved each log entry | Noted the AI help here and in `Other/audit_protocol.md`. Added "re-run a key number before reusing it" to `AGENTS.md` |
| 31 | How to read the "unknown" area group | Looked at how `area_group` is built: unknown = trips with no pickup area, added together | It is a pile of many trips, not one place, so its big coefficient is not a "place effect" | Read it as "trips with no pickup area" in `model/model_card.md`. Named downtown as the clearest place driver |
| 34 | Standardizing visual labels and axes for CP3 | Inspected all 4 visuals in `visuals/` against rubric criteria (Gap, Driver, Recommendation, and Live Chart labels, non-misleading zero baseline, takeaway in title) | Gap chart had takeaway title but needed [Gap] tag; Driver and Recommendation charts created with zero baselines and takeaway titles; Looker Studio live chart created | Labeled each visual clearly and saved all 4 in `visuals/` |

---

## 📌 Next Steps & Open Items

- [ ] Break the trip decline down by pickup area, hour, and company to find where the loss is biggest.
- [ ] Find out why the public table has duplicate rows and missing months (checks 10–12).
- [ ] Test whether ride-hailing explains the drop, using a second data source.
- [x] Save our queries in the [`sql/`](../sql/) folder (done at CP1).

Dropped with the earlier approach (see check 17): the median benchmark re-run and the fare reconciliation on `taxi_2022_2023`.
