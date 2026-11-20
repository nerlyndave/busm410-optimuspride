-- Step 7: check the analysis table for blanks, duplicates, and impossible values. Details in sql/README.md (Step 7).
SELECT
  COUNT(*) AS row_count,
  COUNT(DISTINCT CONCAT(pickup_area, '-', CAST(year AS STRING), '-', month)) AS distinct_rows,
  COUNTIF(pickup_area IS NULL OR area_group IS NULL OR year IS NULL OR month IS NULL
          OR trips IS NULL OR avg_trip_miles IS NULL OR cash_share IS NULL) AS rows_with_blanks,
  COUNTIF(trips <= 0) AS zero_or_negative_trips,
  COUNTIF(avg_trip_miles < 0) AS negative_miles,
  COUNTIF(cash_share < 0 OR cash_share > 1) AS impossible_cash_share,
  MIN(year) AS first_year,
  MAX(year) AS last_year,
  COUNT(DISTINCT month) AS months,
  COUNT(DISTINCT pickup_area) AS areas,
  MIN(avg_trip_miles) AS min_miles,
  MAX(avg_trip_miles) AS max_miles,
  MAX(cash_share) AS max_cash_share
FROM `big-query-509700.optimus_pride.analysis_table`;
