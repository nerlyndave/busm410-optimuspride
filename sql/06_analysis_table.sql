-- Step 6: build the CP2 analysis table. One row = one pickup area in one month (Jan-May, 2017-2019). Details in sql/README.md (Step 6).
CREATE OR REPLACE TABLE `big-query-509700.optimus_pride.analysis_table` AS
WITH clean AS (
  -- same cleaning as CP1: Jan-May only, one row per trip
  SELECT
    unique_key,
    ANY_VALUE(trip_start_timestamp) AS trip_start_timestamp,
    ANY_VALUE(fare) AS fare,
    ANY_VALUE(pickup_community_area) AS pickup_community_area,
    ANY_VALUE(payment_type) AS payment_type,
    ANY_VALUE(trip_miles) AS trip_miles
  FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
  WHERE EXTRACT(YEAR FROM trip_start_timestamp) BETWEEN 2017 AND 2019
    AND EXTRACT(MONTH FROM trip_start_timestamp) BETWEEN 1 AND 5
  GROUP BY unique_key
)
SELECT
  IFNULL(CAST(pickup_community_area AS STRING), 'unknown') AS pickup_area,
  CASE
    WHEN pickup_community_area IN (8, 28, 32, 33) THEN 'downtown'
    WHEN pickup_community_area IN (56, 76) THEN 'airport'
    WHEN pickup_community_area IS NULL THEN 'unknown'
    ELSE 'neighborhood'
  END AS area_group,
  EXTRACT(YEAR FROM trip_start_timestamp) AS year,
  CAST(EXTRACT(MONTH FROM trip_start_timestamp) AS STRING) AS month,
  COUNT(*) AS trips,
  IFNULL(ROUND(AVG(trip_miles), 2), 0) AS avg_trip_miles,
  ROUND(COUNTIF(payment_type = 'Cash') / COUNT(*), 4) AS cash_share
FROM clean
WHERE fare > 0
GROUP BY pickup_area, area_group, year, month;
