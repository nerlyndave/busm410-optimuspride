-- Step 5: the gap. Clean Jan-May trips and fares for 2017, 2018, 2019. Details in sql/README.md (Step 5).
WITH clean AS (
  -- keep one row per trip (removes duplicate copies)
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
WHERE fare > 0          -- drops blank, zero, and negative fares
GROUP BY year
ORDER BY year;
