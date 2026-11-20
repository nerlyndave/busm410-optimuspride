-- Step 12: suspect 1. Average trips per area-month, by year. Details in sql/README.md (Steps 12 to 15).
SELECT year, ROUND(AVG(trips)) AS avg_trips, COUNT(*) AS row_count
FROM `big-query-509700.optimus_pride.analysis_table`
GROUP BY year
ORDER BY year;
