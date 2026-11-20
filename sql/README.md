# How we queried

All queries run in BigQuery on one public table:
`bigquery-public-data.chicago_taxi_trips.taxi_trips` (one row = one taxi trip).

We ran every query ourselves in the BigQuery console (project `big-query-509700`). An AI assistant drafted the SQL, and we checked each result before moving on. Steps 1 to 4 show what we saw on November 10, 2026. Step 5 was re-run on November 19, 2026, and Steps 6 and later were run on November 19 (see the note under Step 5).

| File | What it does |
|---|---|
| [`01_explore_by_year.sql`](01_explore_by_year.sql) | Counts trips and fares by year to look for a gap |
| [`02_month_coverage.sql`](02_month_coverage.sql) | Counts rows by month to find missing months |
| [`03_cleaning_checks.sql`](03_cleaning_checks.sql) | Checks for duplicates, blank fares, bad fares, and future dates |
| [`04_duplicate_check.sql`](04_duplicate_check.sql) | Checks that duplicate rows are exact copies |
| [`05_gap.sql`](05_gap.sql) | The final gap numbers used in `findings.md` |
| [`06_analysis_table.sql`](06_analysis_table.sql) | Builds the CP2 analysis table (one row = one pickup area in one month) |
| [`07_check_analysis_table.sql`](07_check_analysis_table.sql) | Checks the new columns for blanks, duplicates, and impossible values |
| [`08_second_way_check.sql`](08_second_way_check.sql) | Adds up the table by year to check it against CP1 |
| [`09_rerun_gap_check.sql`](09_rerun_gap_check.sql) | Re-runs the CP1 gap query to compare |
| [`10_split_by_month.sql`](10_split_by_month.sql) | Splits the gap by month |
| [`11_split_by_area_group.sql`](11_split_by_area_group.sql) | Splits the gap by area type |
| [`12_suspect_year.sql`](12_suspect_year.sql) | Suspect 1: trips by year |
| [`13_suspect_area_group.sql`](13_suspect_area_group.sql) | Suspect 2: trips by area type |
| [`14_suspect_cash_share.sql`](14_suspect_cash_share.sql) | Suspect 3: trips by cash share |
| [`15_suspect_trip_miles.sql`](15_suspect_trip_miles.sql) | Suspect 4: trips by average trip length |
| [`16_train_model.sql`](16_train_model.sql) | Trains the linear regression model |
| [`17_evaluate_model.sql`](17_evaluate_model.sql) | The model's report card |
| [`18_model_weights.sql`](18_model_weights.sql) | The model's drivers (coefficients and p-values) |
| [`19_model_weights_readable.sql`](19_model_weights_readable.sql) | Same drivers with the numbers shortened so none are cut off |

## Step 1: Explore by year (`01_explore_by_year.sql`)

We counted rows by year to see what was growing or dropping. These are raw rows, before any cleaning.

| Year | Rows | Avg fare |
|---|---:|---:|
| 2013 | 43,489,578 | $12.64 |
| 2014 | 18,005,202 | $12.24 |
| 2015 | 16,159,682 | $12.91 |
| 2016 | 40,145,926 | $13.51 |
| 2017 | 35,299,539 | $13.24 |
| 2018 | 32,651,674 | $13.58 |
| 2019 | 16,409,864 | $14.50 |
| 2022 | 4,478,955 | $22.03 |
| 2023 | 6,430,021 | $22.24 |

What we saw:
- 2020 and 2021 are not in the table at all.
- 2013 to 2016 jump up and down, so we did not trust those years.
- 2017 to 2019 are three years in a row, and trips fall each year. We picked this as our gap.

## Step 2: Check the months (`02_month_coverage.sql`)

2019 looked like half of 2018, so we counted rows by month before trusting it.

- 2017 and 2018 have all 12 months, each with 2.4 to 3.5 million rows.
- 2019 is normal from January to May (2.1 to 2.9 million rows a month). After that the data breaks: June 1,437,273, July 114,692, August 1,349,175, September 1,187,321, October 11. There are no rows for November or December.
- 2022 starts in March (7,624 rows) and May has only 17,117 rows.

