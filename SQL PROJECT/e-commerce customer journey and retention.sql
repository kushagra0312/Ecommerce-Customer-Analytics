-- ====================================================================
-- E-COMMERCE CUSTOMER JOURNEY, RETENTION & REVENUE INTELLIGENCE SYSTEM
-- ====================================================================

-- ==========
-- LOAD DATA 
-- ==========
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    country VARCHAR(50),
    age INT,
    signup_date DATE,
    marketing_opt_in BOOLEAN
);

CREATE TABLE sessions (
    session_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    start_time TIMESTAMP,
    device VARCHAR(50),
    source VARCHAR(50),
    country VARCHAR(50),
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE events (
    event_id VARCHAR(50) PRIMARY KEY,
    session_id VARCHAR(50),
    timestamp TIMESTAMP,
    event_type VARCHAR(50),
    product_id VARCHAR(50),
    qty DECIMAL(10,2),
    cart_size decimal(10,2),
    payment VARCHAR(50),
    discount_pct DECIMAL(5,2),
    amount_usd DECIMAL(10,2),

    FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(100),
    name VARCHAR(255),
    price_usd DECIMAL(10,2),
    cost_usd DECIMAL(10,2),
    margin_usd DECIMAL(10,2)
);
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_time TIMESTAMP,
    payment_method VARCHAR(50),
    discount_pct DECIMAL(5,2),
    subtotal_usd DECIMAL(10,2),
    total_usd DECIMAL(10,2),
    country VARCHAR(50),
    device VARCHAR(50),
    source VARCHAR(50),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    unit_price_usd DECIMAL(10,2),
    quantity INT,
    line_total_usd DECIMAL(10,2),

    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE reviews (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    rating INT,
    review_text TEXT,
    review_time TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- ========
-- INDEXING
-- ========
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_time ON orders(order_time);
CREATE INDEX idx_order_items_order ON order_items(order_id);

-- ============================================
-- DATA CLEANING & EXPLORATORY DATA ANALYSIS
-- ============================================

-- CHECK TOTAL RECORDS BASIC STRUCTURE
SELECT COUNT(*) AS total_rows FROM orders;
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM orders;
SELECT COUNT(DISTINCT order_id) AS total_orders FROM orders;

-- CHECK DUPLICATE RECORDS
SELECT order_id, COUNT(*) 
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- CHECK NULL VALUES
SELECT 
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customers,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_orders,
    COUNT(*) FILTER (WHERE order_time IS NULL) AS null_order_time,
    COUNT(*) FILTER (WHERE total_usd IS NULL) AS null_revenue
FROM orders;

-- CHECK INVALID REVENUE VALUES
SELECT *
FROM orders
WHERE total_usd <= 0;

-- CHECK DATA RANGE (DATA VALIDITY)
SELECT 
    MIN(order_time) AS first_order,
    MAX(order_time) AS last_order
FROM orders;

-- CHECK TIME GAPS/OUTLIERS
SELECT 
    customer_id,
    MAX(order_time) - MIN(order_time) AS lifespan
FROM orders
GROUP BY customer_id
ORDER BY lifespan DESC;

-- REVENUE DISTRIBUTION
SELECT 
    MIN(total_usd) AS min_value,
    MAX(total_usd) AS max_value,
    AVG(total_usd) AS avg_value
FROM orders;

-- ORDERS PER CUSTOMER
SELECT 
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC;

-- CHECK DATA CONSISTENCY
SELECT order_id, COUNT(DISTINCT customer_id)
FROM orders
GROUP BY order_id
HAVING COUNT(DISTINCT customer_id) > 1;

-- MONTHLY TREND
SELECT 
    DATE_TRUNC('month', order_time) AS month,
    COUNT(order_id) AS total_orders,
    SUM(total_usd) AS revenue
FROM orders
GROUP BY month
ORDER BY month;

-- ============================================
-- KPI ANALYSIS – BUSINESS PERFORMANCE OVERVIEW
-- ============================================ 
-- BUSINESS PROBLEM
-- The business lacks a clear understanding of its overall performance in terms of 
-- customer base, order volume, and revenue generation.
-- Without key performance indicators, it is difficult to evaluate growth, 
-- customer behavior, and revenue efficiency.”

-- OBJECTIVE
-- The objective is to calculate core business KPIs such as total customers, 
-- total orders, total revenue, and average order value to establish a 
-- baseline understanding of business performance.

SELECT 
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(order_id) AS total_orders,    
    ROUND(SUM(total_usd), 2) AS total_revenue,    
    ROUND(SUM(total_usd) / COUNT(order_id), 2) AS avg_order_value,
    ROUND(COUNT(order_id) * 1.0 / COUNT(DISTINCT customer_id), 2) AS avg_orders_per_customer,    
    ROUND(SUM(total_usd) * 1.0 / COUNT(DISTINCT customer_id), 2) AS avg_revenue_per_customer
FROM orders;

-- =========
-- INSIGHTS
-- =========
-- avg_orders_per_customer ≈ 2 and avg_revenue_per_customer = $276 (~2× AOV)
-- confirms most customers buy once or twice then stop.
-- Growth must come from increasing purchase frequency, not raising prices.
-- A third purchase per customer adds ~$133 revenue at zero acquisition cost.

-- ========================
-- SALES & REVENUE ANALYSIS
-- ========================

-- BUSINESS PROBLEM
-- The company lacks visibility into revenue trends, growth patterns, 
-- and average customer spending behavior over time.

-- OBJECTIVE
-- Track monthly revenue trends
-- Measure growth rate
-- Analyze Average Order Value (AOV)

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_time) AS month_date,
        SUM(total_usd) AS revenue,
        COUNT(order_id) AS total_orders,
        AVG(total_usd) AS avg_order_value
    FROM orders
    GROUP BY 1
)

