-- ==========================================
-- DAY 1 - SQL Practice
-- JOINs and GROUP BY
-- ==========================================

-- ======================
-- 1. CREATE TABLES
-- ======================

CREATE TABLE customers (
    customer_id INTEGER,
    name VARCHAR,
    city VARCHAR
);

CREATE TABLE transactions (
    transaction_id INTEGER,
    customer_id INTEGER,
    amount DECIMAL(10,2),
    date DATE
);

-- ======================
-- 2. INSERT DATA
-- ======================

INSERT INTO customers VALUES
(1, 'Ana', 'Bogotá'),
(2, 'Luis', 'Medellín'),
(3, 'Pedro', 'Cali'),
(4, 'Sofía', 'Barranquilla'),
(6, 'Carlos', 'Bogotá'),
(7, 'Laura', 'Medellín'),
(8, 'María', 'Cali'),
(9, 'Andrés', 'Bogotá');

INSERT INTO transactions VALUES
(101, 2, 150.00, '2024-01-10'),
(102, 3, 200.00, '2024-01-11'),
(103, 5, 300.00, '2024-01-12'),
(104, 2, 80.00, '2024-01-15'),
(105, 2, 120.00, '2024-01-20'),
(106, 3, 50.00, '2024-01-22'),
(107, 1, 300.00, '2024-01-25'),
(108, 1, 100.00, '2024-01-28'),
(109, 4, 75.00, '2024-02-01'),
(110, 6, 500.00, '2024-02-05'),
(111, 6, 150.00, '2024-02-07'),
(112, 7, 250.00, '2024-02-08'),
(113, 8, 300.00, '2024-02-10'),
(114, 9, 50.00, '2024-02-12'),
(115, 9, 70.00, '2024-02-14');

-- ======================
-- 3. JOIN PRACTICE
-- ======================

-- INNER JOIN
SELECT *
FROM customers
INNER JOIN transactions
ON customers.customer_id = transactions.customer_id;

-- LEFT JOIN
SELECT *
FROM customers
LEFT JOIN transactions
ON customers.customer_id = transactions.customer_id;

-- RIGHT JOIN
SELECT *
FROM customers
RIGHT JOIN transactions
ON customers.customer_id = transactions.customer_id;

-- FULL OUTER JOIN
SELECT *
FROM customers
FULL OUTER JOIN transactions
ON customers.customer_id = transactions.customer_id;

-- CROSS JOIN
SELECT *
FROM customers
CROSS JOIN transactions;

-- ======================
-- 4. GROUP BY PRACTICE
-- ======================

-- Total de transacciones y monto por cliente
SELECT 
    customer_id,
    COUNT(*) AS num_transactions,
    SUM(amount) AS total_amount
FROM transactions
GROUP BY customer_id;

-- Total por ciudad (INNER JOIN)
SELECT 
    city,
    COUNT(transaction_id) AS total_transacciones,
    SUM(amount) AS total_gastado
FROM customers
JOIN transactions
ON customers.customer_id = transactions.customer_id
GROUP BY city;

-- Total por ciudad (LEFT JOIN para incluir ciudades sin transacciones)
SELECT 
    city,
    COUNT(transaction_id) AS total_transacciones,
    COALESCE(SUM(amount), 0) AS total_gastado
FROM customers
LEFT JOIN transactions
ON customers.customer_id = transactions.customer_id
GROUP BY city;

-- ======================
-- END DAY 1
-- ======================
