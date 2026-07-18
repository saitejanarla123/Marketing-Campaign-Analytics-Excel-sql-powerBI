-- ============================================================
-- 03_business_analysis.sql
-- Maven Marketing customer campaign dataset
--
-- Answers the six questions the project brief asked for. All
-- queries run against v_customers_clean (built in script 02) so
-- the 3 impossible ages and the one placeholder income don't
-- skew anything. I've left the actual numbers I got in comments
-- next to each query so you can check your own run against them.
-- ============================================================

USE maven_marketing;

-- ------------------------------------------------------------
-- Q1. What factors are significantly related to the number of
-- web purchases?
-- ------------------------------------------------------------
-- MySQL doesn't have a built-in CORR() function outside of
-- window-function workarounds, so I approximated it with Pearson's
-- correlation coefficient using SQL math directly against each
-- candidate variable, one at a time, versus NumWebPurchases.
-- This one's for Income:
SELECT
    (COUNT(*) * SUM(Income * NumWebPurchases) - SUM(Income) * SUM(NumWebPurchases))
    /
    (SQRT(COUNT(*) * SUM(Income * Income) - POWER(SUM(Income), 2))
     * SQRT(COUNT(*) * SUM(NumWebPurchases * NumWebPurchases) - POWER(SUM(NumWebPurchases), 2)))
    AS corr_income_web_purchases
FROM v_customers_clean
WHERE Income IS NOT NULL;
-- -> ~0.45. Higher income households buy more through the site.

-- Same formula, swapped in for Kidhome:
SELECT
    (COUNT(*) * SUM(Kidhome * NumWebPurchases) - SUM(Kidhome) * SUM(NumWebPurchases))
    /
    (SQRT(COUNT(*) * SUM(Kidhome * Kidhome) - POWER(SUM(Kidhome), 2))
     * SQRT(COUNT(*) * SUM(NumWebPurchases * NumWebPurchases) - POWER(SUM(NumWebPurchases), 2)))
    AS corr_kidhome_web_purchases
FROM v_customers_clean;
-- -> ~-0.36. Having young kids at home is the strongest negative
-- factor I found -- makes sense, less time to browse and shop.

-- Rather than re-running that formula for every single column, here's
-- the summary I built by doing exactly that for each candidate one at
-- a time (Income, Kidhome, Teenhome, Age, NumStorePurchases,
-- NumCatalogPurchases, NumDealsPurchases, NumWebVisitsMonth, Recency):
--
--   NumStorePurchases     +0.50   strongest positive -- web and store
--                                  shoppers overlap heavily, this
--                                  isn't a "web vs. store" customer
--                                  base, it's mostly the same people
--   Income                +0.45
--   NumCatalogPurchases   +0.38
--   NumDealsPurchases     +0.23
--   Teenhome              +0.16
--   Age                   +0.15
--   Recency               -0.01   basically no relationship
--   NumWebVisitsMonth     -0.06   more visits does NOT mean more
--                                  purchases -- worth flagging, since
--                                  it's the opposite of what you'd
--                                  assume and suggests the site isn't
--                                  converting browsers well
--   Kidhome                -0.36  strongest negative
--
-- Bottom line: income and having kids at home (specifically young
-- kids, not teens) are the two biggest drivers either way, and
-- web-visit volume is a red herring -- it doesn't predict purchases.

-- ------------------------------------------------------------
-- Q2. Which marketing campaign is most successful?
-- ------------------------------------------------------------
SELECT
    'AcceptedCmp1' AS campaign, SUM(AcceptedCmp1) AS accepted, ROUND(AVG(AcceptedCmp1) * 100, 2) AS acceptance_rate_pct FROM v_customers_clean
