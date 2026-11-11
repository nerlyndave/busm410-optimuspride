# Charter

## The question

Chicago taxis carried 34% fewer trips in January–May 2019 than in January–May 2017. **Where is that loss happening (which pickup areas, hours, and companies), and how much of it could taxis win back by joining ride-hailing apps such as Uber?**

## The decision this supports

**Manager:** the operations manager of a Chicago taxi company.

**Decision:** how to win riders back. We believe riders moved to ride-hailing apps like Uber (our explanation, not yet tested with our data). The manager must decide whether to put the company's cabs on the Uber app's taxi option, which launched in Chicago in April 2024, and where to send those cabs: evenly across the city, or to the areas and hours where trips dropped the most. The gap is worth about $37.5 million in fares over five months across the city, so getting this wrong is costly.

## Scope

| | |
|---|---|
| **Dataset** | City of Chicago Taxi Trips, `bigquery-public-data.chicago_taxi_trips.taxi_trips` |
| **Years** | 2017, 2018, and 2019, January to May only |
| **What we compare** | Trips and fares in Jan–May 2019 against the same months in 2017 (the benchmark), with 2018 in between |
| **One row stands for** | One taxi trip |
| **Left out** | June to December (2019 is incomplete after May), 2013–2016, 2020–2023, and tips, tolls, and extras |

## What success looks like

- The gap, the benchmark, and the dollar value can be re-created by anyone who runs our SQL files in order.
- We can name the pickup areas, hours, or companies that lost the most trips, with numbers.
- We give the manager one clear recommendation on using the Uber app's taxi option, and say what it could be worth in fares.
- Every number in our write-up matches a query in `sql/`, and every outside fact has a link.
- We say plainly what the data cannot tell us, such as why riders left.
