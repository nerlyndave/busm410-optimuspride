# Dataset Documentation

## Where the data comes from

- **Official documentation:** [City of Chicago Data Portal, Taxi Trips (2013-2023)](https://data.cityofchicago.org/d/wrvz-psew)
- **Where we query it:** `bigquery-public-data.chicago_taxi_trips.taxi_trips` (Google BigQuery public data)

## What it is

Taxi companies report their trips to the City of Chicago, which regulates them. The city publishes those trips. One row is one taxi trip.

Things the city says about the data:
- Trip times are rounded to the nearest 15 minutes to protect privacy.
- Taxi IDs are scrambled, but the same taxi keeps the same ID.
- Not every trip is reported, but the city believes most are.

## Tables

We use one table, `taxi_trips`. There are no joins. See the table diagram: [`table_diagram.pdf`](table_diagram.pdf) (source: [`table_diagram.dbml`](table_diagram.dbml)).

## Columns we use for the gap

| Column | Type | What it means | How we use it |
|---|---|---|---|
| `unique_key` | STRING | The ID of one trip | Remove duplicate rows |
| `trip_start_timestamp` | TIMESTAMP | When the trip started | Pick the year and month |
| `fare` | FLOAT | The fare in dollars, without tips, tolls, or extras | Value the gap |

## Other columns in the table

| Column | What it means |
|---|---|
| `taxi_id` | Scrambled ID of the taxi |
| `trip_end_timestamp` | When the trip ended |
| `trip_seconds`, `trip_miles` | How long and how far the trip was |
| `pickup_census_tract`, `dropoff_census_tract` | Census tract where the trip started and ended |
| `pickup_community_area`, `dropoff_community_area` | Chicago community area (1 to 77) where the trip started and ended |
| `tips`, `tolls`, `extras`, `trip_total` | Other charges, and the total paid |
| `payment_type` | How the rider paid (cash, credit card, and so on) |
| `company` | The taxi company |
| `pickup_latitude`, `pickup_longitude`, `pickup_location` | Map point of the pickup |
| `dropoff_latitude`, `dropoff_longitude`, `dropoff_location` | Map point of the dropoff |

## What we found about the BigQuery copy (November 10, 2026)

- Many trips appear more than once. We keep one row per `unique_key`.
- 2020 and 2021 are missing. 2019 is incomplete after May. 2022 has missing months.

Details are in [`../sql/README.md`](../sql/README.md).