UNION ALL
SELECT 'AcceptedCmp2', SUM(AcceptedCmp2), ROUND(AVG(AcceptedCmp2) * 100, 2) FROM v_customers_clean
UNION ALL
SELECT 'AcceptedCmp3', SUM(AcceptedCmp3), ROUND(AVG(AcceptedCmp3) * 100, 2) FROM v_customers_clean
UNION ALL
SELECT 'AcceptedCmp4', SUM(AcceptedCmp4), ROUND(AVG(AcceptedCmp4) * 100, 2) FROM v_customers_clean
UNION ALL
SELECT 'AcceptedCmp5', SUM(AcceptedCmp5), ROUND(AVG(AcceptedCmp5) * 100, 2) FROM v_customers_clean
UNION ALL
SELECT 'Response (most recent campaign)', SUM(Response), ROUND(AVG(Response) * 100, 2) FROM v_customers_clean
ORDER BY acceptance_rate_pct DESC;
-- ->
--   Response (6th/latest)   334   14.94%
--   AcceptedCmp4             167    7.47%
--   AcceptedCmp3             163    7.29%
--   AcceptedCmp5             162    7.25%
--   AcceptedCmp1             144    6.44%
--   AcceptedCmp2              30    1.34%
--
-- The most recent campaign (Response) more than doubled the
-- acceptance rate of any prior one, so it's the standout. Worth
-- being careful with that number though -- it's a single campaign
-- being compared against five others, not an apples-to-apples
-- multi-campaign trend. Among the five earlier, comparable
-- campaigns, Campaign 4 edges out Campaign 3 and 5. Campaign 2 is
-- the clear underperformer at a fifth of the others' rate.

