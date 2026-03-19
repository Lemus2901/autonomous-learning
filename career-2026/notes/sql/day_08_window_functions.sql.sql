-- =====================================================
-- ROW_NUMBER() - Asignación de Números de Fila Secuenciales
-- =====================================================
-- Descripción: Asigna un número único y secuencial a cada fila
-- dentro de una ventana (window frame).
-- 
-- Características:
-- - Genera números secuenciales sin gaps (1, 2, 3, 4...)
-- - Si hay empates en los valores ordenados, aún asigna números diferentes
-- - Útil para procesamiento batch, paginación y asignación determinística
--
-- PARTITION BY: (Opcional)
--   Divide los registros en grupos independientes.
--   Resetea la numeración a 1 para cada grupo.
--   Si se omite, todos los registros están en una única ventana.
--
-- ORDER BY: (Requerido)
--   Define el criterio de ordenamiento para asignar números.
--   La dirección (ASC/DESC) afecta qué registros reciben números menores.
--
-- Casos de Uso:
--   1. ID única por posición para envío de reportes por lote
--   2. Extracción del top-1 (estudiante #1) dentro de cada grupo
--   3. Segmentación para campañas personalizadas con garantía de orden


-- =====================================================
-- RANK() - Asignación de Posiciones con Manejo de Empates
-- =====================================================
-- Descripción: Asigna una posición (ranking) a cada fila.
-- Si hay empates en el criterio de ordenamiento, múltiples filas
-- reciben la misma posición, y la siguiente posición salta números.
--
-- Características:
-- - Genera posiciones: 1, 1, 3, 4, 4, 6... (con gaps en empates)
-- - Los empates reciben la misma posición
-- - La siguiente posición refleja el número total de filas vistas
-- - Ideal para rankings justos y competiciones
--
-- PARTITION BY: (Opcional)
--   Divide los registros en grupos independientes.
--   Reinicia el ranking a 1 para cada grupo.
--   Permite comparar rankings dentro de categorías específicas.
--
-- ORDER BY: (Requerido)
--   Define el criterio de ordenamiento para el ranking.
--   Valores iguales reciben el mismo rango.
--
-- Casos de Uso:
--   1. Asignación justa de becas (empates comparten posición)
--   2. Medición de liderazgo dentro de categorías (con PARTITION BY)
--   3. Detección de casos atípicos dentro de grupos específicos

-- ¿Para qué sirve? Crear un ID de posición único para procesar
-- registros uno por uno en un pipeline (ej. envío de reportes por lote)
SELECT
    exam_score,
    ROW_NUMBER() OVER (ORDER BY exam_score DESC) AS rn_global
FROM student_performance
ORDER BY rn_global;



-- ¿Para qué sirve? Extraer el "alumno #1 que más estudia"
-- de cada tipo de institución para comparativas de gestión
SELECT
    school_type,
    hours_studied,
    ROW_NUMBER() OVER (
        PARTITION BY school_type
        ORDER BY hours_studied DESC
    ) AS rn_per_school
FROM student_performance
ORDER BY school_type, rn_per_school;




-- ¿Para qué sirve? Segmentar para campañas de incentivos
-- personalizadas garantizando orden determinístico por grupo
SELECT

    gender,
    attendance,
    ROW_NUMBER() OVER (
        PARTITION BY gender
        ORDER BY attendance DESC
    ) AS rn_per_gender
FROM student_performance
ORDER BY gender, rn_per_gender;




-- ¿Para qué sirve? Asignación de becas justa: si dos alumnos
-- empatan en posición 1, el siguiente recibe la posición 3
SELECT
    exam_score,
    RANK() OVER (ORDER BY exam_score DESC) AS rank_exam
FROM student_performance
ORDER BY rank_exam;




-- ¿Para qué sirve? Medir si el apoyo parental determina
-- quiénes son los líderes de asistencia en cada categoría
SELECT
    parental_involvement,
    attendance,
    RANK() OVER (
        PARTITION BY parental_involvement
        ORDER BY attendance DESC
    ) AS rank_attendance
FROM student_performance
ORDER BY parental_involvement, rank_attendance;




-- ¿Para qué sirve? Detectar casos atípicos de alto rendimiento
-- dentro del grupo de "Baja Motivación" para políticas de retención
SELECT
    motivation_level,
    previous_scores,
    RANK() OVER (
        PARTITION BY motivation_level
        ORDER BY Previous_Scores DESC
    ) AS rank_prev_scores
FROM student_performance
ORDER BY motivation_level, rank_prev_scores;


-- ============================================================================
-- WINDOW FUNCTIONS: ROW_NUMBER, RANK, DENSE_RANK
-- ============================================================================
-- PROPÓSITO GENERAL:
-- Estas funciones de ventana asignan números de posición a filas basándose
-- en un criterio de ordenamiento, permitiendo ranking sin necesidad de
-- GROUP BY. Son esenciales para análisis comparativos y reportería ejecutiva.
--
-- ============================================================================
-- 1. DENSE_RANK() - Ranking sin huecos
-- ============================================================================
-- ¿QUÉ ES?
-- Asigna el mismo número de rango a filas con valores idénticos.
-- A diferencia de RANK(), no deja huecos en la secuencia numérica.
--
-- COMPORTAMIENTO:
--   • Valor 1: score 95
--   • Valor 1: score 95  (empatado, mismo rango)
--   • Valor 2: score 90  (siguiente número sin saltos)
--   • Valor 2: score 90  (empatado)
--   • Valor 3: score 85  (continúa secuencial)
--
-- CASOS DE USO:
--   • Reportes ejecutivos: "hay 15 alumnos en el top 5" es más claro
--   • Políticas de distribución de recursos
--   • Clasificaciones donde los empates no deben crear brechas visuales
--   • Análisis equitativo de niveles reales sin confusión
--
-- ============================================================================
-- 2. COMPARATIVA: ROW_NUMBER vs RANK vs DENSE_RANK
-- ============================================================================
--
-- ROW_NUMBER():
--   • Asigna número único a CADA fila, incluso si los valores son idénticos
--   • Score 95 → ROW 1, Score 95 → ROW 2, Score 90 → ROW 3
--   • Uso: Paginación, seleccionar exactamente N filas
--
-- RANK():
--   • Asigna el mismo rango a valores idénticos
--   • Deja huecos en la secuencia tras empates
--   • Score 95 → RANK 1, Score 95 → RANK 1, Score 90 → RANK 3 (salta a 3)
--   • Uso: Competiciones donde los empates "ocupan posiciones"
--
-- DENSE_RANK():
--   • Asigna el mismo rango a valores idénticos
--   • NO deja huecos en la secuencia
--   • Score 95 → RANK 1, Score 95 → RANK 1, Score 90 → RANK 2 (continúa)
--   • Uso: Reportería ejecutiva, distribución equitativa de recursos
--
-- ============================================================================
-- 3. SINTAXIS CON PARTICIONES
-- ============================================================================
-- DENSE_RANK() OVER (PARTITION BY columna ORDER BY criterio)
--   • PARTITION BY: Reinicia el ranking para cada grupo
--   • ORDER BY: Define el criterio de ordenamiento
--   • Permite múltiples criterios: ORDER BY criterio1 DESC, criterio2 DESC
--
-- ============================================================================
-- ¿Para qué sirve? Reportes ejecutivos donde decir
-- "hay 15 alumnos en el top 5" es más claro que tener huecos
SELECT
    student_id,
    exam_score,
    DENSE_RANK() OVER (ORDER BY exam_score DESC) AS dense_rank_exam
FROM students
ORDER BY dense_rank_exam;

-- ¿Para qué sirve? Entender de un vistazo las diferencias
-- entre las 3 funciones — query imprescindible para tu portafolio
SELECT
    student_id,
    exam_score,
    ROW_NUMBER() OVER (ORDER BY exam_score DESC) AS row_num,
    RANK()       OVER (ORDER BY exam_score DESC) AS rank_val,
    DENSE_RANK() OVER (ORDER BY exam_score DESC) AS dense_rank_val
FROM students
ORDER BY exam_score DESC; 

-- ¿Para qué sirve? Política de distribución de recursos:
-- saber en qué "nivel real" está cada alumno sin huecos confusos
SELECT
    student_id,
    school_type,
    access_to_resources,
    exam_score,
    DENSE_RANK() OVER (
        PARTITION BY school_type
        ORDER BY access_to_resources DESC, exam_score DESC
    ) AS dense_rank_resources
FROM students
ORDER BY school_type, dense_rank_resources;