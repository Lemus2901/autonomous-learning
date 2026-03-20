-- ============================================================
-- BLOQUE 2: LAG / LEAD
-- Dataset: Student Performance
-- ============================================================


-- ============================================================
-- EJERCICIO 9: Variación de puntaje entre examen previo y actual
-- FUNCIÓN: LAG
-- ============================================================

SELECT
    student_id,
    Previous_Scores,
    Exam_Score,
    Exam_Score - LAG(Exam_Score) OVER (
        PARTITION BY School_Type
        ORDER BY Previous_Scores
    ) AS diferencia_con_anterior,
    ROUND(
        (Exam_Score - LAG(Exam_Score) OVER (
            PARTITION BY School_Type ORDER BY Previous_Scores
        ))::NUMERIC / NULLIF(LAG(Exam_Score) OVER (
            PARTITION BY School_Type ORDER BY Previous_Scores
        ), 0) * 100, 2
    ) AS variacion_pct
FROM students
ORDER BY School_Type, Previous_Scores;

-- POR QUÉ (lógica técnica):
-- 1. LAG() accede al valor de la fila anterior dentro de la partición ordenada.
-- 2. NULLIF(..., 0) evita división por cero en el cálculo porcentual.
-- 3. La variación porcentual es más útil que la diferencia absoluta para comparar grupos con escalas distintas.

-- USO EN NEGOCIO:
-- Medir si los estudiantes mejoran o empeoran entre ciclos permite al equipo
-- académico detectar tendencias negativas antes del examen final.


-- ============================================================
-- EJERCICIO 10: Tiempo entre sesiones de tutoría (diferencia acumulada)
-- FUNCIÓN: LAG con valores por defecto
-- ============================================================

SELECT
    student_id,
    Tutoring_Sessions,
    LAG(Tutoring_Sessions, 1, 0) OVER (
        PARTITION BY Family_Income
        ORDER BY student_id
    ) AS tutoring_anterior,
    Tutoring_Sessions - LAG(Tutoring_Sessions, 1, 0) OVER (
        PARTITION BY Family_Income
        ORDER BY student_id
    ) AS cambio_sesiones
FROM students
ORDER BY Family_Income, student_id;

-- POR QUÉ (lógica técnica):
-- 1. LAG(col, 1, 0) tiene un tercer argumento: el valor default cuando no hay fila anterior (evita NULL).
-- 2. PARTITION BY Family_Income compara a cada estudiante con el anterior dentro de su grupo de ingresos.
-- 3. El cambio en sesiones de tutoría puede indicar si estudiantes con más recursos invierten más en apoyo.

-- USO EN NEGOCIO:
-- Analizar si los estudiantes de bajos ingresos incrementan sus sesiones de tutoría
-- y si ese incremento correlaciona con mejora en el puntaje final.


-- ============================================================
-- EJERCICIO 11: Detectar caídas de puntaje mayores al 15%
-- FUNCIÓN: LAG + filtro condicional
-- ============================================================

WITH variaciones AS (
    SELECT
        student_id,
        Motivation_Level,
        Previous_Scores,
        Exam_Score,
        LAG(Exam_Score) OVER (
            PARTITION BY Motivation_Level
            ORDER BY Previous_Scores
        ) AS puntaje_anterior
    FROM students
)
SELECT
    student_id,
    Motivation_Level,
    puntaje_anterior,
    Exam_Score,
    ROUND((Exam_Score - puntaje_anterior) / puntaje_anterior * 100, 1) AS caida_pct
FROM variaciones
WHERE puntaje_anterior IS NOT NULL
  AND (Exam_Score - puntaje_anterior) / puntaje_anterior < -0.15
ORDER BY caida_pct ASC;

-- POR QUÉ (lógica técnica):
-- 1. La CTE aisla el cálculo de LAG para poder filtrarlo limpiamente en la query exterior.
-- 2. WHERE puntaje_anterior IS NOT NULL excluye la primera fila de cada partición (no tiene valor previo).
-- 3. El umbral -0.15 (15%) es un parámetro de negocio ajustable según la política educativa.

-- USO EN NEGOCIO:
-- Identificar estudiantes con motivación alta que aun así cayeron en puntaje
-- es una señal de alerta de problemas externos (salud, familia) que no reportan.


-- ============================================================
-- EJERCICIO 12: Comparar con el próximo estudiante (LEAD)
-- FUNCIÓN: LEAD
-- ============================================================

SELECT
    student_id,
    Gender,
    Hours_Studied,
    Exam_Score,
    LEAD(Exam_Score) OVER (
        PARTITION BY Gender
        ORDER BY Hours_Studied DESC
    ) AS puntaje_siguiente,
    Exam_Score - LEAD(Exam_Score) OVER (
        PARTITION BY Gender
        ORDER BY Hours_Studied DESC
    ) AS ventaja_sobre_siguiente
FROM students
ORDER BY Gender, Hours_Studied DESC;

-- POR QUÉ (lógica técnica):
-- 1. LEAD() es el espejo de LAG(): accede a la fila siguiente en lugar de la anterior.
-- 2. ORDER BY Hours_Studied DESC permite comparar al estudiante que más estudia con el que le sigue.
-- 3. La "ventaja" resultante muestra si estudiar más horas realmente diferencia los puntajes.

-- USO EN NEGOCIO:
-- Validar si la relación horas de estudio → puntaje es escalonada o si hay un
-- plateau donde más horas no generan mejora marginal.


-- ============================================================
-- EJERCICIO 13: Puntaje anterior vs puntaje actual — tabla comparativa
-- FUNCIÓN: LAG para análisis de progreso individual
-- ============================================================

