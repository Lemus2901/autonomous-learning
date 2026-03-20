-- ============================================================
-- BLOQUE 1: ROW_NUMBER / RANK / DENSE_RANK
-- Dataset: Student Performance (student_id + 20 variables)
-- ============================================================

-- Nota: Se asume la tabla se llama `students`
-- Para practicar en PostgreSQL puedes crear la tabla así:
-- CREATE TABLE students (student_id SERIAL, Hours_Studied NUMERIC, Attendance NUMERIC,
--   Parental_Involvement TEXT, Access_to_Resources TEXT, Extracurricular_Activities TEXT,
--   Sleep_Hours NUMERIC, Previous_Scores NUMERIC, Motivation_Level TEXT, Internet_Access TEXT,
--   Tutoring_Sessions INT, Family_Income TEXT, Teacher_Quality TEXT, School_Type TEXT,
--   Peer_Influence TEXT, Physical_Activity NUMERIC, Learning_Disabilities TEXT,
--   Parental_Education_Level TEXT, Distance_from_Home TEXT, Gender TEXT, Exam_Score NUMERIC);


-- ============================================================
-- EJERCICIO 1: Top 3 estudiantes por puntaje en cada tipo de escuela
-- FUNCIÓN: ROW_NUMBER
-- ============================================================

WITH ranked AS (
    SELECT
        student_id,
        School_Type,
        Exam_Score,
        ROW_NUMBER() OVER (
            PARTITION BY School_Type
            ORDER BY Exam_Score DESC
        ) AS ranking_en_escuela
    FROM students
)
SELECT *
FROM ranked
WHERE ranking_en_escuela <= 3;

-- POR QUÉ (lógica técnica):
-- 1. PARTITION BY School_Type reinicia el contador para cada tipo de escuela (Public/Private).
-- 2. ORDER BY Exam_Score DESC garantiza que rank=1 es el mejor puntaje dentro del grupo.
-- 3. ROW_NUMBER() asigna números únicos sin empates, incluso si dos estudiantes tienen el mismo puntaje.

-- USO EN NEGOCIO:
-- Un director escolar puede identificar los alumnos estrella por tipo de institución
-- para nombrarlos embajadores del programa o asignarles becas diferenciadas.


-- ============================================================
-- EJERCICIO 2: RANK vs DENSE_RANK — diferencia explícita
-- FUNCIÓN: RANK, DENSE_RANK
-- ============================================================

SELECT
    student_id,
    Exam_Score,
    RANK()       OVER (ORDER BY Exam_Score DESC) AS rank_con_saltos,
    DENSE_RANK() OVER (ORDER BY Exam_Score DESC) AS rank_sin_saltos
FROM students
ORDER BY Exam_Score DESC
LIMIT 20;

-- POR QUÉ (lógica técnica):
-- 1. RANK() salta números cuando hay empates (ej: 1, 2, 2, 4) — puede dejar huecos.
-- 2. DENSE_RANK() nunca salta (ej: 1, 2, 2, 3) — útil cuando los rangos deben ser contiguos.
-- 3. Ambas comparten la misma cláusula OVER, lo que permite compararlas en la misma query.

-- USO EN NEGOCIO:
-- En sistemas de becas donde el número de ganadores es fijo (ej: "los 10 primeros"),
-- RANK puede excluir a estudiantes empatados; DENSE_RANK garantiza equidad.


-- ============================================================
-- EJERCICIO 3: Primer examen de cada estudiante (simulado con fecha)
-- FUNCIÓN: ROW_NUMBER — filtrar primera fila del grupo
-- ============================================================

-- Caso: En una tabla con múltiples registros por student_id (historial de exámenes),
-- extraer solo el registro más antiguo / de menor puntaje anterior.

WITH primer_registro AS (
    SELECT
        student_id,
        Previous_Scores,
        Exam_Score,
        ROW_NUMBER() OVER (
            PARTITION BY student_id
            ORDER BY Previous_Scores ASC  -- el examen previo más bajo = el más antiguo
        ) AS rn
    FROM students
)
SELECT student_id, Previous_Scores, Exam_Score
FROM primer_registro
WHERE rn = 1;

-- POR QUÉ (lógica técnica):
-- 1. PARTITION BY student_id asegura que el ranking se reinicia por alumno.
-- 2. Filtrar WHERE rn = 1 es el patrón estándar para "dame solo la primera fila del grupo".
-- 3. Este patrón es preferible a MAX/MIN con GROUP BY cuando necesitas otras columnas del mismo registro.

-- USO EN NEGOCIO:
-- Identificar el "estado de entrada" de cada estudiante al programa para medir
-- cuánto progresó entre el primer y el último examen.


-- ============================================================
-- EJERCICIO 4: Eliminar duplicados con ROW_NUMBER
-- FUNCIÓN: ROW_NUMBER — deduplicación
-- ============================================================

WITH dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY student_id
            ORDER BY Exam_Score DESC  -- quedarse con el mejor registro
        ) AS rn
    FROM students
)
SELECT * EXCLUDE (rn)  -- en PostgreSQL: SELECT student_id, Exam_Score, ... FROM dedup
FROM dedup
WHERE rn = 1;

