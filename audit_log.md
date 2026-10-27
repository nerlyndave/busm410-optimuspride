# Audit Log

| # | What I checked | How | What I found | What I did about it |
|---|---|---|---|---|
| 1 | Date range of the first copy of the data | Ran MIN and MAX on trip_start_timestamp | First trip was June 30, 2021, so Jan to Jun 2021 is missing from the public table | Switched the analysis to full years 2022 and 2023 |
| 2 | Date range and size of the new table | Ran MIN, MAX, COUNT on taxi_2022_2023 | Jan 1, 2022 to Dec 31, 2023, 12,782,991 trips | Table looks complete for the chosen period |
| 3 | Columns available | Rebuilt the table with 11 columns, including taxi_id | taxi_id lets us count taxis per area and hour | Using fare per taxi as the measure |
| 4 | Whether a spread exists | Looked at fare per taxi by pickup area and hour (760 slots with 1,000+ trips) | Lowest $18.01, 25th percentile $68.87, median $108.41, 75th percentile $160.84, highest $2,774.18 | Real spread exists, so a gap is possible |
| 5 | Outliers | Saw pickup area 76 at the top of the results | Airport slots earn far more per taxi than neighborhoods | Excluded areas 76 and 56 from the benchmark (still need to verify these are the airports) |
| 6 | Fair benchmark | Compared areas to each other within the same hour | Avoids calling a quiet 4 am slot a gap | Benchmark = 75th percentile of areas at the same hour |
| 7 | Gap size | Summed (benchmark minus actual) x taxis for slots below benchmark | $22,696,763 gap on $140,871,668 total fares = 16.1% | Report as "up to" because the benchmark choice affects the result |

## Still to do
- Re-run with the median benchmark to show a range
- Confirm areas 76 and 56 are the airports
- Compare total_fare to a plain SUM(fare) on the whole table
- Note: SQL help from Claude (AI), results checked by team