SELECT
    TO_CHAR(month_date, 'Mon YYYY') AS month,

    ROUND(revenue, 2) AS revenue,
    total_orders,

    ROUND(avg_order_value, 2) AS avg_order_value,

    ROUND(
        LAG(revenue) OVER (ORDER BY month_date), 2
    ) AS prev_month_revenue,

    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month_date)) * 1.0 /
        NULLIF(LAG(revenue) OVER (ORDER BY month_date), 0),
        2
    ) AS growth_rate

FROM monthly_sales
ORDER BY month_date;

-- ========
-- INSIGHTS
-- ========
-- Revenue holds in the $60K–$70K band with no compounding growth —
-- volume drives revenue, not increasing spend per customer (AOV flat at $120–$145).

-- Consistent spikes in Jul and Dec (+19%) indicate seasonal demand peaks.
-- Consistent drops in Feb (−28% in both 2023 and 2025) confirm a recurring trough.

-- Revenue cannot sustain its peaks because the business relies on new customer
-- acquisition rather than retention — cohort analysis confirms this directly.

-- =======================================
-- CUSTOMER SEGMENTATION (RFM ANALYSIS)
-- =======================================
-- BUSINESS PROBLEM
-- The company does not know which customers are high-value, at-risk, or low-engagement,
-- leading to inefficient marketing and poor retention.

-- OBJECTIVE
-- Segment customers based on:
-- Recency → How recently they purchased
-- Frequency → How often they purchase
-- Monetary → How much they spend

WITH rfm_base AS (
    SELECT
        customer_id,
        MAX(order_time) AS last_purchase,
        COUNT(order_id) AS frequency,
        SUM(total_usd) AS monetary
    FROM orders
    GROUP BY customer_id
),

rfm_scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY last_purchase DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS monetary_score
    FROM rfm_base
)

SELECT *,
    (recency_score + frequency_score + monetary_score) AS rfm_score
FROM rfm_scores;

-- ========
-- INSIGHTS
-- ========
-- Low RFM scores (3–6) = Champions and Loyal Customers —
-- most recent, most frequent, highest spend. Smallest group, largest revenue share.

-- Customers with frequency ≥ 3 and monetary ≥ $500 carry a disproportionate
-- share of total revenue. Losing even a few of them has outsized impact.

-- High monetary but low recency = highest priority win-back target.
-- These customers spent significantly before and have gone quiet —
-- they are recoverable if targeted before crossing into Churned.

-- ==========================
-- COHORT RETENTION ANALYSIS
-- ==========================
-- BUSINESS PROBLEM
-- The company does not know:
-- How many customers return after first purchase
-- How long they stay active
-- Whether retention is improving or declining
-- This leads to poor retention strategy

