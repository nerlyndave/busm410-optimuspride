-- Step 3: check for duplicates, blank fares, bad fares, and future dates. Details in sql/README.md (Step 3).
SELECT
  EXTRACT(YEAR FROM trip_start_timestamp) AS year,
  COUNT(*) AS trips,
  COUNT(DISTINCT unique_key) AS distinct_trips,
  COUNTIF(fare IS NULL) AS blank_fares,
  COUNTIF(fare <= 0) AS zero_or_negative_fares,
  COUNTIF(trip_start_timestamp > CURRENT_TIMESTAMP()) AS future_dates,
  ROUND(AVG(fare), 2) AS avg_fare,
  ROUND(SUM(fare)) AS total_fares
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
WHERE EXTRACT(YEAR FROM trip_start_timestamp) BETWEEN 2017 AND 2019
  AND EXTRACT(MONTH FROM trip_start_timestamp) BETWEEN 1 AND 5
GROUP BY year
ORDER BY year;
