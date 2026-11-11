# How we queried

All queries run in BigQuery on one public table:
`bigquery-public-data.chicago_taxi_trips.taxi_trips` (one row = one taxi trip).

We ran every query ourselves in the BigQuery console (project `big-query-509700`). An AI assistant drafted the SQL, and we checked each result before moving on. The numbers below are the results we got on November 10, 2026.

| File | What it does |
|---|---|
| [`01_explore_by_year.sql`](01_explore_by_year.sql) | Counts trips and fares by year to look for a gap |
| [`02_month_coverage.sql`](02_month_coverage.sql) | Counts rows by month to find missing months |
| [`03_cleaning_checks.sql`](03_cleaning_checks.sql) | Checks for duplicates, blank fares, bad fares, and future dates |
| [`04_duplicate_check.sql`](04_duplicate_check.sql) | Checks that duplicate rows are exact copies |
| [`05_gap.sql`](05_gap.sql) | The final gap numbers used in `findings.md` |

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
| 2017 (benchmark) | 10,664,759 | $13.20 | $140,811,879 |
| 2018 | 8,974,977 | $13.27 | $119,102,382 |
| 2019 | 7,007,630 | $14.74 | $103,295,724 |

- Gap in trips: 10,664,759 − 7,007,630 = **3,657,129 fewer trips (34.3% lower)**.
- Gap in fares: $140,811,879 − $103,295,724 = **$37,516,155**.

## What we did not use, and why

| Left out | Why |
|---|---|
| June to December (all years) | 2019 data is incomplete after May |
| 2013 to 2016 | Yearly counts jump up and down |
| 2020 and 2021 | Not in the table |
| 2022 and 2023 | 2022 has missing months, and there is a two-year hole before it |
| `tips`, `tolls`, `extras` | We value the gap with `fare` only, so our dollar number is on the low side |

## Limits to keep in mind

- These counts come from the BigQuery public copy of the data. The public table can change, so a re-run later may give slightly different numbers.
- We do not know why the public table has duplicate rows or missing months. We only measured them and worked around them.
