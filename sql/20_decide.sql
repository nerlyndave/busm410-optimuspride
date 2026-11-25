-- Step 20 / 03_decide: Calculate the value of the recommendation.
-- Details and assumptions documented in sql/README.md.
-- Recommendation: Operations manager puts cabs on the Uber app taxi option in the 4 Downtown areas (8, 28, 32, 33).

WITH downtown_gap AS (
  SELECT
    area_group,
    SUM(CASE WHEN year = 2017 THEN trips ELSE 0 END) AS trips_2017,
    SUM(CASE WHEN year = 2019 THEN trips ELSE 0 END) AS trips_2019,
    SUM(CASE WHEN year = 2017 THEN trips ELSE 0 END) - 
      SUM(CASE WHEN year = 2019 THEN trips ELSE 0 END) AS trips_lost,
    -- Average fare in downtown Jan-May 2019 ($12.50 baseline from analysis table)
    ROUND(AVG(CASE WHEN year = 2019 THEN avg_trip_miles * 2.25 + 3.25 ELSE NULL END), 2) AS estimated_avg_fare
  FROM `big-query-509700.optimus_pride.analysis_table`
  WHERE area_group = 'downtown'
  GROUP BY area_group
)
SELECT
  area_group,
  trips_lost,
  -- Scenario A: Conservative (10% recapture of lost downtown rides)
  ROUND(trips_lost * 0.10) AS recapture_trips_10pct,
  ROUND(trips_lost * 0.10 * 12.50) AS gross_fare_recapture_10pct,

  -- Scenario B: Moderate (25% recapture of lost downtown rides)
  ROUND(trips_lost * 0.25) AS recapture_trips_25pct,
  ROUND(trips_lost * 0.25 * 12.50) AS gross_fare_recapture_25pct,

  -- Scenario C: Target / Strong (50% recapture of lost downtown rides)
  ROUND(trips_lost * 0.50) AS recapture_trips_50pct,
  ROUND(trips_lost * 0.50 * 12.50) AS gross_fare_recapture_50pct

FROM downtown_gap;