-- POR QUÉ (lógica técnica):
-- 1. PARTITION BY student_id agrupa todos los registros del mismo alumno.
-- 2. ORDER BY Exam_Score DESC hace que el mejor puntaje quede en rn=1.
-- 3. WHERE rn = 1 actúa como filtro de deduplicación sin borrar datos de la tabla original.

-- USO EN NEGOCIO:
-- En datasets con registros duplicados por errores de carga, este patrón limpia
-- los datos sin necesidad de DELETE, preservando la trazabilidad.


-- ============================================================
-- EJERCICIO 5: Top estudiante por nivel de motivación y género
-- FUNCIÓN: ROW_NUMBER con PARTITION múltiple
-- ============================================================

WITH ranked AS (
    SELECT
        student_id,
        Gender,
        Motivation_Level,
        Exam_Score,
        ROW_NUMBER() OVER (
            PARTITION BY Gender, Motivation_Level
            ORDER BY Exam_Score DESC
        ) AS ranking
    FROM students
)
SELECT *
FROM ranked
WHERE ranking = 1
ORDER BY Gender, Motivation_Level;

-- POR QUÉ (lógica técnica):
-- 1. PARTITION BY con dos columnas crea subgrupos cruzados (ej: Female-High, Female-Low, Male-High...).
-- 2. Esto genera hasta 6 combinaciones posibles (2 géneros × 3 niveles de motivación).
-- 3. El resultado tiene exactamente un ganador por cada combinación existente.

-- USO EN NEGOCIO:
-- Diseñar programas de mentoría diferenciados: el mejor estudiante motivado de cada
-- segmento puede actuar como mentor par para sus compañeros similares.


-- ============================================================
-- EJERCICIO 6: Ranking percentil de puntajes
-- FUNCIÓN: NTILE, PERCENT_RANK
-- ============================================================

SELECT
    student_id,
    Exam_Score,
    NTILE(4) OVER (ORDER BY Exam_Score)               AS cuartil,
    ROUND(PERCENT_RANK() OVER (ORDER BY Exam_Score)::NUMERIC * 100, 1) AS percentil
FROM students
ORDER BY Exam_Score DESC;

-- POR QUÉ (lógica técnica):
-- 1. NTILE(4) divide a todos los estudiantes en 4 grupos iguales (Q1=peor, Q4=mejor).
-- 2. PERCENT_RANK() calcula qué porcentaje de estudiantes está por debajo de cada puntaje.
-- 3. Ambas funciones no necesitan PARTITION BY cuando se aplican a toda la tabla.

-- USO EN NEGOCIO:
-- Clasificar a los estudiantes en cuartiles permite focalizar recursos:
-- Q1 necesita intervención urgente, Q4 puede aspirar a programas avanzados.


-- ============================================================
-- EJERCICIO 7: Top N con filtro en CTE — mejores por acceso a recursos
-- FUNCIÓN: ROW_NUMBER + CTE
-- ============================================================

WITH top_por_recursos AS (
    SELECT
        student_id,
        Access_to_Resources,
        Exam_Score,
        Tutoring_Sessions,
        ROW_NUMBER() OVER (
            PARTITION BY Access_to_Resources
            ORDER BY Exam_Score DESC
        ) AS ranking
    FROM students
),
top5 AS (
    SELECT * FROM top_por_recursos WHERE ranking <= 5
)
SELECT
    Access_to_Resources,
    student_id,
    Exam_Score,
    Tutoring_Sessions,
    ranking
FROM top5
ORDER BY Access_to_Resources, ranking;

-- POR QUÉ (lógica técnica):
-- 1. La primera CTE calcula el ranking dentro de cada nivel de acceso a recursos.
-- 2. La segunda CTE filtra solo los top 5, separando la lógica de ranking del filtro.
-- 3. La query final puede agregar columnas adicionales sin repetir la lógica de ranking.

-- USO EN NEGOCIO:
-- Analizar si los estudiantes con bajo acceso a recursos pero alto puntaje
-- son candidatos prioritarios para becas de equipamiento tecnológico.


-- ============================================================
-- EJERCICIO 8: Ranking inverso — identificar estudiantes en riesgo
-- FUNCIÓN: ROW_NUMBER orden ascendente
-- ============================================================

WITH en_riesgo AS (
    SELECT
        student_id,
        School_Type,
        Family_Income,
        Exam_Score,
        Attendance,
        ROW_NUMBER() OVER (
            PARTITION BY School_Type
            ORDER BY Exam_Score ASC  -- ASC = los peores primero
        ) AS ranking_riesgo
    FROM students
    WHERE Attendance < 75  -- filtro adicional: también faltan mucho
)
SELECT *
FROM en_riesgo
WHERE ranking_riesgo <= 5
ORDER BY School_Type, ranking_riesgo;

-- POR QUÉ (lógica técnica):
-- 1. ORDER BY ASC invierte el ranking: rn=1 es el peor puntaje del grupo.
-- 2. El filtro WHERE Attendance < 75 en la CTE externa reduce el universo a estudiantes con doble riesgo.
-- 3. Combinar ranking + filtro previo crea segmentos de intervención más precisos.

-- USO EN NEGOCIO:
-- Los 5 estudiantes con peor puntaje Y baja asistencia en cada tipo de escuela
-- son el grupo de intervención prioritaria para el equipo de orientación.
