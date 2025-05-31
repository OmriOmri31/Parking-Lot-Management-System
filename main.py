"""
Creates DB schema  parkinglot  and table  cars
  car_id           INT auto-increment PRIMARY KEY
  licence_plate    VARCHAR(15)
  time_of_creation TIMESTAMP (defaults to NOW)
"""

import os
from dotenv import load_dotenv
import mysql.connector

# ── 1. load connection details from .env ───────────────────────────────────────
load_dotenv()                        # populates os.environ

host = os.getenv("DB_HOST")
port = int(os.getenv("DB_PORT", 3306))
user = os.getenv("DB_USER")
password = os.getenv("DB_PASS")

if not all([host, port, user, password]):
    raise RuntimeError("Missing DB_* variables; check your .env file")

# ── 2. open the connection ────────────────────────────────────────────────────
cnx = mysql.connector.connect(
    host=host,
    port=port,
    user=user,
    password=password,
    autocommit=True
)
cur = cnx.cursor()

# ── 3. create schema & table if they don’t exist ──────────────────────────────
cur.execute("CREATE SCHEMA IF NOT EXISTS parkinglot;")
cur.execute("USE parkinglot;")
cur.execute("""
    CREATE TABLE IF NOT EXISTS cars (
        car_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        licence_plate VARCHAR(15) NOT NULL,
        time_of_creation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
""")
print("✅  cars table ready")

# ── 4. quick smoke-test insert & read back ------------------------------------
cur.execute("INSERT INTO cars (licence_plate) VALUES ('ABC-125');")
cur.execute("SELECT * FROM cars ORDER BY car_id DESC LIMIT 1;")
print("Last row:", cur.fetchone())

cur.close()
cnx.close()
