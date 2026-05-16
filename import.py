import pandas as pd

from sqlalchemy import create_engine

# =========================================================
# READ PARQUET
# =========================================================

print("Reading parquet files...")

df_listings = pd.read_parquet(
    "listings.parquet",
    engine="pyarrow"
)

df_past_rates = pd.read_parquet(
    "past_rates.parquet",
    engine="pyarrow"
)

print("Parquet loaded")

# =========================================================
# CHECK SCHEMA
# =========================================================

print("\nListings Schema")
print(df_listings.dtypes)

print("\nPast Rates Schema")
print(df_past_rates.dtypes)

# =========================================================
# CONNECT MYSQL
# =========================================================

print("\nConnecting MySQL...")

engine = create_engine(
    "mysql+pymysql://root:11001010aaB@localhost/airBnB_Market"
)

print("Connected")

# =========================================================
# IMPORT LISTINGS
# =========================================================

print("\nImporting listings table...")

df_listings.to_sql(
    "listings",
    con=engine,
    if_exists="replace",
    index=False,
    chunksize=5000,
    method="multi"
)

print("Listings imported")

# =========================================================
# IMPORT PAST_RATES
# =========================================================

print("\nImporting past_rates table...")

df_past_rates.to_sql(
    "past_rates",
    con=engine,
    if_exists="replace",
    index=False,
    chunksize=5000,
    method="multi"
)

print("Past_rates imported")

print("\nDONE")