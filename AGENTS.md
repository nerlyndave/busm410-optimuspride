# AGENTS.md

Read this before helping on our project.

- Team: Optimus Pride. Partners: Helaman Gonzaga | Dave Alcantara | Antigravity | Claude.
- Dataset: chicago_taxi_trips.
- Keep answers short and plain.
- Draft one step at a time, as a short query for us to approve. Never draft one long query that does everything.
- Don't save or change files until we say so.
- Back every claim about our data with a source, and say when something is your own conclusion.
- Ask us to confirm a table or column exists before you use it.
- Use our project audit skill (.agents/skills/project-audit/SKILL.md) to keep Other/audit_log.md up to date.
- Assume we're new to Git and GitHub. When we work together on our own computer, teach us how Git works as we go.
- Never run commits or pushes yourself. Give us the commands, and we'll run them.
- We each work on our own branch, named after the person (for example, alex). At the start of each session, remind us to run git pull on main, then merge main into our branch, before we change anything.
- At the end of each session, remind us to push our branch and open a pull request. Our partner reviews it before we merge it into main.
- If our work conflicts with our partner's, explain the conflict in plain words and help us decide what to keep.
- Remind us to merge finished work into main before each due date. Our instructor grades main.

## Project facts

Last updated: November 10, 2026 (CP1).

### Dataset
- Table: `bigquery-public-data.chicago_taxi_trips.taxi_trips`. It is the only table we use, so there are no joins.
- One row = one taxi trip.
- Documentation: https://data.cityofchicago.org/d/wrvz-psew
- Google Cloud project: `big-query-509700` (BigQuery sandbox).

### Key columns
- `unique_key`: the trip ID. Use it to remove duplicates.
- `trip_start_timestamp`: when the trip started. Use it for year and month.
- `fare`: the fare in dollars. Does not include tips, tolls, or extras.
- For later steps: `pickup_community_area`, `company`, `payment_type`, `taxi_id`.

### Cleaning rules (always apply these)
1. Use January to May only, for 2017, 2018, and 2019. The 2019 data is incomplete after May (October 2019 has 11 rows).
2. Keep one row per `unique_key`. The table has millions of duplicate rows. They are exact copies (checked in `sql/04_duplicate_check.sql`).
3. Drop rows where `fare` is blank, zero, or negative.
4. Do not use 2013–2016 (counts jump around), 2020–2021 (not in the table), or 2022–2023 (2022 has missing months).

### Our gap and benchmark
- Gap: 7,007,630 clean trips in Jan–May 2019, against 10,664,759 in Jan–May 2017. That is 3,657,129 fewer trips (34.3% lower).
- Middle year: 8,974,977 trips in Jan–May 2018 (−15.8%). 2018 to 2019 is −21.9%.
- Benchmark: Jan–May 2017, an earlier time. Same months, so seasons do not affect it.
- Value: $140,811,879 − $103,295,724 = $37,516,155 in fares over five months.
- Sources: `sql/05_gap.sql` for the numbers. The fare comes from the dataset's `fare` column.

### Decisions and lessons (do not repeat these mistakes)
- Never use `COUNT(*)` to count trips in this table. Remove duplicates first.
- Before comparing years, count rows by month. A year that looks low may just be missing months.
- Do not compare full years. Full-year 2019 looks 54% below 2017, but most of that is missing data.
- Our explanation for the drop is competition from ride-hailing apps like Uber. This is the team's hypothesis. Our data does not prove it, so always label it as "likely" or "our explanation", never as a measured fact.
- Outside support for the hypothesis: a City of Chicago report found ride-hailing trips grew 271% from 2015 to 2018.
- Our proposed solution: taxi companies make full use of the taxi option in the Uber app. It launched in Chicago on April 11, 2024 (Uber with Arro and Curb). Our data ends in 2023, so we cannot measure its effect.
- On November 10, 2026 the team dropped the earlier gap (fare per taxi by area and hour, 2022–2023) and agreed on the trip decline. The earlier checks stay in `Other/audit_log.md` as history.
- Audit files live in `Other/`. The copies in the repo root only point there.
