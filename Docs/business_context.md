# Business Context

## Problem Statement

Maven Marketing has run six promotional campaigns targeting its customer base over the past two years, alongside three purchasing channels: web, catalog, and in-store. Marketing and merchandising decisions so far have been made without a clear read on which campaigns actually converted, which products carry the business, and which channels are worth further investment.

This analysis works through a database of 2,240 customers — their demographics, spending across six product categories, purchase behavior across four channels, and their response to each of the six campaigns — to give the business a data-backed answer to those questions before the next campaign or catalog cycle is planned.

## Goals

1. **Establish a trustworthy baseline** — Check the dataset for nulls, duplicates, and outliers (implausible ages, placeholder income values, junk categorical entries) before any business conclusion is drawn from it.

2. **Identify what drives web purchases** — Determine which customer attributes (income, household composition, age, other purchase behavior) are meaningfully related to online buying, and which commonly-assumed factors (like site visit frequency) turn out not to matter.

3. **Rank campaign performance** — Compare acceptance rates across all six campaigns to identify the strongest and weakest performers, and quantify how many customers have ever responded to an offer at all.

4. **Profile the average customer** — Summarize the typical customer's age, income, household, spending, and channel preference so campaigns and offers can be built around who's actually buying.

5. **Assess product concentration** — Quantify how revenue is distributed across the six product categories, and flag any risk of over-reliance on a single category.

6. **Flag underperforming channels** — Compare purchase volume across web, catalog, store, and deal-driven purchases to identify which channel is underused relative to the others.

7. **Deliver a recruiter-ready portfolio artifact** — Package the analysis as a clean, well-documented GitHub repository (MySQL scripts, README, Power BI dashboard) demonstrating end-to-end analytics work: data quality checks, business-question-driven SQL, and dashboard storytelling.

## Scope

- **Data source:** `marketing_data.xlsb` — a single flat table of 2,240 Maven Marketing customers (public-domain Maven Analytics dataset), documented in `docs/marketing_data_dictionary.csv`.
- **Tools:** MySQL (data cleaning and business analysis queries), Power BI (dashboard and DAX measures), Excel (initial file inspection and CSV conversion).
- **Out of scope:** Predictive modeling of campaign response, customer lifetime value, and A/B test design for future campaigns are not covered in this phase.