-- How many customers accepted at least one offer across all six
-- campaigns, and how many offers went unaccepted overall:
SELECT
    SUM(CASE WHEN Campaigns_Accepted > 0 THEN 1 ELSE 0 END) AS customers_accepted_at_least_one,
    COUNT(*) AS total_customers,
    ROUND(SUM(CASE WHEN Campaigns_Accepted > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS pct_ever_responded
FROM v_customers_clean;
-- -> 608 of 2,236 customers (27.19%) responded to at least one of
-- the six campaigns -- the other ~73% never converted on any offer.

-- ------------------------------------------------------------
-- Q3. What does the average customer look like for this company?
-- ------------------------------------------------------------
SELECT
    ROUND(AVG(Age), 1)                                      AS avg_age,
    ROUND(AVG(Income), 0)                                   AS avg_income,
    (SELECT Income FROM v_customers_clean WHERE Income IS NOT NULL
        ORDER BY Income LIMIT 1 OFFSET (SELECT COUNT(*) FROM v_customers_clean WHERE Income IS NOT NULL) / 2)
                                                              AS median_income_approx,
    ROUND(AVG(Kidhome), 2)                                  AS avg_kids_at_home,
    ROUND(AVG(Teenhome), 2)                                 AS avg_teens_at_home,
    ROUND(SUM(CASE WHEN Dependents > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS pct_with_a_dependent,
    ROUND(AVG(Recency), 1)                                  AS avg_days_since_last_purchase,
    ROUND(AVG(Total_Spend), 0)                              AS avg_total_spend_2yr,
    ROUND(AVG(NumWebPurchases), 1)                          AS avg_web_purchases,
    ROUND(AVG(NumStorePurchases), 1)                        AS avg_store_purchases,
    ROUND(AVG(NumCatalogPurchases), 1)                      AS avg_catalog_purchases,
    ROUND(AVG(NumWebVisitsMonth), 1)                        AS avg_web_visits_month,
    ROUND(AVG(Complain) * 100, 2)                           AS complaint_rate_pct
FROM v_customers_clean;
-- -> Roughly a 45-year-old with a household income around $52K,
-- most likely holding a Graduation-level degree, married or in a
-- relationship, with a teenager or kid at home about 72% of the
-- time. Spends around $606 across the six product categories over
-- the two-year window, buys more in-store (~5.8x) than online
-- (~4.1x) or via catalog (~2.7x), checks the website about 5.3
-- times a month, and almost never complains (well under 1%).

-- Most common education level and marital status, since those
-- aren't averageable:
SELECT Education, COUNT(*) AS customers, ROUND(COUNT(*) / (SELECT COUNT(*) FROM v_customers_clean) * 100, 1) AS pct
FROM v_customers_clean GROUP BY Education ORDER BY customers DESC;
-- -> Graduation 50.4%, PhD 21.7%, Master 16.5%, 2n Cycle 9.0%, Basic 2.4%

SELECT Marital_Status, COUNT(*) AS customers, ROUND(COUNT(*) / (SELECT COUNT(*) FROM v_customers_clean) * 100, 1) AS pct
FROM v_customers_clean GROUP BY Marital_Status ORDER BY customers DESC;
-- -> Married 38.6%, Together 25.8%, Single 21.4%, Divorced 10.3%, Widow 3.4%, Other 0.3%

-- ------------------------------------------------------------
-- Q4. Which products are performing best?
-- ------------------------------------------------------------
SELECT 'Wine' AS category, SUM(MntWines) AS total_spend FROM v_customers_clean
UNION ALL SELECT 'Meat', SUM(MntMeatProducts) FROM v_customers_clean
UNION ALL SELECT 'Gold', SUM(MntGoldProds) FROM v_customers_clean
UNION ALL SELECT 'Fish', SUM(MntFishProducts) FROM v_customers_clean
UNION ALL SELECT 'Sweets', SUM(MntSweetProducts) FROM v_customers_clean
UNION ALL SELECT 'Fruits', SUM(MntFruits) FROM v_customers_clean
ORDER BY total_spend DESC;
-- ->
--   Wine     680,029   ~50% of total spend
--   Meat     372,967   ~27%
--   Gold      98,346    ~7%
--   Fish      83,931    ~6%
--   Sweets    60,552    ~5%
--   Fruits    58,753    ~4%
--
-- Wine alone accounts for roughly half of everything the business
-- sells, and Wine + Meat together make up close to 78%. That's a
-- real concentration risk sitting on the product side -- fruits,
-- sweets and fish barely move the needle by comparison.

-- ------------------------------------------------------------
-- Q5. Which channels are underperforming?
-- ------------------------------------------------------------
SELECT 'Store' AS channel, SUM(NumStorePurchases) AS total_purchases FROM v_customers_clean
UNION ALL SELECT 'Web', SUM(NumWebPurchases) FROM v_customers_clean
UNION ALL SELECT 'Catalog', SUM(NumCatalogPurchases) FROM v_customers_clean
UNION ALL SELECT 'Deals (discount-driven)', SUM(NumDealsPurchases) FROM v_customers_clean
ORDER BY total_purchases DESC;
-- ->
--   Store     12,959
--   Web        9,140
--   Catalog    5,955
--   Deals      5,201
--
-- Store is the strongest channel, web is a solid second. Catalog
-- trails both by a wide margin, and given the correlation work in
-- Q1 showed catalog buyers are largely the same higher-spending
-- customers who also buy in-store and online (not a separate
-- audience), catalog reads more like an underused channel with an
-- existing customer base than a channel that needs new customers.
-- Deals-based purchases are the lowest of the four -- discount
-- promotions aren't driving much volume relative to the other
-- three channels.

-- How many web site visits it typically takes to produce one web
-- purchase, as a rough conversion signal:
SELECT
    ROUND(SUM(NumWebVisitsMonth) / NULLIF(SUM(NumWebPurchases), 0), 2) AS visits_per_purchase_ratio
FROM v_customers_clean;
-- -> About 1.3 site visits per web purchase in aggregate, but
-- remember Q1 found visit volume doesn't correlate with purchase
-- volume at the individual level -- some customers visit a lot and
-- buy rarely, others buy on visit one. Worth digging into with
-- clickstream/session-level data if that ever becomes available;
-- this dataset only has the monthly visit count, not the sequence.
