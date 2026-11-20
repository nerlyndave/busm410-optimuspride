-- Step 8: second-way check. Total trips per year in the analysis table should match the CP1 gap query. Details in sql/README.md (Step 8).
SELECT year, SUM(trips) AS total_trips
FROM `big-query-509700.optimus_pride.analysis_table`
GROUP BY year
ORDER BY year;
