-- =========================================
-- LIMPIEZA DE DATOS EN SQL
-- =========================================
-- 
-- PROPÓSITO:
-- Este archivo contiene ejemplos y técnicas esenciales para la limpieza
-- y validación de datos en SQL. Cubre desde el manejo de valores nulos
-- hasta la estandarización de formatos y validaciones de calidad.
--
-- SECCIONES:
--
-- 1. MANEJO DE NULOS
--    Técnicas para detectar, contar y reemplazar valores NULL en datos.
--    Utiliza COALESCE para proporcionar valores por defecto y IS NULL/NOT NULL
--    para filtrar registros con ausencia de datos.
--
-- 2. LIMPIEZA DE TEXTO
--    Funciones para normalizar y transformar datos de texto.
--    Incluye: trimming de espacios, conversión de mayúsculas/minúsculas,
--    reemplazos, concatenación, extracción de subcadenas y validación
--    de patrones con expresiones regulares.
--
-- 3. LIMPIEZA DE FECHAS
--    Métodos para extraer componentes de fechas, calcular diferencias
--    temporales, truncar períodos y realizar conversiones de formato.
--    Essencial para análisis temporal y agrupaciones por períodos.
--
-- 4. DUPLICADOS
--    Identificación de registros duplicados mediante GROUP BY y HAVING,
--    así como obtención de registros únicos con DISTINCT.
--
-- 5. ESTANDARIZACIÓN DE FORMATOS
--    Técnicas de formatos numéricos: redondeo, conversión de tipos de datos
--    (CAST) y formateo de porcentajes para garantizar consistencia.
--
-- 6. LIMPIEZA COMBINADA (INDUSTRIA)
--    Ejemplos prácticos que combinan múltiples técnicas de limpieza
--    en consultas reales de producción.
--
-- 7. VALIDACIONES DE CALIDAD
--    Queries de auditoría para detectar anomalías: valores negativos
--    inesperados, fechas futuras, textos vacíos y longitudes inválidas.
--
-- =========================================}

-- =========================================
-- LIMPIEZA DE DATOS EN SQL
-- =========================================

-- ==============================
-- 1. MANEJO DE NULOS
-- ==============================

SELECT COALESCE(columna, valor) FROM tabla;

SELECT COALESCE(city, 'DESCONOCIDA') FROM customers;

SELECT COALESCE(amount, 0) FROM transactions;

SELECT SUM(COALESCE(amount,0)) FROM transactions;

SELECT COUNT(*) - COUNT(columna) AS nulos FROM tabla;

SELECT * FROM tabla WHERE columna IS NULL;

SELECT * FROM tabla WHERE columna IS NOT NULL;

-- ==============================
-- 2. LIMPIEZA DE TEXTO
-- ==============================

SELECT TRIM(name) FROM customers;

SELECT LTRIM(name) FROM customers;

SELECT RTRIM(name) FROM customers;

SELECT UPPER(name) FROM customers;

SELECT LOWER(name) FROM customers;

SELECT REPLACE(city,'medellin','MEDELLÍN') FROM customers;

SELECT CONCAT(name,' - ',city) FROM customers;

SELECT SUBSTRING(name,1,5) FROM customers;

SELECT LENGTH(name) FROM customers;

SELECT REGEXP_REPLACE(phone,'[^0-9]','') FROM customers;

-- ==============================
-- 3. LIMPIEZA DE FECHAS
-- ==============================

SELECT CURRENT_DATE;

SELECT EXTRACT(YEAR FROM date) FROM transactions;

SELECT EXTRACT(MONTH FROM date) FROM transactions;

SELECT EXTRACT(DAY FROM date) FROM transactions;

SELECT EXTRACT(YEAR FROM date), COUNT(*) 
FROM transactions 
GROUP BY 1;

SELECT DATE_TRUNC('month', date), SUM(amount)
FROM transactions
GROUP BY 1;

SELECT DATEDIFF(day, fecha_inicio, fecha_fin) FROM tabla;

SELECT date + INTERVAL '7 days' FROM tabla;

SELECT CURRENT_DATE - date FROM transactions;

SELECT TO_DATE('2026-03-05','YYYY-MM-DD');

-- ==============================
-- 4. DUPLICADOS
-- ==============================

SELECT columna, COUNT(*) 
FROM tabla 
GROUP BY columna 
HAVING COUNT(*) > 1;

SELECT DISTINCT * FROM tabla;

-- ==============================
-- 5. ESTANDARIZACIÓN DE FORMATOS
-- ==============================

SELECT ROUND(amount,2) FROM transactions;

SELECT CAST(amount AS INTEGER) FROM transactions;

SELECT CAST(customer_id AS VARCHAR) FROM customers;

SELECT ROUND(rate*100,2) || '%' FROM tabla;

-- ==============================
-- 6. LIMPIEZA COMBINADA (INDUSTRIA)
-- ==============================

SELECT UPPER(TRIM(name)) AS name_clean
FROM customers;

SELECT 
    customer_id,
    SUM(COALESCE(amount,0)) AS total
FROM transactions
GROUP BY customer_id;

SELECT 
    UPPER(TRIM(city)) AS city_clean,
    COUNT(*) 
FROM customers
GROUP BY city_clean;

-- ==============================
-- 7. VALIDACIONES DE CALIDAD
-- ==============================

SELECT * FROM transactions WHERE amount < 0;

SELECT * FROM transactions WHERE date > CURRENT_DATE;

SELECT * FROM customers WHERE name = '';

SELECT * FROM customers WHERE LENGTH(phone) < 10;