**Cleaning choice 1: use January to May only, in all three years.** The 2019 rows after May are missing data, not fewer rides. Using the same five months each year is a fair comparison and also removes the effect of seasons.

## Step 3: Check the gap columns (`03_cleaning_checks.sql`)

We checked the three columns our gap uses (`unique_key`, `trip_start_timestamp`, `fare`) for January to May.

| Year | Rows | Distinct trips | Extra copies | Blank fares | Fares $0 or less | Future dates |
|---|---:|---:|---:|---:|---:|---:|
| 2017 | 13,710,451 | 10,670,978 | 3,039,473 | 148 | 8,524 | 0 |
| 2018 | 13,499,725 | 8,980,308 | 4,519,417 | 747 | 8,600 | 0 |
| 2019 | 12,321,392 | 7,013,627 | 5,307,765 | 933 | 9,833 | 0 |

What we saw:
- **Duplicates.** Many trips appear more than once with the same `unique_key`. Counting rows would count the same trip two or more times.
- **Blank and bad fares.** A small number of rows have no fare, or a fare of $0 or less (under 0.1% of rows).
- **Future dates.** None.

## Step 4: Are the duplicates exact copies? (`04_duplicate_check.sql`)

Before removing duplicates, we checked if any copies disagree on the fare or the start time.

Result: **0** trips have copies that disagree. Every duplicate is an exact copy.

**Cleaning choice 2: keep one row per `unique_key`.** Because the copies are identical, keeping one of them loses no information.

**Cleaning choice 3: drop rows where the fare is blank, zero, or negative.** A real paid trip has a fare above $0. This removes 6,219 trips in 2017, 5,331 in 2018, and 5,997 in 2019.

## Step 5: The gap (`05_gap.sql`)

This query applies all three cleaning choices and gives the numbers in `findings.md`.

| Jan–May | Clean trips | Avg fare | Total fares |
|---|---:|---:|---:|
| 2017 (benchmark) | 10,566,675 | $13.09 | $138,370,459 |
| 2018 | 8,861,212 | $13.22 | $117,101,456 |
| 2019 | 6,925,134 | $14.72 | $101,913,809 |

- Gap in trips: 10,566,675 − 6,925,134 = **3,641,541 fewer trips (34.5% lower)**.
- Gap in fares: $138,370,459 − $101,913,809 = **$36,456,650**.

**Note:** on November 10 this same query gave 10,664,759 / 8,974,977 / 7,007,630 trips and a fare gap of $37,516,155. The public table changed in between (about 1% fewer trips: 98,084 in 2017, 113,765 in 2018, and 82,496 in 2019). We found out in Step 8, re-ran the query on November 19, and updated every number in the repo. The finding did not change.

## Step 6: Build the analysis table (`06_analysis_table.sql`)

CP2 needs one row for each thing we compare, and one trip alone cannot show a drop. So we group trips: **one row = one pickup area in one month** (January to May, 2017 to 2019). The query is one `CREATE OR REPLACE TABLE` and saves `big-query-509700.optimus_pride.analysis_table`. It uses the same cleaning as Step 5 (January to May only, one row per `unique_key`, fare above $0).

| Column | What it is | Role |
|---|---|---|
| `trips` | Clean trips in that area that month | Y |
| `year` | 2017, 2018, or 2019 | X |
| `month` | January to May, as text so each month is its own category | X |
| `area_group` | downtown (areas 8, 28, 32, 33), airport (56, 76), unknown (no pickup area), or neighborhood (all others) | X |
| `avg_trip_miles` | Average trip length in miles | X |
| `cash_share` | Share of trips paid in cash, 0 to 1 | X |
| `pickup_area` | The area number, or "unknown". A label only, not used in the model | |

How we followed the three rules:
1. **Only facts known before the outcome.** `year`, `month`, and `area_group` are known in advance. `avg_trip_miles` and `cash_share` are measured from the same trips we count, so they are not strictly "known before." We keep them to explain Y and we do not use the model to predict. We left out the number of active taxis because it is counted from the same trips.
2. **Only settled rows.** All five months are complete in all three years (Step 2 and Step 7).
3. **No blanks.** `IFNULL` turns a missing pickup area into "unknown" and a missing average distance into 0, so BigQuery does not quietly fill blanks with the average.

