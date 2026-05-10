import pandas as pd
from sqlalchemy import create_engine

print("Reading parquet...")
listings = pd.read_parquet(
    "listings.parquet",
    engine="pyarrow"
)

past_rates = pd.read_parquet(
    "past_rates.parquet",
    engine="pyarrow"
)

print("Connecting DB...")
engine = create_engine(
    "mysql+pymysql://root:11001010aaB@localhost/airBnB_Market"
)

print("Importing...")

listings.to_sql(
    "listings",
    con=engine,
    if_exists="append",
    index=False,
    chunksize=5000,
    method="multi"
)

past_rates.to_sql(
    "past_rates",
    con=engine,
    if_exists="append",
    index=False,
    chunksize=5000,
    method="multi"
)

print("Done")