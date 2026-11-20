-- Step 19: same weights as Step 18, with numbers shortened so nothing is cut off. Details in sql/README.md (Steps 16 to 19).
SELECT
  processed_input,
  category,
  FORMAT('%.1f', weight) AS coefficient,
  FORMAT('%.4g', p_value) AS p_value
FROM ML.ADVANCED_WEIGHTS(MODEL `big-query-509700.optimus_pride.trips_model`);
