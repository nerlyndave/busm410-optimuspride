-- Step 14: suspect 3. Average trips per area-month, by cash share (rounded to 10% steps). Details in sql/README.md (Steps 12 to 15).
SELECT ROUND(cash_share, 1) AS cash_share_bucket, ROUND(AVG(trips)) AS avg_trips, COUNT(*) AS row_count
FROM `big-query-509700.optimus_pride.analysis_table`
GROUP BY cash_share_bucket
ORDER BY cash_share_bucket;