SELECT
    student_id,
    Parental_Education_Level,
    Previous_Scores                                           AS puntaje_previo,
    Exam_Score                                                AS puntaje_actual,
    Exam_Score - Previous_Scores                              AS mejora_absoluta,
    CASE
        WHEN Exam_Score > Previous_Scores THEN 'Mejoró'
        WHEN Exam_Score < Previous_Scores THEN 'Empeoró'
        ELSE 'Sin cambio'
    END                                                       AS tendencia,
    AVG(Exam_Score - Previous_Scores) OVER (
        PARTITION BY Parental_Education_Level
    )                                                         AS mejora_promedio_grupo
FROM students
ORDER BY Parental_Education_Level, mejora_absoluta DESC;

-- POR QUÉ (lógica técnica):
-- 1. La diferencia directa Previous_Scores → Exam_Score actúa como un LAG implícito en datasets transversales.
-- 2. AVG() OVER sin ORDER BY calcula el promedio grupal para cada fila (referencia contextual).
-- 3. CASE WHEN categoriza la tendencia en texto legible para presentaciones no técnicas.

-- USO EN NEGOCIO:
-- Evaluar si el nivel educativo de los padres correlaciona con la mejora promedio
-- del estudiante — métrica clave para políticas de involucramiento familiar.


-- ============================================================
-- EJERCICIO 14: Primer y último puntaje de cada grupo (FIRST_VALUE / LAST_VALUE)
-- FUNCIÓN: FIRST_VALUE, LAST_VALUE
-- ============================================================

SELECT
    student_id,
    Peer_Influence,
    Exam_Score,
    FIRST_VALUE(Exam_Score) OVER (
        PARTITION BY Peer_Influence
        ORDER BY Exam_Score DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS mejor_del_grupo,
    LAST_VALUE(Exam_Score) OVER (
        PARTITION BY Peer_Influence
        ORDER BY Exam_Score DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS peor_del_grupo,
    Exam_Score - LAST_VALUE(Exam_Score) OVER (
        PARTITION BY Peer_Influence
        ORDER BY Exam_Score DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS distancia_al_peor
FROM students
ORDER BY Peer_Influence, Exam_Score DESC;

-- POR QUÉ (lógica técnica):
-- 1. FIRST_VALUE y LAST_VALUE son funciones de ventana que acceden a los extremos del grupo.
-- 2. ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING es obligatorio para LAST_VALUE —
--    sin esto, el frame por defecto solo llega hasta la fila actual y LAST_VALUE = valor actual.
-- 3. La distancia al peor del grupo cuantifica la brecha interna dentro de cada tipo de influencia de pares.

-- USO EN NEGOCIO:
-- Evaluar si los estudiantes con influencia de pares negativa tienen una brecha
-- mayor entre el mejor y el peor — lo que indicaría alta varianza y necesidad de intervención grupal.


-- ============================================================
-- EJERCICIO 15: Detectar inactividad — estudiantes sin tutoría que mejoraron
-- FUNCIÓN: LAG + lógica de negocio
-- ============================================================

WITH comparacion AS (
    SELECT
        student_id,
        Tutoring_Sessions,
        Internet_Access,
        Exam_Score,
        Previous_Scores,
        Exam_Score - Previous_Scores AS mejora,
        LAG(Tutoring_Sessions) OVER (
            PARTITION BY Internet_Access
            ORDER BY student_id
        ) AS tutoring_anterior
    FROM students
)
SELECT
    student_id,
    Internet_Access,
    Tutoring_Sessions,
    mejora,
    CASE WHEN Tutoring_Sessions = 0 AND mejora > 10 THEN 'Mejoró sin tutoría' ELSE 'Normal' END AS hallazgo
FROM comparacion
WHERE Tutoring_Sessions = 0 AND mejora > 10
ORDER BY mejora DESC;

-- POR QUÉ (lógica técnica):
-- 1. Filtrar Tutoring_Sessions = 0 Y mejora > 10 identifica el segmento de "alta autonomía".
-- 2. LAG en la CTE permite tener contexto del estado anterior del grupo para enriquecer el análisis.
-- 3. El CASE WHEN añade una etiqueta cualitativa útil para reportes ejecutivos.

-- USO EN NEGOCIO:
-- Los estudiantes que mejoran sin tutoría son candidatos a programas de liderazgo peer-to-peer;
-- su método de estudio autónomo puede ser documentado y replicado.


-- ============================================================
-- EJERCICIO 16: Tasa de crecimiento porcentual acumulada
-- FUNCIÓN: LAG + cálculo porcentual encadenado
-- ============================================================

WITH base AS (
    SELECT
        student_id,
        School_Type,
        Teacher_Quality,
        Previous_Scores,
        Exam_Score,
        ROUND(
            (Exam_Score::NUMERIC - Previous_Scores) / NULLIF(Previous_Scores, 0) * 100,
        2) AS crecimiento_pct
    FROM students
),
ranking_crecimiento AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY School_Type, Teacher_Quality ORDER BY crecimiento_pct DESC) AS rank_crecimiento
    FROM base
)
SELECT *
FROM ranking_crecimiento
WHERE rank_crecimiento <= 3
ORDER BY School_Type, Teacher_Quality, rank_crecimiento;

-- POR QUÉ (lógica técnica):
-- 1. El crecimiento porcentual normaliza la mejora sin importar el puntaje base del estudiante.
-- 2. La segunda CTE aplica RANK sobre el crecimiento calculado en la primera — encadenamiento limpio.
-- 3. Filtrar top 3 por cruce de School_Type × Teacher_Quality genera una matriz 2×3 de mejores progresores.

-- USO EN NEGOCIO:
-- Identificar en qué combinación de tipo de escuela y calidad docente se produce
-- el mayor crecimiento — insumo directo para decisiones de asignación de docentes.