-- OBJECTIVE
-- Analyze:
-- Customer retention over time
-- Behavior of users after first purchase
-- Using cohort analysis 

WITH first_purchase AS (
    SELECT 
        customer_id,
        MIN(DATE_TRUNC('month', order_time)) AS cohort_month
    FROM orders
    GROUP BY customer_id
),

cohort_data AS (
    SELECT 
        o.customer_id,
        DATE_TRUNC('month', o.order_time) AS order_month,
        f.cohort_month,
        EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', o.order_time), f.cohort_month)) AS month_number
    FROM orders o
    JOIN first_purchase f 
        ON o.customer_id = f.customer_id
),

cohort_counts AS (
    SELECT 
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_id) AS customers
    FROM cohort_data
    GROUP BY cohort_month, month_number
),

cohort_size AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM first_purchase
    GROUP BY cohort_month
)

SELECT 
    TO_CHAR (c.cohort_month, 'YYYY-MON-DD') AS cohort_month,
    c.month_number,
    c.customers,
    s.total_customers,
    ROUND(c.customers * 1.0 / s.total_customers, 2) AS retention_rate
FROM cohort_counts c
JOIN cohort_size s 
    ON c.cohort_month = s.cohort_month
ORDER BY c.cohort_month, c.month_number;

-- ========
-- INSIGHTS
-- ========
-- Month-1 retention is only 5–16% across all cohorts — 84–95% of customers
-- never make a second purchase. This is the steepest drop in the entire funnel.

-- Cohort quality is declining: 2020 cohorts retained 10–17% at month 1,
-- 2022–2023 cohorts retain only 5–10%. Each new customer batch is weaker.

-- Customers who survive month 1 tend to stay active through month 6–12.
-- The entire retention problem sits at the first-to-second purchase moment.
-- Fixing this one stage is worth more than any other initiative in the business.

-- ============================================
-- PRODUCT PERFORMANCE & MARKET BASKET ANALYSIS
-- =============================================
-- BUSINESS PROBLEM
-- The company does NOT know:
-- Which products are top performers
-- Which products should be promoted or removed
-- What combinations of products customers buy together

-- OBJECTIVE
-- Top & Bottom Products (Revenue)
-- Product Demand (Quantity Sold)
-- Frequently Bought Together (Market Basket)

-- TOP & LOW PERFORMING PRODUCTS

WITH product_performance AS (
    SELECT 
        p.name,
        SUM(oi.unit_price_usd * oi.quantity) AS total_revenue
    FROM order_items oi
    JOIN products p 
        ON oi.product_id = p.product_id
    GROUP BY p.name
),

ranked_products AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY total_revenue DESC) AS revenue_bucket
    FROM product_performance
)

SELECT 
    name,
    ROUND(total_revenue, 2) AS total_revenue,
    CASE 
        WHEN revenue_bucket = 1 THEN 'Top Performing'
        WHEN revenue_bucket IN (2,3,4) THEN 'Mid Performing'
        ELSE 'Low Performing'
    END AS performance_category
FROM ranked_products
ORDER BY total_revenue DESC;

-- PRODUCT DEMAND SEGMENTATION

WITH product_demand AS (
    SELECT 
        p.name,
        SUM(oi.quantity) AS total_units_sold
    FROM order_items oi
    JOIN products p 
        ON oi.product_id = p.product_id
    GROUP BY p.name
),

ranked_demand AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY total_units_sold DESC) AS demand_bucket
    FROM product_demand
)

SELECT 
    name,
    total_units_sold,
    CASE 
        WHEN demand_bucket = 1 THEN 'High Demand'
        WHEN demand_bucket IN (2,3,4) THEN 'Moderate Demand'
        ELSE 'Low Demand'
    END AS demand_category
FROM ranked_demand
ORDER BY total_units_sold DESC;

-- MARKET BASKET

SELECT 
    p1.name AS product_1,
    p2.name AS product_2,
    COUNT(*) AS frequency
FROM order_items oi1
JOIN order_items oi2 
    ON oi1.order_id = oi2.order_id
    AND oi1.product_id < oi2.product_id
JOIN products p1 
    ON oi1.product_id = p1.product_id
