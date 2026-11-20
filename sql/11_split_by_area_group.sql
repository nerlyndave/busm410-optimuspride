-- Step 11: split the gap by area group. Details in sql/README.md (Steps 10 and 11).
SELECT
  area_group,
  SUM(IF(year = 2017, trips, 0)) AS trips_2017,
  SUM(IF(year = 2018, trips, 0)) AS trips_2018,
  SUM(IF(year = 2019, trips, 0)) AS trips_2019,
  ROUND(100 * (SUM(IF(year = 2019, trips, 0)) / SUM(IF(year = 2017, trips, 0)) - 1), 1) AS pct_change_2017_to_2019
FROM `big-query-509700.optimus_pride.analysis_table`
GROUP BY area_group
ORDER BY trips_2017 DESC;
