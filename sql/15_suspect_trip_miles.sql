-- Step 15: suspect 4. Average trips per area-month, by average trip length (whole miles). Details in sql/README.md (Steps 12 to 15).
SELECT CAST(FLOOR(avg_trip_miles) AS INT64) AS miles_bucket, ROUND(AVG(trips)) AS avg_trips, COUNT(*) AS row_count
FROM `big-query-509700.optimus_pride.analysis_table`
GROUP BY miles_bucket
ORDER BY miles_bucket;
