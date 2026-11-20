# Model card

**The question:** what goes with more or fewer taxi trips in a pickup area? We use a linear regression because Y (`trips`) is a number.

| | |
|---|---|
| **Model** | `big-query-509700.optimus_pride.trips_model` (trained in [`sql/16_train_model.sql`](../sql/16_train_model.sql)) |
| **Type** | `linear_reg` with `calculate_p_values = TRUE`, `category_encoding_method = 'DUMMY_ENCODING'`, `max_iterations = 50`, `early_stop = FALSE` |
| **Data** | `analysis_table`, 1,170 rows. One row = one pickup area in one month (Jan–May, 2017–2019). Built in [`sql/06_analysis_table.sql`](../sql/06_analysis_table.sql) |
| **Y** | `trips`: clean taxi trips in that area that month |
| **X's** | `year`, `month`, `area_group`, `avg_trip_miles`, `cash_share` |
| **Held-back rows** | Our table has 1,170 rows (more than 500), so BigQuery held some rows back and did not train on them. The report card below is measured on those held-back rows |
| **Run on** | November 19, 2026 |

## Report card

From [`sql/17_evaluate_model.sql`](../sql/17_evaluate_model.sql) (`ML.EVALUATE`):

| Measure | Value |
|---|---:|
| **r2_score** | **0.353** |
| explained_variance | 0.357 |
| mean_absolute_error | 15,986 trips |
| median_absolute_error | 4,232 trips |

**Our r2_score is 0.353, so the model explains a little (about a third) of the ups and downs in trips.**

How to read the errors: a typical area-month in our table has about 22,500 trips. The model's average miss is about 16,000 trips, and its middle miss is about 4,200. So it is off by a lot for the busiest areas and closer for quiet ones.

A weak model can still be used to see which X's go with Y. That is how we use it. We do **not** use it to predict next year's trips.

## Drivers (coefficients)

From [`sql/18_model_weights.sql`](../sql/18_model_weights.sql) and [`sql/19_model_weights_readable.sql`](../sql/19_model_weights_readable.sql) (`ML.ADVANCED_WEIGHTS`). A p-value under 0.05 means the pattern is unlikely to be luck. Each row compares to a left-out starting group: `month` to January, and `area_group` to neighborhood. Those two have a coefficient of 0 and no p-value (NaN) by design, and `__INTERCEPT__` is only the starting point of the line, so we skip all three below.

| X | Coefficient | p-value | Reading |
|---|---:|---:|---|
| `year` | −4,534 | 0.029 | Each later year goes with about 4,500 fewer trips in an area-month. Fairly clear, but not strong |
| `month` = February (vs January) | +1,676 | 0.748 | Not different from January. Could be luck |
| `month` = March | +6,569 | 0.212 | Not different from January. Could be luck |
| `month` = April | +6,182 | 0.246 | Not different from January. Could be luck |
| `month` = May | +4,407 | 0.410 | Not different from January. Could be luck |
| `area_group` = downtown (vs neighborhood) | +310,110 | 0.0 (too small to show) | A downtown area has about 310,000 more trips a month than a neighborhood area. Very clear |
| `area_group` = unknown (vs neighborhood) | +136,955 | 0.0000000018 | The "no pickup area" pile has about 137,000 more trips. Very clear, but it is a pile of trips, not one place |
| `area_group` = airport (vs neighborhood) | +80,822 | 0.0000495 | An airport area has about 81,000 more trips a month than a neighborhood area. Very clear |
| `avg_trip_miles` | −1,947 per mile | 0.032 | Areas with longer average trips have somewhat fewer trips. Weak, and the real pattern is a U-shape (see limits) |
| `cash_share` | −6,809 (from 0% to 100% cash) | 0.768 | No clear link once the other X's are held steady. Could be luck |

### The two strongest drivers

The two with the smallest p-values are downtown and unknown (airport is third).

1. **Downtown:** The downtown category's coefficient is positive (+310,110), with a p-value of 0.0 (so small BigQuery shows it as zero), so holding the other X's steady, a downtown pickup area goes with a higher number of trips (about 310,000 more per month than a neighborhood area).
2. **Unknown area:** The unknown category's coefficient is positive (+136,955), with a p-value of 1.8e-09 (0.0000000018), so holding the other X's steady, the group of trips with no recorded pickup area goes with a higher number of trips (about 137,000 more than a neighborhood area).

Year (−4,534, p = 0.029) is the clearest of the other X's. It fits what Part A showed: trips fall each year.

## What this means for our question

- **Where matters far more than when.** The gap between downtown and a neighborhood (+310,110) is about 70 times the yearly change (−4,534). The month barely matters.
- **The yearly drop is still there** after holding area type, month, trip length, and cash share steady, so it is not just a change in which areas are busy.
- It does **not** tell us why trips fell, and it does not test the Uber idea. Ride-hailing trips are not in our data.

## Limits (read before using this)

- **The fit is weak (r2 = 0.353).** About two-thirds of the ups and downs in trips are not explained by these five X's.
- **Y is very uneven.** A downtown area has about 299,000 trips a month and a neighborhood about 3,600. A few busy areas dominate the straight line, which is partly why the misses are large.
- **Trip length is a U-shape, not a straight line** (Part A, suspect 4). A straight-line model cannot fit that, so the −1,947 is only a rough average.
- **`cash_share` and `avg_trip_miles` are measured from the same trips we count.** They are not known before the month happens, so we use the model to explain, not to predict. They also move with area type, so their effects overlap with `area_group`.
- **`year` is treated as a straight line with only three values** (2017, 2018, 2019).
- **The "unknown" group is every trip with no pickup area added together.** It is not one place, so its coefficient is not a "place effect."
- **A real link is not a cause.** The model shows what goes with more or fewer trips. It does not show what made trips go up or down.
- The p-values are only as good as the model. With a weak, uneven fit, treat them as a rough guide.
