-- ============================================================
-- DÍA 9 — Entregable: Query Antes vs Después
-- Concepto: Optimización de Running Totals en producción
-- ============================================================


-- ============================================================
-- VERSIÓN "ANTES" — Ineficiente
-- ============================================================
-- Problema: Selecciona todas las columnas con SELECT *,
-- no filtra previamente, y procesa filas innecesarias.
-- En tablas de millones de registros esto consume más memoria
-- y tiempo de procesamiento del motor SQL.
-- ============================================================
SELECT *,
    SUM(tutoring_sessions) OVER (
        PARTITION BY parental_involvement
        ORDER BY student_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS tutoring_acumulado
FROM students;


-- ============================================================
-- VERSIÓN "DESPUÉS" — Optimizada
-- ============================================================
-- Mejoras aplicadas:
-- 1. SELECT específico: solo las columnas necesarias → menos I/O
-- 2. WHERE temprano: reduce el conjunto de filas antes de la
--    ventana, aliviando la carga del OVER()
-- 3. Resultado: menor uso de memoria y más rápido en producción
-- ============================================================
SELECT
    student_id,
    parental_involvement,
    tutoring_sessions,
    SUM(tutoring_sessions) OVER (
        PARTITION BY parental_involvement
        ORDER BY student_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS tutoring_acumulado
FROM students
WHERE parental_involvement IN ('Low', 'Medium', 'High')  -- filtra explícitamente
ORDER BY parental_involvement, student_id;


-- ============================================================
-- NOTA TÉCNICA — ¿Por qué importa en producción?
-- ============================================================
-- Las funciones de ventana (OVER) se ejecutan DESPUÉS del WHERE.
-- Esto significa que si filtras antes, el motor trabaja sobre
-- un subconjunto más pequeño al calcular el acumulado.
-- En entornos cloud (BigQuery, Redshift, Snowflake) esto impacta
-- directamente en el costo de la consulta (bytes procesados).
-- Regla: filtra temprano, selecciona solo lo que necesitas.
-- ============================================================



