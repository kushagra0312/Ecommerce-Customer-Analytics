# 🛍️ E-Commerce Customer Analytics & Churn Prediction System

> **End-to-end E-Commerce Analytics platform combining RFM Segmentation, Cohort Retention, K-Means Clustering, Churn Prediction ML Model, SQL Analytics, Power BI Dashboards, and a Natural Language AI Agent.**

---

## 📌 Project Overview

This project solves one of the most expensive problems in e-commerce — **customer churn**. With a 69.4% churn rate and ₹2.86M in churned revenue, the goal was to build a complete analytics system that identifies at-risk customers, segments them by value, and enables data-driven retention strategies.

Using a dataset of **16,000 customers** across 7 interconnected tables, I built a full pipeline from raw behavioral data to ML-powered churn prediction, RFM segmentation, cohort analysis, and an AI agent for real-time business queries.

---

## 🎯 Business Problem

> An e-commerce company is losing 69.4% of its customers with ₹2.86M in churned revenue. The business needs to identify which customers will churn, segment them by value, and take proactive retention actions before revenue is lost.

---

## 📊 Key Business Results

| Metric | Value |
|--------|-------|
| Total Customers | 16,000 |
| Total Revenue | ₹4.49M |
| Churn Rate | 69.4% |
| Churned Revenue Loss | ₹2.86M |
| At Risk Customers | 2,397 |
| Revenue at Risk | ₹752K |
| Avg Churn Probability | 83.2% |
| Early Churn Risk Rate | 80.1% |

---

## 🏗️ Project Architecture

```
Raw Dataset (7 tables — customers, orders, order_items,
            products, events, sessions, reviews)
        │
        ▼
┌───────────────────┐
│  Python — EDA,    │
│  RFM, Cohort,     │
│  K-Means, Churn   │
└────────┬──────────┘
         │
         ▼
┌───────────────────┐     ┌──────────────────────┐
│  ML Model         │────▶│  Streamlit App        │
│  (Random Forest)  │     │  (Live Prediction)    │
└────────┬──────────┘     └──────────────────────┘
         │
         ▼
┌───────────────────┐     ┌──────────────────────┐
│  SQL Analytics    │────▶│  Power BI Dashboard   │
│  (PostgreSQL)     │     │  (Business Insights)  │
└────────┬──────────┘     └──────────────────────┘
         │
         ▼
┌───────────────────┐
│  AI SQL Agent     │
│  (n8n + LLaMA)    │
│  Natural Language │
│  → SQL → Answer   │
└───────────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Tools |
|-------|-------|
| Language | Python 3.x |
| Data Processing | Pandas, NumPy |
| Visualization | Matplotlib, Seaborn |
| Machine Learning | Scikit-learn (Random Forest, K-Means, GridSearchCV) |
| Database | PostgreSQL (Supabase) |
| SQL Analytics | Advanced SQL (CTEs, Window Functions, Cohort Analysis) |
| BI Dashboard | Power BI |
| Deployment | Streamlit |
| AI Agent | n8n, LLaMA 3.1 70B (OpenRouter), PostgreSQL Tool |
| Version Control | Git, GitHub |

---

## 📁 Project Structure

```
Ecommerce-Customer-Analytics/
│
├── 📓 PYTHON PROJECT/
│   └── CUSTOMER_ANALYTICS_CHURN_PREDICTION_SYSTEM.ipynb
│
├── 🖥️ CHURN PREDICTION APP/
│   └── app.py
│
├── 🗄️ SQL PROJECT/
│   └── e-commerce_customer_journey_and_retention.sql
│
├── 📊 POWER BI DASHBOARD/
│   ├── dashboard1_churn_executive.png
│   ├── dashboard2_customer_behaviour.png
│   ├── dashboard3_rfm_analysis.png
│   └── dashboard4_retention_strategy.png
│
├── 🤖 AI AUTOMATION/
│   ├── Ecommerce_AI_AGENT.json
│   └── Ecommerce_2.json
│
├── requirements.txt
└── README.md
```

---

## 📈 Power BI Dashboards

### 1️⃣ Customer Churn Executive Dashboard
![Dashboard 1](POWER%20BI%20DASHBOARD/dashboard1_churn_executive.png)
> 16K customers with 69.4% churn rate. Churned customers contribute ₹2.86M in revenue loss. Veteran customers show highest churn concentration at 3,038.

---

### 2️⃣ Customer Behaviour Analysis
![Dashboard 2](POWER%20BI%20DASHBOARD/dashboard2_customer_behaviour.png)
> Active customers average 2.6 orders and ₹340 revenue vs churned at 1.9 orders and ₹254. High engagement tier shows significantly better retention.

---

### 3️⃣ RFM Segment Analysis & Customer Value
![Dashboard 3](POWER%20BI%20DASHBOARD/dashboard3_rfm_analysis.png)
> Loyal Customers (4,610) and Champions (2,519) drive the most revenue at ₹1,399K and ₹1,324K. Lost Customers (2,678) represent ₹172K in recoverable revenue.

---

### 4️⃣ Customer Retention Strategy
![Dashboard 4](POWER%20BI%20DASHBOARD/dashboard4_retention_strategy.png)
> Data-driven retention strategy table with trigger conditions and actions per segment. 6,223 low engagement customers identified as early churn risk (80.1%).

---

## 🔬 Machine Learning Pipeline

### Data Preparation
- Customer-level feature engineering from raw order data
- Features: `total_orders`, `total_revenue`, `avg_order_value`, `lifespan_days`
- 3-class target: `Active`, `At Risk`, `Churned`
- Label encoding + train/test stratified split

### Model Development
- Built Scikit-learn Pipeline (Scaler + Random Forest Classifier)
- Hyperparameter tuning with GridSearchCV (3-fold CV)
- Best params: `n_estimators`, `max_depth`, `min_samples_split`
- Evaluated on ROC-AUC, Precision, Recall, F1-Score

### Prediction Classes
| Class | Meaning | Action |
|-------|---------|--------|
| 0 — Active | Healthy customer | Retain with loyalty programs |
| 1 — At Risk | Declining engagement | Personalized recommendations |
| 2 — Churned | Lost customer | Discount + re-engagement campaign |

---

## 🔍 Advanced Analytics (Python)

### Section 1 — Data Loading & Cleaning
- 7 table joins, null handling, duplicate removal, data validation

### Section 2 — KPI Summary
- Total customers, revenue, AOV, churn rate, lifespan metrics

### Section 3 — Sales & Revenue Analysis
- Monthly revenue trends, AOV distribution, device/source breakdown

### Section 4 — RFM Segmentation
- Recency, Frequency, Monetary scoring with NTILE-based bucketing
- 7 RFM segments: Champions, Loyal, At Risk, Lost, New, Average, Big Spenders

### Section 5 — Cohort Retention Heatmap
- Monthly cohort analysis showing retention drop-off over time
- 2022–2023 cohorts retain only 5–10% after Month 1

### Section 6 — Churn Prediction (ML)
- Random Forest with GridSearchCV pipeline
- Feature importance: lifespan_days and total_orders are top predictors

### Section 7 — K-Means Customer Clustering
- K=4 clusters justified by elbow method
- Cluster profiling on RFM dimensions

### Section 8 — Final Export for Power BI
- Enriched dataset with ML predictions + RFM scores exported for dashboarding

---

## 🗄️ SQL Analytics

**E-Commerce Customer Journey, Retention & Revenue Intelligence System**

Key sections covered:
- Data loading, indexing, cleaning, EDA
- KPI Analysis — Business Performance Overview
- Sales & Revenue Analysis (AOV, monthly trends)
- Customer Segmentation (RFM Analysis)
- Cohort Retention Analysis
- Customer Journey & Behaviour
- Retention Strategy Queries

---

## 🤖 AI SQL Agent

**Natural Language → SQL → Answer** pipeline built on n8n with LLaMA 3.1 70B via OpenRouter.

```
User: "Which country has the highest number of orders?"
        ↓
