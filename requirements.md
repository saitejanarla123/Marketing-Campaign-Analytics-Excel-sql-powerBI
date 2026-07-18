# Analytical Requirements

This document translates the brief ("Recommended Analysis") into concrete requirements, so it's clear what "done" looks like for each one before it gets marked complete.

## R1 — Data Quality

**Requirement:** The dataset must be checked for nulls, duplicate IDs, and outliers before being used in any downstream analysis.

**Acceptance criteria:**
- Null/blank check run across every column
- Duplicate `ID` check run
- Age outliers identified via `Year_Birth` and excluded from age-based analysis
- Income outliers identified and reviewed individually (not auto-dropped by a blanket statistical rule) — only values that look like data entry errors are excluded
- Non-standard `Marital_Status` categories identified and recoded rather than silently dropped
- All of the above implemented as a reusable SQL view (`v_customers_clean`), not a one-off manual edit

**Covered by:** `sql/02_data_cleaning_and_quality_checks.sql`

## R2 — Web Purchase Drivers

**Requirement:** Identify which customer attributes are meaningfully related (positively or negatively) to `NumWebPurchases`.

**Acceptance criteria:**
- Correlation calculated between `NumWebPurchases` and at minimum: income, kids at home, teens at home, age, recency, web visit frequency, and purchases through the other three channels
- Findings state both the strongest positive and strongest negative factor
- Any counter-intuitive result (e.g., a variable expected to correlate that doesn't) is called out explicitly

**Covered by:** `sql/03_business_analysis.sql`, Q1

## R3 — Campaign Performance

**Requirement:** Rank all six campaigns (`AcceptedCmp1`–`5` and `Response`) by acceptance rate and identify the top and bottom performers.

**Acceptance criteria:**
- Acceptance count and rate calculated per campaign
- Share of customers who accepted at least one campaign, out of all six, is reported
- Result distinguishes the most recent campaign (`Response`) from the five historical ones, since it isn't collected on the same basis

**Covered by:** `sql/03_business_analysis.sql`, Q2

## R4 — Customer Profile

**Requirement:** Describe the average Maven Marketing customer across demographics, spend, and channel behavior.

**Acceptance criteria:**
- Central tendency (mean and/or median) reported for age, income, spend, recency, and purchases per channel
- Most common education level and marital status reported (mode, not mean, since these are categorical)
- Share of customers with at least one dependent (kid or teen) at home reported

**Covered by:** `sql/03_business_analysis.sql`, Q3

## R5 — Product Performance

**Requirement:** Rank the six product categories by total spend and quantify concentration risk.

**Acceptance criteria:**
- Total spend and share of total calculated per category
- Combined share of the top two categories reported explicitly, to size the concentration risk

**Covered by:** `sql/03_business_analysis.sql`, Q4

## R6 — Channel Performance

**Requirement:** Rank the four purchase channels (web, catalog, store, deals) by volume and identify the underperformer.

**Acceptance criteria:**
- Total purchases per channel reported
- Underperforming channel identified with a reason grounded in the data (not just "lowest number"), using the R2 correlation findings where relevant

**Covered by:** `sql/03_business_analysis.sql`, Q5

## R7 — Portfolio Packaging

**Requirement:** Repository must be presentable to a recruiter within the "under 60 seconds" scan described in the GitHub Portfolio Playbook.

**Acceptance criteria:**
- README covers business problem, tech stack, setup instructions, pipeline flow, screenshots, and key findings
- Folder structure follows the Data Analyst project template (`data/`, `sql/`, `docs/`, `dashboards/`)
- LICENSE file present
- No large raw data files committed
