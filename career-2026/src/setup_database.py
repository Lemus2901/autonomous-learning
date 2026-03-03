import duckdb
import os

db_path = "data/analytics.db"

# Crear carpeta data si no existe
os.makedirs("data", exist_ok=True)

# Si la base ya existe, no la borra (más profesional)
con = duckdb.connect(db_path)

# Crear tablas solo si no existen
con.execute("""
CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER,
    name VARCHAR,
    city VARCHAR
);
""")

con.execute("""
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INTEGER,
    customer_id INTEGER,
    amount DOUBLE,
    date DATE
);
""")

# Insertar datos solo si la tabla está vacía
count = con.execute("SELECT COUNT(*) FROM customers").fetchone()[0]

if count == 0:
    con.execute("""
    INSERT INTO customers VALUES
    (1, 'Ana', 'Bogotá'),
    (2, 'Luis', 'Medellín'),
    (3, 'Pedro', 'Cali'),
    (4, 'Sofía', 'Barranquilla'),
    (5, 'Carlos', 'Bogotá'),
    (6, 'Laura', 'Medellín'),
    (7, 'María', 'Cali'),
    (8, 'Andrés', 'Bogotá');
    """)

    con.execute("""
    INSERT INTO transactions VALUES
    (101, 1, 300.00, '2024-01-25'),
    (102, 1, 100.00, '2024-01-28'),
    (103, 2, 150.00, '2024-01-10'),
    (104, 2, 80.00, '2024-01-15'),
    (105, 3, 200.00, '2024-01-11'),
    (106, 3, 50.00, '2024-01-22'),
    (107, 4, 75.00, '2024-02-01'),
    (108, 5, 500.00, '2024-02-05'),
    (109, 6, 250.00, '2024-02-08'),
    (110, 7, 300.00, '2024-02-10'),
    (111, 8, 50.00, '2024-02-12');
    """)

con.close()

print("Base lista en data/analytics.db")
