-- ============================================================
-- BLOQUE 3: SUM / AVG / COUNT OVER (Running Totals, Promedios Móviles)
-- Dataset: Student Performance
-- ============================================================


-- ============================================================
-- EJERCICIO 17: Running total de horas de estudio por tipo de escuela
-- FUNCIÓN: SUM() OVER con ORDER BY
-- ============================================================

SELECT
    student_id,
    School_Type,
    Hours_Studied,
    SUM(Hours_Studied) OVER (
        PARTITION BY School_Type
        ORDER BY student_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS horas_acumuladas,
    SUM(Hours_Studied) OVER (PARTITION BY School_Type) AS total_escuela,
    ROUND(
        SUM(Hours_Studied) OVER (
            PARTITION BY School_Type
            ORDER BY student_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) * 100.0 / SUM(Hours_Studied) OVER (PARTITION BY School_Type),
    1) AS pct_acumulado
FROM students
ORDER BY School_Type, student_id;

-- POR QUÉ (lógica técnica):
-- 1. ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW define el frame acumulativo (desde el inicio hasta la fila actual).
-- 2. SUM sin ORDER BY (segunda instancia) calcula el total del grupo completo — sirve de denominador.
-- 3. Dividir el acumulado entre el total da el porcentaje progresivo de contribución.

-- USO EN NEGOCIO:
-- Monitorear cómo se distribuye el esfuerzo de estudio acumulado a lo largo del año escolar
-- permite planificar cuándo concentrar los recursos de apoyo.


-- ============================================================
-- EJERCICIO 18: Promedio móvil de 3 estudiantes en puntaje de examen
-- FUNCIÓN: AVG() OVER con ROWS BETWEEN
-- ============================================================

SELECT
    student_id,
    Motivation_Level,
    Exam_Score,
    ROUND(AVG(Exam_Score) OVER (
        PARTITION BY Motivation_Level
        ORDER BY student_id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS promedio_movil_3,
    ROUND(AVG(Exam_Score) OVER (
        PARTITION BY Motivation_Level
        ORDER BY student_id
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2) AS promedio_movil_5
FROM students
ORDER BY Motivation_Level, student_id;

-- POR QUÉ (lógica técnica):
-- 1. ROWS BETWEEN 2 PRECEDING AND CURRENT ROW incluye la fila actual + las 2 anteriores = ventana de 3.
-- 2. Comparar promedio de 3 vs 5 muestra cómo distintos tamaños de ventana suavizan la señal.
-- 3. PARTITION BY Motivation_Level evita que el promedio "cruce" entre grupos distintos.

-- USO EN NEGOCIO:
-- El promedio móvil de puntajes es análogo a la media móvil en series de tiempo financieras:
-- suaviza la variabilidad individual y revela tendencias grupales más confiables.


-- ============================================================
-- EJERCICIO 19: Porcentaje del total por nivel de acceso a recursos
-- FUNCIÓN: SUM OVER — contribución relativa
-- ============================================================

SELECT
    student_id,
    Access_to_Resources,
    Exam_Score,
    SUM(Exam_Score) OVER (PARTITION BY Access_to_Resources) AS total_grupo,
    SUM(Exam_Score) OVER ()                                  AS total_global,
    ROUND(Exam_Score * 100.0 / SUM(Exam_Score) OVER (PARTITION BY Access_to_Resources), 2) AS pct_dentro_grupo,
    ROUND(Exam_Score * 100.0 / SUM(Exam_Score) OVER (), 2)   AS pct_del_total
FROM students
ORDER BY Access_to_Resources, Exam_Score DESC;

-- POR QUÉ (lógica técnica):
-- 1. SUM OVER () sin PARTITION ni ORDER BY calcula el gran total de toda la tabla en cada fila.
-- 2. Tener ambos porcentajes (dentro del grupo y del total) permite análisis de composición multinivel.
-- 3. Esta estructura es la base de los reportes de contribución que se ven en dashboards ejecutivos.

-- USO EN NEGOCIO:
-- Determinar si los estudiantes con acceso alto a recursos contribuyen desproporcionadamente
-- al puntaje total — evidencia para justificar inversión en equipamiento para grupos rezagados.


-- ============================================================
-- EJERCICIO 20: Acumulado de tutorías por nivel de ingresos familiares
-- FUNCIÓN: SUM OVER con ORDER BY
-- ============================================================

SELECT
    student_id,
    Family_Income,
    Tutoring_Sessions,
    SUM(Tutoring_Sessions) OVER (
        PARTITION BY Family_Income
        ORDER BY student_id
    ) AS tutoring_acumulado,
    COUNT(*) OVER (
        PARTITION BY Family_Income
        ORDER BY student_id
    ) AS estudiantes_contados,
    ROUND(
        SUM(Tutoring_Sessions) OVER (PARTITION BY Family_Income ORDER BY student_id)::NUMERIC
        / COUNT(*) OVER (PARTITION BY Family_Income ORDER BY student_id),
    2) AS promedio_acumulado_tutoring
FROM students
ORDER BY Family_Income, student_id;

-- POR QUÉ (lógica técnica):
-- 1. Dividir SUM acumulado entre COUNT acumulado genera un promedio progresivo (equivalente a AVG OVER).
-- 2. Ver cómo evoluciona el promedio acumulado revela si los estudiantes que se agregan en el tiempo tienen más o menos tutorías.
-- 3. Separar por Family_Income permite comparar el ritmo de adopción de tutorías entre niveles socioeconómicos.

-- USO EN NEGOCIO:
-- Justificar ante un comité si el acceso a tutorías es equitativo entre niveles de ingresos,
-- y si las diferencias impactan estadísticamente el puntaje final.


-- ============================================================
-- EJERCICIO 21: Desviación del puntaje individual vs. promedio del grupo
-- FUNCIÓN: AVG OVER — comparación con benchmark
-- ============================================================

SELECT
    student_id,
    Teacher_Quality,
    Exam_Score,
    ROUND(AVG(Exam_Score) OVER (PARTITION BY Teacher_Quality), 2) AS promedio_grupo,
    Exam_Score - ROUND(AVG(Exam_Score) OVER (PARTITION BY Teacher_Quality), 2) AS desviacion,
    CASE
        WHEN Exam_Score > AVG(Exam_Score) OVER (PARTITION BY Teacher_Quality) + 10 THEN 'Muy sobre promedio'
        WHEN Exam_Score > AVG(Exam_Score) OVER (PARTITION BY Teacher_Quality)      THEN 'Sobre promedio'
        WHEN Exam_Score < AVG(Exam_Score) OVER (PARTITION BY Teacher_Quality) - 10 THEN 'Muy bajo promedio'
        ELSE 'Bajo promedio'
    END AS categoria
FROM students
ORDER BY Teacher_Quality, desviacion DESC;

-- POR QUÉ (lógica técnica):
-- 1. AVG OVER sin ORDER BY calcula el promedio estático del grupo — no acumulativo.
-- 2. La resta (Exam_Score - promedio_grupo) genera una "desviación de benchmark" estilo KPI de negocio.
-- 3. El CASE WHEN categoriza la desviación en bandas interpretables por audiencias no técnicas.

-- USO EN NEGOCIO:
-- Detectar si la calidad del docente crea grupos más o menos homogéneos (alta vs baja desviación interna)
-- informa decisiones sobre capacitación docente y asignación de grupos.


-- ============================================================
-- EJERCICIO 22: Running count de estudiantes por nivel de involucramiento parental
-- FUNCIÓN: COUNT() OVER
-- ============================================================

SELECT
    student_id,
    Parental_Involvement,
    Exam_Score,
    COUNT(*) OVER (
        PARTITION BY Parental_Involvement
        ORDER BY Exam_Score DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS posicion_en_grupo,
    COUNT(*) OVER (PARTITION BY Parental_Involvement) AS total_en_grupo
FROM students
ORDER BY Parental_Involvement, Exam_Score DESC;

-- POR QUÉ (lógica técnica):
-- 1. COUNT con frame acumulativo genera la posición ordinal del estudiante dentro del grupo.
-- 2. Dividir posicion_en_grupo / total_en_grupo da el percentil manual sin usar PERCENT_RANK.
-- 3. Esta técnica es útil cuando se necesita el conteo acumulado como número, no como porcentaje.

-- USO EN NEGOCIO:
-- Saber cuántos estudiantes hay por encima de cada alumno en su grupo de involucramiento
-- parental permite construir "posiciones relativas" para comunicar avance a los padres.


-- ============================================================
-- EJERCICIO 23: MAX acumulado de puntaje por tipo de escuela
-- FUNCIÓN: MAX() OVER
-- ============================================================

SELECT
    student_id,
    School_Type,
    Exam_Score,
    MAX(Exam_Score) OVER (
        PARTITION BY School_Type
        ORDER BY student_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS maximo_historico,
    CASE
        WHEN Exam_Score = MAX(Exam_Score) OVER (
            PARTITION BY School_Type
            ORDER BY student_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) THEN '🏆 Nuevo máximo'
        ELSE ''
    END AS es_record
FROM students
ORDER BY School_Type, student_id;

-- POR QUÉ (lógica técnica):
-- 1. MAX() OVER con frame acumulativo mantiene el "high watermark" — el máximo visto hasta esa fila.
-- 2. Comparar Exam_Score con el máximo acumulado detecta cada vez que se bate un récord.
-- 3. Este patrón es idéntico al que se usa para detectar all-time highs en series financieras.

-- USO EN NEGOCIO:
-- Visualizar cuándo se registró el mejor puntaje histórico en cada tipo de escuela
-- permite correlacionar con eventos educativos (cambio de docente, nueva metodología).


-- ============================================================
-- EJERCICIO 24: SUM OVER con PARTITION y ORDER combinados
-- FUNCIÓN: SUM OVER con frame RANGE
-- ============================================================

SELECT
    student_id,
    Distance_from_Home,
    Hours_Studied,
    Exam_Score,
    SUM(Exam_Score) OVER (
        PARTITION BY Distance_from_Home
        ORDER BY Hours_Studied
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS acumulado_por_horas
FROM students
ORDER BY Distance_from_Home, Hours_Studied;

-- POR QUÉ (lógica técnica):
-- 1. RANGE (en lugar de ROWS) agrupa filas con el mismo valor de ORDER BY en el mismo frame.
-- 2. Si dos estudiantes tienen las mismas Hours_Studied, ambos quedan incluidos en el mismo acumulado.
-- 3. Esto produce totales acumulados "por nivel" en lugar de "por posición de fila".

-- USO EN NEGOCIO:
-- Entender si los estudiantes que viven lejos de casa estudian más horas y si ese esfuerzo
-- adicional se refleja en puntajes acumulados mayores — análisis de retorno al esfuerzo.


-- ============================================================
-- EJERCICIO 25: Contribución porcentual de cada género al puntaje total
-- FUNCIÓN: SUM OVER para análisis de composición
-- ============================================================

WITH resumen AS (
    SELECT
        Gender,
        COUNT(*)                  AS total_estudiantes,
        ROUND(AVG(Exam_Score), 2) AS puntaje_promedio,
        SUM(Exam_Score)           AS puntaje_total_genero
    FROM students
    GROUP BY Gender
),
totales AS (
    SELECT
        *,
        SUM(puntaje_total_genero) OVER () AS gran_total,
        SUM(total_estudiantes) OVER ()    AS total_estudiantes_global
    FROM resumen
)
SELECT
    Gender,
    total_estudiantes,
    puntaje_promedio,
    puntaje_total_genero,
    ROUND(puntaje_total_genero * 100.0 / gran_total, 1) AS pct_del_total,
    ROUND(total_estudiantes * 100.0 / total_estudiantes_global, 1) AS pct_de_poblacion
FROM totales
ORDER BY puntaje_total_genero DESC;

-- POR QUÉ (lógica técnica):
-- 1. La primera CTE agrega los datos — pasar de nivel de fila a nivel de grupo.
-- 2. SUM OVER () en la segunda CTE añade el gran total como columna sin subquery correlacionada.
-- 3. Comparar pct_del_total vs pct_de_poblacion detecta si un género está sobrerrepresentado en puntaje.

-- USO EN NEGOCIO:
-- Verificar equidad de género en rendimiento académico — si un género tiene 50% de la población
-- pero 60% del puntaje total, hay una brecha de desempeño que merece investigación.
