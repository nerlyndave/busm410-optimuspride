-- Step 17: the report card. Grades the model on the rows BigQuery held back. Details in sql/README.md (Steps 16 to 19).
SELECT * FROM ML.EVALUATE(MODEL `big-query-509700.optimus_pride.trips_model`);