AI Agent (LLaMA 3.1 70B) generates SQL
        ↓
PostgreSQL executes query across 7 tables
        ↓
Answer: "The US has the highest orders with 6,138"
```

### Sample Questions
- *"What is the total revenue by device type?"*
- *"Which product category generates the highest revenue?"*
- *"Segment customers into High, Medium and Low value based on RFM"*
- *"Show me month over month revenue growth"*
- *"Which traffic source brings the most revenue?"*

### Setup
```bash
npx n8n                           # Start n8n locally
# Open http://localhost:5678
# Import Ecommerce_2.json (sub-workflow) first
# Import Ecommerce_AI_AGENT.json (main workflow)
# Add OpenRouter API key + Supabase credentials
# Activate and open chat
```

---

## 🖥️ Streamlit App

### Features
- Predict churn status for any customer in real-time
- 3-class output: Active / At Risk / Churned
- Actionable business recommendation per prediction
- Input summary display

### Run Locally
```bash
git clone https://github.com/kushagra0312/Ecommerce-Customer-Analytics.git
cd Ecommerce-Customer-Analytics
pip install -r requirements.txt
streamlit run app.py
```

> **Note:** `model.pkl` is not included due to GitHub's 25MB file size limit. Run the Jupyter notebook to train and generate the model file automatically.

---

## 💡 Key Business Insights

- 📌 **69.4% churn rate** with ₹2.86M revenue already lost
- 📌 **Churned customers average only 1.9 orders** vs 2.6 for active — low early engagement is the #1 churn signal
- 📌 **Veteran customers** show the highest churn concentration (3,038) — long-term customers are not being retained
- 📌 **Champions and Loyal customers** (7,129 combined) drive ₹2.72M revenue — protecting this segment is critical
- 📌 **80.1% early churn risk rate** — most customers churn very early in their lifecycle
- 📌 **Single Purchase tier** (38.3% of customers) represents the highest churn risk pool

---

## 📋 Retention Strategy

| Segment | Trigger | Action | Metric |
|---------|---------|--------|--------|
| Active | Lifespan > 1000 | Loyalty rewards | CLV |
| Active | Orders > 2.5 | Upsell premium | AOV |
| At Risk | No recent purchase | Re-engagement email | Conversion Rate |
| At Risk | Orders drop < 2.3 | Personalized offers | Retention Rate |
| Churned | Lifespan < 500 | Improve onboarding | Early Retention % |
| Churned | Total orders < 2 | 3-order incentive | Repeat Purchase Rate |

---

## ⚠️ Project Review & Honest Assessment

**Strengths:**
- Complete end-to-end pipeline from raw data to deployed app
- RFM + Cohort + K-Means + ML combined in one project
- Business-focused insights with actionable recommendations
- AI Agent adds modern automation layer

**Areas to improve before interviews:**
- The Streamlit app uses only 4 features — mention this is intentional for simplicity and that more features can be added
- Model accuracy should be stated clearly in README — run the notebook and add it
- The churn definition (3 classes) should be explained confidently if asked

---

## 👨‍💻 Author

**Kushagra Yadav** — Data Analyst
Python • SQL • Power BI • Machine Learning • AI Automation

[![GitHub](https://img.shields.io/badge/GitHub-kushagra0312-black?logo=github)](https://github.com/kushagra0312)

---

## 📄 License
MIT License
