import pandas as pd
from datetime import datetime

# ===============================
# LOAD RAW TRANSACTION DATA
# ===============================
df = pd.read_csv("Data/customer_data.csv", header=None)

df.columns = [
    "transaction_id",
    "customer_id",
    "transaction_date",
    "product_id",
    "quantity",
    "sales_amount",
    "c6","c7","c8","c9","c10"
]

# ===============================
# DATA CLEANING
# ===============================
df["transaction_date"] = pd.to_datetime(df["transaction_date"], errors="coerce")
df["sales_amount"] = pd.to_numeric(df["sales_amount"], errors="coerce")

df = df.dropna(subset=["customer_id", "transaction_date", "sales_amount"])

# ===============================
# CUSTOMER-LEVEL AGGREGATION
# ===============================
rfm = df.groupby("customer_id").agg(
    last_purchase_date=("transaction_date", "max"),
    frequency=("transaction_id", "count"),
    monetary=("sales_amount", "sum")
).reset_index()

# ===============================
# RECENCY CALCULATION (CREATE IT FIRST)
# ===============================
rfm["recency"] = (datetime.now() - rfm["last_purchase_date"]).dt.days

# ===============================
# SAFE RFM SCORING (NO qcut CRASH)
# ===============================
rfm["recency"] = rfm["recency"].fillna(rfm["recency"].median())
rfm["frequency"] = rfm["frequency"].fillna(0)
rfm["monetary"] = rfm["monetary"].fillna(0)

# Dynamic bins (handles small data)
r_bins = min(5, rfm["recency"].nunique())
f_bins = min(5, rfm["frequency"].nunique())
m_bins = min(5, rfm["monetary"].nunique())

rfm["R"] = pd.qcut(
    rfm["recency"],
    q=r_bins,
    labels=False,
    duplicates="drop"
)

rfm["F"] = pd.qcut(
    rfm["frequency"].rank(method="first"),
    q=f_bins,
    labels=False,
    duplicates="drop"
)

rfm["M"] = pd.qcut(
    rfm["monetary"],
    q=m_bins,
    labels=False,
    duplicates="drop"
)

# Convert to 1–5 scale
rfm["R"] = 5 - rfm["R"]
rfm["F"] = rfm["F"] + 1
rfm["M"] = rfm["M"] + 1

# ===============================
# SEGMENTATION
# ===============================
rfm["segment"] = "Hibernating"

rfm.loc[
    (rfm["R"] >= 4) & (rfm["F"] >= 4) & (rfm["M"] >= 4),
    "segment"
] = "Champion"

rfm.loc[
    (rfm["R"] >= 3) & (rfm["F"] >= 3),
    "segment"
] = "Loyalist"

# ===============================
# SAVE OUTPUT
# ===============================
rfm.to_csv("Data/rfm_output.csv", index=False)

print("✅ Consumer360 Week-2 Analytics Completed Successfully")