JOIN products p2 
    ON oi2.product_id = p2.product_id
GROUP BY p1.name, p2.name
ORDER BY frequency DESC;

-- =========
-- INSIGHTS
-- =========
-- High quantity sold ≠ high revenue — inventory decisions should use
-- quantity rank, margin decisions should use revenue rank. These are different lists.

-- Market basket pairs are the lowest-effort AOV growth lever available:
-- products frequently bought together should be shown as bundles at checkout.

-- ======================================
-- CUSTOMER LIFETIME VALUE (CLV) ANALYSIS
-- ======================================

-- BUSINESS PROBLEM
-- The company wants to estimate how much revenue a customer generates over time to:
-- Identify high-value customers
-- Optimize marketing spend
-- Improve retention strategies

-- OBJECTIVE
-- Calculate CLV per customer using:
-- Purchase frequency
-- Average order value
-- Customer lifespan
-- Improve overall profitability

WITH customer_metrics AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total_usd) AS total_revenue,
        MIN(order_time) AS first_purchase,
        MAX(order_time) AS last_purchase
    FROM orders
    GROUP BY customer_id
),

customer_lifespan AS (
    SELECT
        customer_id,
        total_orders,
        total_revenue,
        (last_purchase - first_purchase) AS lifespan_days,
        ROUND(
            EXTRACT(EPOCH FROM AGE(last_purchase, first_purchase)) 
            / (365*24*60*60), 
        2) AS lifespan_years,
        ROUND(
            (EXTRACT(EPOCH FROM AGE(last_purchase, first_purchase)) 
            / (365*24*60*60)) * 12, 
        1) AS lifespan_months
    FROM customer_metrics
)

SELECT 
    customer_id,
    total_orders,
    total_revenue,
    lifespan_days,
    lifespan_months,
    lifespan_years,
    ROUND(
        CASE 
            WHEN lifespan_years = 0 THEN total_revenue
            ELSE total_revenue / lifespan_years
        END
    , 2) AS annual_clv
FROM customer_lifespan
ORDER BY annual_clv DESC;

-- ========
-- INSIGHTS
-- ========
-- annual_clv drops sharply after the top tier — a small group generates
-- $300–$500+/year while the majority sit under $150. Revenue is concentrated.

-- Customers with lifespan_days = 0 are single-session buyers. Their CLV equals
-- one order value ($133) with no recurring contribution. They inflate customer
-- count but do not build sustainable revenue.

-- The gap between one-time buyers (CLV ≈ $133) and repeat buyers (CLV ≈ $276+)
-- shows the second purchase is the highest-value event in a customer's lifecycle.
-- It is the moment a buyer becomes a recurring revenue source.

-- Read CLV alongside RFM: high m_score + low lifespan_years = Big Spender who
-- just arrived. High m_score + high lifespan_years = Champion who compounds.
-- Same revenue today, completely different actions required.


-- =======================
-- CUSTOMER CHURN ANALYSIS
-- =======================
-- BUSINESS PROBLEM
-- The company is losing customers but doesn’t know:
-- Who is likely to churn
-- How many customers are already inactive
-- What revenue is at risk

-- OBJECTIVE
-- Identify:
-- Churned customers
-- At-risk customers
-- Active customers

WITH max_date AS (
    SELECT MAX(order_time)::date AS max_order_date
    FROM orders
),

customer_metrics AS (
    SELECT 
        customer_id,
        SUM(total_usd) AS total_revenue,
        MAX(order_time)::date AS last_order
    FROM orders
    GROUP BY customer_id
),

churn_calc AS (
    SELECT 
        c.customer_id,
        c.total_revenue,
        (m.max_order_date - c.last_order) AS days_since_last_order
    FROM customer_metrics c
    CROSS JOIN max_date m
),

churn_segment AS (
    SELECT *,
        CASE 
            WHEN days_since_last_order <= 180 THEN 'Active'
            WHEN days_since_last_order <= 365 THEN 'At Risk'
            ELSE 'Churned'
        END AS status
    FROM churn_calc
)

SELECT 
    status,
    COUNT(customer_id) AS customers,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer,

    ROUND(100.0 * COUNT(customer_id) / SUM(COUNT(customer_id)) OVER (), 2) AS customer_percentage,
    ROUND(100.0 * SUM(total_revenue) / SUM(SUM(total_revenue)) OVER (), 2) AS revenue_percentage

