-- Step 16: train the linear regression model. Y = trips (a number). One row = one pickup area in one month. Details in sql/README.md (Steps 16 to 19).
CREATE OR REPLACE MODEL `big-query-509700.optimus_pride.trips_model`
OPTIONS (
  model_type = 'linear_reg',
  input_label_cols = ['trips'],
  calculate_p_values = TRUE,
  category_encoding_method = 'DUMMY_ENCODING',
  max_iterations = 50,
  early_stop = FALSE
) AS
SELECT trips, year, month, area_group, avg_trip_miles, cash_share
FROM `big-query-509700.optimus_pride.analysis_table`;
