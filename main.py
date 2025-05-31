"""
Creates DB schema `parkinglot` and table `cars`
  car_id        INT auto-increment PRIMARY KEY
  licence_plate VARCHAR(15)
  parking_lot   INT
  time_of_creation TIMESTAMP (defaults to NOW)
"""
import os
from dotenv import load_dotenv
import mysql.connector
from flask import Flask, request, jsonify, abort


load_dotenv()
host     = os.getenv("DB_HOST")
port     = int(os.getenv("DB_PORT", 3306))
user     = os.getenv("DB_USER")
password = os.getenv("DB_PASS")
if not all([host, port, user, password]):
    raise RuntimeError("Missing DB_* variables; check .env")



# open one global connection
cnx = mysql.connector.connect(
    host=host, port=port, user=user, password=password, autocommit=True
)
cur = cnx.cursor()

cur.execute("CREATE SCHEMA IF NOT EXISTS parkinglot;")
cur.execute("USE parkinglot;")
cur.execute("""
    CREATE TABLE IF NOT EXISTS cars (
        car_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        licence_plate VARCHAR(15) NOT NULL,
        parking_lot INT UNSIGNED NOT NULL,
        time_of_creation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
""")

# API
app = Flask(__name__)

@app.route("/entry", methods=["POST"])
def add_entry():
    plate = request.args.get("plate")
    lot   = request.args.get("parkingLot", type=int)
    if not plate or lot is None:
        abort(400, "plate and parkingLot are required")

    cur.execute(
        "INSERT INTO cars (licence_plate, parking_lot) VALUES (%s, %s)",
        (plate, lot)
    )
    new_id = cur.lastrowid
    return jsonify({"id": new_id}), 201


if __name__ == "__main__":
    app.run(debug=True)