FROM churn_segment
GROUP BY status
ORDER BY total_revenue DESC;

-- ========
-- INSIGHTS
-- ========
-- Active customers (≤180 days) are the revenue base — their avg_revenue_per_customer
-- sets the benchmark for what one retained customer is worth.

-- At Risk customers (181–365 days) are the most valuable intervention target.
-- They have proven willingness to spend but have not returned.
-- Their revenue_percentage shows exactly how much recoverable revenue is at stake.

-- Churned customers (>365 days) have the lowest recovery probability.
-- Re-acquisition cost typically exceeds the return — suppress from paid campaigns.

-- If At Risk customers hold 20–30% of total revenue, a 20% win-back rate
-- is more efficient than any new acquisition campaign at equivalent budget.


-- ====================================
-- ULTIMATE CUSTOMER SEGMENTATION TABLE
-- ====================================
-- BUSINESS PROBLEM
-- Identify different types of customers to improve retention and revenue.

-- OBJECTIVE 
-- Create a unified segmentation using RFM + CLV + lifespan.

WITH base AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total_usd) AS total_revenue,
        AVG(total_usd) AS avg_order_value,
        MIN(order_time) AS first_purchase,
        MAX(order_time) AS last_purchase       
    FROM orders
    GROUP BY customer_id
),

lifecycle AS (
    SELECT *,
        (last_purchase - first_purchase) AS lifespan_days,

        ROUND(
            EXTRACT(EPOCH FROM AGE(last_purchase, first_purchase)) 
            / (365*24*60*60), 2
        ) AS lifespan_years,

        CASE 
            WHEN EXTRACT(EPOCH FROM AGE(last_purchase, first_purchase)) = 0 
            THEN total_revenue
            ELSE total_revenue / 
                 (EXTRACT(EPOCH FROM AGE(last_purchase, first_purchase)) / (365*24*60*60))
        END AS annual_clv
    FROM base
),
rfm AS (
    SELECT *,
        CURRENT_DATE - last_purchase  AS recency_days
    FROM lifecycle
),

rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days ASC) AS r_score,
        NTILE(5) OVER (ORDER BY total_orders DESC) AS f_score,
        NTILE(5) OVER (ORDER BY total_revenue DESC) AS m_score
    FROM rfm
)

SELECT 
    customer_id,
    total_orders,
    total_revenue,
    ROUND(avg_order_value,2) AS avg_order_value,
    lifespan_days,
    ROUND(lifespan_years,2) AS lifespan_years,
    ROUND(annual_clv,2) AS annual_clv,
    recency_days,
    r_score,
    f_score,
    m_score,
   CASE 
    WHEN r_score >= 4 AND (f_score >= 4 OR m_score >= 4) THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
    WHEN m_score >= 4 AND r_score >= 3 THEN 'Big Spenders'
    WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
    WHEN r_score <= 2 AND (f_score >= 3 OR m_score >= 3) THEN 'At Risk'
    WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost Customers'
    ELSE 'Average Customers'
END AS customer_segment
FROM rfm_scores
ORDER BY annual_clv DESC;

-- ========================
-- BUSINESS RECOMMENDATIONS
-- ========================

-- These recommendations are derived directly from the KPI, RFM, Cohort,
-- CLV, Churn, and Segmentation analyses above.

-- -----------------------------------------------------------------------
-- RECOMMENDATION 1: STOP LOSING REVENUE TO CHURN — ACT ON AT-RISK SEGMENT
-- -----------------------------------------------------------------------
-- Finding:
-- Churn analysis shows customers are classified into Active (≤240 days),
-- At Risk (241–365 days), and Churned (>365 days).
-- At Risk customers still hold significant avg_revenue_per_customer but
-- are approaching the point of no return.

-- Action:
-- Launch a win-back campaign exclusively for the 'At Risk' segment.
-- Offer a time-limited discount (10–15%) triggered at day 180 of inactivity
-- — before they cross into Churned. This is cheaper than acquiring new customers.
-- Priority: HIGH. Target this segment before any new acquisition spend.

