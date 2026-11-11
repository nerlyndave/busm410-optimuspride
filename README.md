<h1 align="center">🚖 Busm410-optimuspride 🚖</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Team-Optimus%20Pride-blue?style=for-the-badge" alt="Team">
  <img src="https://img.shields.io/badge/Canvas-Team%206-orange?style=for-the-badge" alt="Canvas team">
  <img src="https://img.shields.io/badge/Dataset-Chicago%20Taxi%20Trips-yellow?style=for-the-badge" alt="Dataset">
  <img src="https://img.shields.io/badge/Tool-BigQuery-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" alt="BigQuery">
</p>

<p align="center"><i>BUSM 410 · Big Data and Advanced Analytics · BYU–Hawaii</i></p>

---

## 👥 Team Info

| | |
|---|---|
| **Team name** | Optimus Pride |
| **Canvas team number** | Team 6 |
| **Partners** | Helaman Gonzaga, Dave Alcantara |
| **AI Contributors** | Antigravity (Google DeepMind), Claude (Anthropic) |

## 📊 Dataset

| | |
|---|---|
| **Dataset** | `chicago_taxi_trips` |
| **Table** | `bigquery-public-data.chicago_taxi_trips.taxi_trips` |
| **Each row is** | One taxi ride |
| **Google Cloud project ID** | `big-query-509700` |

## 🎯 Problem Framing

Chicago taxis are losing riders. After cleaning the data, taxis made **7,007,630 trips in January–May 2019**, compared with **10,664,759 in January–May 2017**, our benchmark. That is a gap of **3,657,129 trips (34.3% lower)**, and the drop got faster each year (−15.8%, then −21.9%). In fares, the gap is worth **$37,516,155 (about $37.5 million) over five months**: $140,811,879 collected in Jan–May 2017 minus $103,295,724 in Jan–May 2019. One row in the data is one taxi trip. We compare January to May only because the 2019 data is incomplete after May. We think the main cause is competition from ride-hailing apps like Uber (our explanation, not yet tested with our data), and our proposed solution is for taxi companies to use the taxi option in the Uber app, which launched in Chicago in April 2024. The fare comes from the dataset's own `fare` column ([City of Chicago Taxi Trips](https://data.cityofchicago.org/d/wrvz-psew)), and the math is in [`findings.md`](findings.md).

## 🧭 Explore the Work

| File / Folder | What it's for |
|---|---|
| [`findings.md`](findings.md) | Our gap, benchmark, value, and chart |
| [`charter.md`](charter.md) | Our question, the decision it supports, scope, and what success looks like |
| [`sql/README.md`](sql/README.md) | How we queried and every cleaning choice |
| [`sql/01_explore_by_year.sql`](sql/01_explore_by_year.sql) | Trips and fares by year |
| [`sql/02_month_coverage.sql`](sql/02_month_coverage.sql) | Rows by month, to find missing months |
| [`sql/03_cleaning_checks.sql`](sql/03_cleaning_checks.sql) | Duplicates, blank fares, bad fares, future dates |
| [`sql/04_duplicate_check.sql`](sql/04_duplicate_check.sql) | Proof that duplicates are exact copies |
| [`sql/05_gap.sql`](sql/05_gap.sql) | The final gap numbers |
| [`visuals/gap_chart.png`](visuals/gap_chart.png) | Chart of the gap and the benchmark |
| [`Other/dataset_documentation.md`](Other/dataset_documentation.md) | What the dataset is and what each column means |
| [`Other/table_diagram.pdf`](Other/table_diagram.pdf) | Table diagram (source: [`Other/table_diagram.dbml`](Other/table_diagram.dbml)) |
| [`Other/audit_protocol.md`](Other/audit_protocol.md) | How we direct and check our AI agent |
| [`Other/audit_log.md`](Other/audit_log.md) | Every check we ran, by category |
| [`AGENTS.md`](AGENTS.md) | Rules and project facts for our AI agent |
| [`.agents/skills/project-audit/SKILL.md`](.agents/skills/project-audit/SKILL.md) | The audit skill our agent follows |
| `model/` | Model results (later checkpoints) |

**Dataset documentation:** [City of Chicago Data Portal, Taxi Trips (2013-2023)](https://data.cityofchicago.org/d/wrvz-psew)

---

<p align="center">Made with 🚕 by Helaman, Dave, and Antigravity</p>
