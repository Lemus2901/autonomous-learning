-- ============================================================================
-- FILE: day_03_ctes.sql
-- DESCRIPTION: Common Table Expressions (CTEs) - WITH clause examples
-- ============================================================================

-- EXAMPLE 1: Basic CTE - Calculate total spending per customer
-- PURPOSE: Demonstrates simple CTE structure with aggregation
-- OUTPUT: customer_id, total_gasto (total amount spent by customer)

-- EXAMPLE 2: Duplicate of Example 1 (same logic, different formatting)
-- PURPOSE: Shows alternative formatting style for CTE readability

-- EXAMPLE 3: CTE with WHERE clause filter
-- PURPOSE: Demonstrates filtering CTE results using aggregate functions
-- OUTPUT: Customers with more than 5 transactions
-- KEY CONCEPT: Filtering on COUNT aggregate requires WHERE clause

-- EXAMPLE 4: Multiple CTEs (Nested/Chained) with Subquery
-- PURPOSE: Shows how to reference one CTE within another CTE
-- LOGIC FLOW:
--   1. gastos_totales: Calculates total spending per customer
--   2. avg_gastos_totales: Calculates average of all customers' totals
--   3. Final SELECT: Returns customers spending above average
-- OUTPUT: customer_id of high-spending customers

-- EXAMPLE 5: Multiple CTEs with MAX function
-- PURPOSE: Demonstrates finding customers with maximum spending
-- LOGIC FLOW:
--   1. gastos_totales: Calculates total spending per customer
--   2. max_gasto: Finds the maximum spending amount
--   3. Final SELECT: Returns customer(s) matching the maximum value
-- OUTPUT: customer_id, total_gasto for top spender(s)
-- NOTE: File appears incomplete - missing closing parenthesis and semicolon


WITH customer_totals AS ( select customer_id, SUM(amount) AS total_gasto
FROM transactions
GROUP BY customer_id )
            
select customer_id, total_gasto
from customer_totals


with customer_totals as (
            select customer_id, SUM(amount) AS total_gasto
            from transactions
            group by customer_id
            )

select customer_id, total_gasto
from customer_totals

with count_transactions as (
    select customer_id, count(transaction_id) as num_transaction
    from transactions
    group by customer_id
)
select * from count_transactions
where num_transaction > 5;


WITH 
    gastos_totales AS (
        SELECT 
            customer_id, 
            SUM(amount) AS gasto_total
        FROM transactions
        GROUP BY customer_id
    ),
    avg_gastos_totales AS (
        SELECT 
            AVG(gasto_total) AS promedio
        FROM gastos_totales
    )

SELECT customer_id  
FROM gastos_totales
WHERE gasto_total > (
    SELECT promedio 
    FROM avg_gastos_totales
);

WITH 
    gastos_totales AS (
        SELECT 
            customer_id,
            SUM(amount) AS total_gasto
        FROM transactions
        GROUP BY customer_id
    ),
    max_gasto AS (
        SELECT 
            MAX(total_gasto) AS gasto_maximo
        FROM gastos_totales
    )

SELECT customer_id, total_gasto
FROM gastos_totales
WHERE total_gasto = (
    SELECT gasto_maximo 
    FROM max_gasto