-- Step 4: check that duplicate rows are exact copies before removing them. Details in sql/README.md (Step 4).
SELECT COUNT(*) AS keys_with_conflicting_copies
FROM (
  SELECT unique_key
  FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
  WHERE EXTRACT(YEAR FROM trip_start_timestamp) BETWEEN 2017 AND 2019
    AND EXTRACT(MONTH FROM trip_start_timestamp) BETWEEN 1 AND 5
  GROUP BY unique_key
  HAVING COUNT(*) > 1
     AND (COUNT(DISTINCT fare) > 1 OR COUNT(DISTINCT trip_start_timestamp) > 1)
);
