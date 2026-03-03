-- Día 2: SQL Avanzado con Subqueries
-- Fecha: 2026-03-03

-- 1️⃣ Número de transacciones por cliente
SELECT customer_id, COUNT(*) AS num_transactions
FROM transactions
GROUP BY customer_id;

-- 2️⃣ Promedio de transacciones por cliente
SELECT AVG(num_transactions)
FROM (
    SELECT customer_id, COUNT(*) AS num_transactions
    FROM transactions
    GROUP BY customer_id
) AS t_avg;

-- 3️⃣ Clientes que superan el promedio de transacciones
SELECT customer_id, num_transactions
FROM (
    SELECT customer_id, COUNT(*) AS num_transactions
    FROM transactions
    GROUP BY customer_id
) AS t
WHERE num_transactions > (
    SELECT AVG(num_transactions)
    FROM (
        SELECT customer_id, COUNT(*) AS num_transactions
        FROM transactions
        GROUP BY customer_id
    ) AS t_avg
)
ORDER BY num_transactions DESC;

-- 4️⃣ Clientes con gasto total mayor que el promedio
SELECT customer_id, total_gasto
FROM (
    SELECT customer_id, SUM(amount) AS total_gasto
    FROM transactions
    GROUP BY customer_id
) AS gtc
WHERE total_gasto > (
    SELECT AVG(total_gasto)
    FROM (
        SELECT customer_id, SUM(amount) AS total_gasto
        FROM transactions
        GROUP BY customer_id
    ) AS t_avg
)
ORDER BY total_gasto DESC;
