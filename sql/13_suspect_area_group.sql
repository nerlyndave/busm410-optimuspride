-- Step 13: suspect 2. Average trips per area-month, by area group. Details in sql/README.md (Steps 12 to 15).
SELECT area_group, ROUND(AVG(trips)) AS avg_trips, COUNT(*) AS row_count
FROM `big-query-509700.optimus_pride.analysis_table`
GROUP BY area_group
ORDER BY avg_trips DESC;