-- -----------------------------------------------------------------------
-- RECOMMENDATION 2: PROTECT CHAMPIONS — THEY CARRY DISPROPORTIONATE REVENUE
-- -----------------------------------------------------------------------
-- Finding:
-- Final segmentation shows 'Champions' have r_score >= 4 AND f_score/m_score >= 4.
-- KPI analysis confirms avg_revenue_per_customer = $276, which is 2× AOV ($133),
-- meaning a small group of repeat buyers drives the bulk of revenue.
-- Business is over-dependent on this thin segment.

-- Action:
-- Introduce a VIP loyalty program for Champions and Loyal Customers.
-- Offer early access, free shipping, or exclusive deals — not discounts
-- (they already buy; discounts only erode margin).
-- Goal: Increase their lifespan_years, not just their next order.

-- -----------------------------------------------------------------------
-- RECOMMENDATION 3: FIX THE SECOND-PURCHASE PROBLEM
-- -----------------------------------------------------------------------
-- Finding:
-- avg_orders_per_customer ≈ 2. Cohort retention shows month-1 retention
-- of only 5–16%, meaning most customers never return after first purchase.
-- This is the single biggest growth lever in the business.

-- Action:
-- Create a "second purchase" automated email sequence triggered 7 days
-- after first order. Offer a small incentive (free shipping or 5% off)
-- only for customers with 1 order and r_score >= 4 (recently active).
-- Even moving 2-order customers to 3 orders at $133 AOV = +$133 revenue
-- per customer with zero acquisition cost.

-- -----------------------------------------------------------------------
-- RECOMMENDATION 4: DO NOT WASTE BUDGET ON LOST CUSTOMERS
-- -----------------------------------------------------------------------
-- Finding:
-- 'Lost Customers' (r_score <= 2, f_score <= 2) have low annual_clv
-- and have not purchased in over 365 days.
-- Re-engaging them costs more than the revenue they return.

-- Action:
-- Suppress 'Lost Customers' from all paid marketing campaigns immediately.
-- Redirect that budget toward 'At Risk' and 'New Customers' segments.
-- Only attempt a single low-cost re-engagement email per year for this group
-- (e.g., a birthday offer or annual "we miss you" message).

-- -----------------------------------------------------------------------
-- RECOMMENDATION 5: GROW AOV THROUGH BUNDLING, NOT DISCOUNTING
-- -----------------------------------------------------------------------
-- Finding:
-- AOV is stable at $120–$145 across all months per revenue analysis.
-- Revenue fluctuations are driven by order volume, not spend per order.
-- Market basket analysis shows which products are frequently bought together.

-- Action:
-- Use frequently-bought-together product pairs from market basket analysis
-- to create bundles at a slight premium (e.g., "buy both for $X").
-- Target 'New Customers' and 'Average Customers' segments with bundle offers
-- at checkout. Goal: push AOV from ~$133 toward $150+ without touching pricing.

-- -----------------------------------------------------------------------
-- RECOMMENDATION 6: INVEST IN JULY AND DECEMBER — SUPPRESS IN FEBRUARY
-- -----------------------------------------------------------------------
-- Finding:
-- Revenue analysis shows consistent growth spikes in Jul (+19%) and Dec (+19%)
-- and consistent drops in Feb (−28%) and post-peak months.
-- This pattern is seasonal and predictable.

-- Action:
-- Pre-load marketing budget into June and November to capitalize on
-- natural demand peaks in July and December.
-- In February, shift from acquisition campaigns to retention campaigns —
-- focus on Champions and Loyal Customers who will buy regardless of season.
-- Do not run discount campaigns in February — they burn margin at low-demand periods.

-- -----------------------------------------------------------------------
-- RECOMMENDATION 7: INCREASE BIG SPENDERS' PURCHASE FREQUENCY
-- -----------------------------------------------------------------------
-- Finding:
-- 'Big Spenders' have m_score >= 4 but may have lower f_score — they spend
-- a lot per order but don't return often. annual_clv is high on a per-order basis
-- but their lifetime value is limited by low purchase frequency.

-- Action:
-- Send Big Spenders a personalized "you might like" recommendation email
-- 30 days after each purchase based on their last product category.
-- Goal: increase their total_orders from low frequency toward 3+ orders,
-- which compounds directly into annual_clv growth.