-- Step 9: re-run of the CP1 gap query (05_gap.sql) on Nov 19 to compare with the analysis table. Details in sql/README.md (Step 8).
WITH clean AS (
  SELECT
    unique_key,
    ANY_VALUE(trip_start_timestamp) AS trip_start_timestamp,
    ANY_VALUE(fare) AS fare
  FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
  WHERE EXTRACT(YEAR FROM trip_start_timestamp) BETWEEN 2017 AND 2019
    AND EXTRACT(MONTH FROM trip_start_timestamp) BETWEEN 1 AND 5
  GROUP BY unique_key
)
SELECT
  EXTRACT(YEAR FROM trip_start_timestamp) AS year,
  COUNT(*) AS trips,
  ROUND(AVG(fare), 2) AS avg_fare,
  ROUND(SUM(fare)) AS total_fares
FROM clean
WHERE fare > 0
GROUP BY year
ORDER BY year;