## Step 7: Check the new columns (`07_check_analysis_table.sql`)

| Check | Result |
|---|---|
| Rows | 1,170 (78 areas × 5 months × 3 years) |
| Distinct rows (same area, year, month) | 1,170, so no duplicate rows |
| Rows with a blank in any column | 0 |
| Zero or negative trips | 0 |
| Negative average miles | 0 |
| Cash share outside 0 to 1 | 0 |
| Years, months, areas | 2017 to 2019, 5 months, 78 areas |
| Average trip length | 0.76 to 15.79 miles |
| Highest cash share | 1.0 (some small areas were paid only in cash in a month) |

## Step 8: Check the totals a second way (`08_second_way_check.sql`, `09_rerun_gap_check.sql`)

If the analysis table is right, adding up its `trips` by year must give the Step 5 totals.

| Year | Table total (Step 8) | Step 5 on Nov 10 | Step 5 re-run on Nov 19 (Step 9) |
|---|---:|---:|---:|
| 2017 | 10,566,675 | 10,664,759 | 10,566,675 |
| 2018 | 8,861,212 | 8,974,977 | 8,861,212 |
| 2019 | 6,925,134 | 7,007,630 | 6,925,134 |

The table did not match our November 10 numbers, but it matched the same query re-run on November 19. So the table is right, and the public data changed.

## Steps 10 and 11: Where and when (`10_split_by_month.sql`, `11_split_by_area_group.sql`)

We split the 2017 to 2019 drop by month and by area type. The tables and sentences are in [`findings.md`](../findings.md), Part A. In short: every month dropped (−31.9% to −39.2%), downtown lost the most trips (61% of the drop), neighborhoods lost the biggest share of their own trips (−50.5%), and airports held up best (−15.6%).

## Steps 12 to 15: Suspects (`12_suspect_year.sql` to `15_suspect_trip_miles.sql`)

For each X we show the average trips per area-month for each value of X: year, area type, cash share (rounded to 10%), and average trip length (whole miles). The tables and sentences are in [`findings.md`](../findings.md), Part A.

## Steps 16 to 19: The model (`16_train_model.sql` to `19_model_weights_readable.sql`)

Y (`trips`) is a number, so we trained a linear regression with `calculate_p_values = TRUE`, `category_encoding_method = 'DUMMY_ENCODING'`, `max_iterations = 50`, and `early_stop = FALSE`. The table has more than 500 rows, so BigQuery held some rows back for the report card.

- **Report card (Step 17):** r2_score 0.353, explained_variance 0.357, mean_absolute_error 15,986, median_absolute_error 4,232.
- **Drivers (Steps 18 and 19; Step 19 shows the full p-values, because BigQuery cut off the end of the small ones in Step 18):** downtown +310,110 (p 0.0), unknown +136,955 (p 1.8e-09), airport +80,822 (p 4.9e-05), year −4,534 (p 0.029), average trip miles −1,947 (p 0.032), cash share −6,809 (p 0.77), months not clear (p 0.21 to 0.75). `month` is compared to January and `area_group` to neighborhood.

The table, sentences, and limits are in [`model/model_card.md`](../model/model_card.md).

## What we did not use, and why

| Left out | Why |
|---|---|
| June to December (all years) | 2019 data is incomplete after May |
| 2013 to 2016 | Yearly counts jump up and down |
| 2020 and 2021 | Not in the table |
| 2022 and 2023 | 2022 has missing months, and there is a two-year hole before it |
| `tips`, `tolls`, `extras` | We value the gap with `fare` only, so our dollar number is on the low side |
| Number of active taxis (as an X) | It is counted from the same trips as Y, so the model would peek at the answer |
| Uber and Lyft trips (as an X) | They are not in our dataset |

## Limits to keep in mind

- These counts come from the BigQuery public copy of the data. The public table can change, so a re-run later may give slightly different numbers.
- We do not know why the public table has duplicate rows or missing months. We only measured them and worked around them.
- In Step 4 we only checked that duplicate copies agree on the fare and the start time. We did not check the pickup area, payment type, or miles. We assume they agree too.
- `cash_share` and `avg_trip_miles` come from the same trips we count (Step 6), so we use the model to explain, not to predict.
