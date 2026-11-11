-- Step 2: count rows by month to find missing months. Details in sql/README.md (Step 2).
SELECT
  EXTRACT(YEAR FROM trip_start_timestamp) AS year,
  EXTRACT(MONTH FROM trip_start_timestamp) AS month,
  COUNT(*) AS trips
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
WHERE EXTRACT(YEAR FROM trip_start_timestamp) >= 2017
GROUP BY year, month
ORDER BY year, month;
