-- Step 1: count trips and fares by year to look for a gap. Details in sql/README.md (Step 1).
SELECT
  EXTRACT(YEAR FROM trip_start_timestamp) AS year,
  COUNT(*) AS trips,
  ROUND(AVG(fare), 2) AS avg_fare,
  ROUND(SUM(fare)) AS total_fares
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
GROUP BY year
ORDER BY year;
