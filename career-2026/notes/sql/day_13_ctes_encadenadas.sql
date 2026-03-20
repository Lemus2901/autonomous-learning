-- ============================================================
-- BLOQUE 4: CTEs (Common Table Expressions)
-- Dataset: Student Performance
-- ============================================================


-- ============================================================
-- EJERCICIO 26: CTE simple — limpiar y renombrar columnas para análisis
-- FUNCIÓN: CTE básica de legibilidad
-- ============================================================

WITH datos_limpios AS (
    SELECT
        student_id                  AS id,
        Hours_Studied               AS horas_estudio,
        Exam_Score                  AS puntaje,
        Attendance                  AS asistencia_pct,
        School_Type                 AS tipo_escuela,
        Motivation_Level            AS motivacion
    FROM students
    WHERE Exam_Score IS NOT NULL
      AND Hours_Studied > 0
)
SELECT
    id,
    horas_estudio,
    puntaje,
    asistencia_pct,
    tipo_escuela,
    motivacion
FROM datos_limpios
ORDER BY puntaje DESC
LIMIT 20;

-- POR QUÉ (lógica técnica):
-- 1. La CTE actúa como una "vista temporal" que limpia y renombra columnas una sola vez.
-- 2. El filtro WHERE en la CTE elimina datos problemáticos antes de que lleguen a la query final.
-- 3. Los alias en español mejoran la legibilidad para stakeholders no técnicos que lean el código.

-- USO EN NEGOCIO:
-- En entornos de análisis compartido, nombrar las columnas en el idioma del negocio
-- facilita la revisión del código por parte de analistas y líderes de área.


-- ============================================================
-- EJERCICIO 27: CTE encadenada — estudiantes → métricas → clasificación
-- FUNCIÓN: CTEs múltiples en cadena
-- ============================================================

WITH base AS (
    SELECT
        student_id,
        Exam_Score,
        Hours_Studied,
        Tutoring_Sessions,
        Attendance
    FROM students
),
metricas AS (
    SELECT
        student_id,
        Exam_Score,
        Hours_Studied + Tutoring_Sessions * 2 AS esfuerzo_total,  -- ponderación simple
        Attendance,
        AVG(Exam_Score) OVER () AS promedio_global
    FROM base
),
clasificacion AS (
    SELECT
        *,
        CASE
            WHEN Exam_Score >= promedio_global + 10 AND esfuerzo_total >= 20 THEN 'Alto rendimiento'
            WHEN Exam_Score >= promedio_global                                THEN 'Rendimiento normal'
            ELSE                                                                   'Necesita apoyo'
        END AS segmento
    FROM metricas
)
SELECT segmento, COUNT(*) AS cantidad, ROUND(AVG(Exam_Score), 2) AS puntaje_promedio
FROM clasificacion
GROUP BY segmento
ORDER BY puntaje_promedio DESC;

-- POR QUÉ (lógica técnica):
-- 1. Cada CTE hace UNA cosa: base limpia, metricas calcula, clasificacion segmenta.
-- 2. La cadena hace el código legible de arriba a abajo — como un pipeline de transformación.
-- 3. La query final es una simple agregación sobre datos ya preparados.

-- USO EN NEGOCIO:
-- Segmentar a los estudiantes en grupos de intervención permite priorizar recursos:
-- los de "Necesita apoyo" reciben tutoría, los de "Alto rendimiento" reciben retos adicionales.


-- ============================================================
-- EJERCICIO 28: CTE recursiva — jerarquía simple (simulada)
-- FUNCIÓN: CTE recursiva
-- ============================================================

-- Simulamos una jerarquía: tutor → estudiante (usando student_id y un tutor_id ficticio)
-- Para ejecutar esto necesitas: ALTER TABLE students ADD COLUMN tutor_id INT;
-- UPDATE students SET tutor_id = student_id - 1 WHERE student_id > 1;

WITH RECURSIVE jerarquia AS (
    -- Caso base: tutores raíz (sin tutor superior)
    SELECT
        student_id,
        student_id AS tutor_id,
        Exam_Score,
        1 AS nivel,
        student_id::TEXT AS ruta
    FROM students
    WHERE student_id <= 5  -- simulamos 5 tutores raíz

    UNION ALL

    -- Caso recursivo: estudiantes asignados a tutores
    SELECT
        s.student_id,
        j.student_id AS tutor_id,
        s.Exam_Score,
        j.nivel + 1,
        j.ruta || ' → ' || s.student_id::TEXT
    FROM students s
    INNER JOIN jerarquia j ON s.student_id = j.student_id + 5  -- asignación simulada
    WHERE j.nivel < 3  -- máximo 3 niveles de profundidad
)
SELECT * FROM jerarquia ORDER BY ruta;

-- POR QUÉ (lógica técnica):
-- 1. Una CTE recursiva tiene dos partes: el caso base (sin recursión) y el caso recursivo unido con UNION ALL.
-- 2. La columna nivel evita ciclos infinitos junto con la cláusula WHERE nivel < N.
-- 3. La columna ruta construye el camino completo desde la raíz — útil para debug y visualización.

-- USO EN NEGOCIO:
-- Las jerarquías aparecen en org charts, sistemas de mentoría, categorías de productos y BOM (bill of materials).
-- Saber escribir CTEs recursivas te hace capaz de resolver el 90% de estos casos.


-- ============================================================
-- EJERCICIO 29: Reemplazar subquery anidada con CTE legible
-- FUNCIÓN: CTE como sustituto de subqueries
-- ============================================================

-- VERSIÓN CON SUBQUERY (ilegible):
-- SELECT student_id, Exam_Score
-- FROM students
-- WHERE Exam_Score > (SELECT AVG(Exam_Score) FROM students WHERE School_Type = 'Public')
-- AND School_Type = 'Public';

-- VERSIÓN CON CTE (legible y mantenible):
WITH promedio_publicas AS (
    SELECT AVG(Exam_Score) AS avg_score
    FROM students
    WHERE School_Type = 'Public'
),
estudiantes_sobre_promedio AS (
    SELECT
        s.student_id,
        s.Exam_Score,
        s.School_Type,
        s.Gender,
        p.avg_score AS benchmark
    FROM students s
    CROSS JOIN promedio_publicas p
    WHERE s.Exam_Score > p.avg_score
      AND s.School_Type = 'Public'
)
SELECT * FROM estudiantes_sobre_promedio ORDER BY Exam_Score DESC;

-- POR QUÉ (lógica técnica):
-- 1. CROSS JOIN con una CTE de una sola fila es el reemplazo limpio de una subquery escalar.
-- 2. El valor de benchmark queda como columna visible — útil para debugging y reportes.
-- 3. La CTE puede reutilizarse en múltiples partes de la query sin recalcular.

-- USO EN NEGOCIO:
-- Los análisis "por encima del promedio" son una de las consultas más frecuentes en operaciones.
-- Tener este patrón dominado permite responder esas preguntas en segundos, no minutos.


-- ============================================================
-- EJERCICIO 30: CTE + Window Function — combo real de portafolio
-- FUNCIÓN: CTE + ROW_NUMBER + LAG
-- ============================================================

WITH datos AS (
    SELECT
        student_id,
        Parental_Involvement,
        Exam_Score,
        Previous_Scores,
        Exam_Score - Previous_Scores AS mejora
    FROM students
),
con_ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY Parental_Involvement ORDER BY mejora DESC) AS rank_mejora,
        LAG(mejora) OVER (PARTITION BY Parental_Involvement ORDER BY student_id)   AS mejora_anterior,
        AVG(mejora) OVER (PARTITION BY Parental_Involvement)                       AS mejora_promedio_grupo
    FROM datos
)
SELECT
    student_id,
    Parental_Involvement,
    Exam_Score,
    mejora,
    rank_mejora,
    mejora_anterior,
    ROUND(mejora_promedio_grupo, 2) AS benchmark_grupo,
    mejora - mejora_promedio_grupo  AS sobre_benchmark
FROM con_ranking
WHERE rank_mejora <= 5
ORDER BY Parental_Involvement, rank_mejora;

-- POR QUÉ (lógica técnica):
-- 1. La CTE base prepara el cálculo de mejora — separar la aritmética simple de las funciones de ventana.
-- 2. La segunda CTE aplica tres window functions distintas en un solo paso — eficiente y legible.
-- 3. La query final filtra y presenta — cada capa tiene responsabilidad única (Single Responsibility).

-- USO EN NEGOCIO:
-- Los top 5 estudiantes con mayor mejora por nivel de involucramiento parental
-- son los casos de éxito que el equipo comunicacional puede usar en reportes a familias y directivos.


-- ============================================================
-- EJERCICIO 31: Análisis de cohorte básico con CTEs
-- FUNCIÓN: CTEs para análisis de retención
-- ============================================================

-- Cohorte: estudiantes agrupados por nivel de motivación al inicio (usando Previous_Scores como proxy)
WITH cohorte AS (
    SELECT
        student_id,
        Motivation_Level,
        CASE
            WHEN Previous_Scores >= 75 THEN 'Alta base'
            WHEN Previous_Scores >= 60 THEN 'Media base'
            ELSE 'Baja base'
        END AS grupo_entrada
    FROM students
),
resultados AS (
    SELECT
        c.grupo_entrada,
        c.Motivation_Level,
        COUNT(*)                         AS total,
        ROUND(AVG(s.Exam_Score), 2)      AS puntaje_promedio,
        ROUND(AVG(s.Exam_Score - s.Previous_Scores), 2) AS mejora_promedio,
        COUNT(CASE WHEN s.Exam_Score > s.Previous_Scores THEN 1 END) AS estudiantes_que_mejoraron
    FROM cohorte c
    JOIN students s USING (student_id)
    GROUP BY c.grupo_entrada, c.Motivation_Level
)
SELECT
    grupo_entrada,
    Motivation_Level,
    total,
    puntaje_promedio,
    mejora_promedio,
    estudiantes_que_mejoraron,
    ROUND(estudiantes_que_mejoraron * 100.0 / total, 1) AS tasa_mejora_pct
FROM resultados
ORDER BY grupo_entrada, Motivation_Level;

-- POR QUÉ (lógica técnica):
-- 1. La cohorte se define en la primera CTE — separar la lógica de segmentación de la de aggregation.
-- 2. COUNT(CASE WHEN ...) es el patrón estándar para conteos condicionales sin subqueries.
-- 3. La tasa de mejora porcentual convierte un conteo en una métrica de negocio accionable.

-- USO EN NEGOCIO:
-- El análisis de cohortes es la base de las métricas de retención en productos y en educación.
-- Presentar "el 78% de estudiantes de baja base con alta motivación mejoró" impacta en cualquier junta directiva.


-- ============================================================
-- EJERCICIO 32: CTE para métricas intermedias de dashboard ejecutivo
-- FUNCIÓN: CTEs como capa de transformación BI
-- ============================================================

WITH kpis_base AS (
    SELECT
        School_Type,
        COUNT(*)                                                       AS n_estudiantes,
        ROUND(AVG(Exam_Score), 2)                                      AS puntaje_promedio,
        ROUND(AVG(Attendance), 2)                                      AS asistencia_promedio,
        ROUND(AVG(Hours_Studied), 2)                                   AS horas_estudio_promedio,
        COUNT(CASE WHEN Exam_Score >= 80 THEN 1 END)                   AS aprobados_alto,
        COUNT(CASE WHEN Exam_Score < 60 THEN 1 END)                    AS reprobados
    FROM students
    GROUP BY School_Type
),
kpis_enriquecidos AS (
    SELECT
        *,
        ROUND(aprobados_alto * 100.0 / n_estudiantes, 1) AS tasa_alto_rendimiento,
        ROUND(reprobados * 100.0 / n_estudiantes, 1)     AS tasa_reprobacion,
        puntaje_promedio - AVG(puntaje_promedio) OVER ()  AS vs_promedio_global
    FROM kpis_base
)
SELECT * FROM kpis_enriquecidos ORDER BY puntaje_promedio DESC;

-- POR QUÉ (lógica técnica):
-- 1. La primera CTE construye los KPIs base con GROUP BY — la capa de agregación.
-- 2. La segunda CTE enriquece con ratios y comparación global usando OVER () — imposible en GROUP BY directo.
-- 3. Separar las dos capas evita repetir el GROUP BY en una query gigante y difícil de mantener.

-- USO EN NEGOCIO:
-- Este es el patrón exacto detrás de cualquier dashboard BI: capas de transformación
-- progresiva hasta llegar a métricas listas para visualizar en Tableau, Power BI o Metabase.


-- ============================================================
-- EJERCICIO 33: Churn simple — estudiantes que "cayeron" significativamente
-- FUNCIÓN: CTEs + lógica de negocio de retención
-- ============================================================

WITH rendimiento AS (
    SELECT
        student_id,
        Exam_Score,
        Previous_Scores,
        Exam_Score - Previous_Scores AS delta,
        Attendance,
        Tutoring_Sessions
    FROM students
),
en_riesgo AS (
    SELECT
        *,
        CASE
            WHEN delta < -15 AND Attendance < 70 THEN 'Churn crítico'
            WHEN delta < -10 OR Attendance < 70  THEN 'En riesgo'
            WHEN delta >= 0  AND Attendance >= 85 THEN 'Retenido activo'
            ELSE 'Estable'
        END AS estado_retención
    FROM rendimiento
),
resumen_retención AS (
    SELECT
        estado_retención,
        COUNT(*) AS n,
        ROUND(AVG(Exam_Score), 2) AS puntaje_promedio,
        ROUND(AVG(Tutoring_Sessions), 2) AS tutoring_promedio
    FROM en_riesgo
    GROUP BY estado_retención
)
SELECT * FROM resumen_retención ORDER BY n DESC;

-- POR QUÉ (lógica técnica):
-- 1. El concepto de "churn" en educación equivale al abandono o caída crítica de rendimiento.
-- 2. Usar múltiples condiciones en CASE WHEN crea segmentos mutuamente excluyentes y exhaustivos.
-- 3. La CTE de resumen agrupa para presentar a dirección — siempre pensar en el consumidor final de los datos.

-- USO EN NEGOCIO:
-- Un sistema de alerta temprana basado en esta lógica puede enviar notificaciones automáticas
-- a orientadores cuando un estudiante entra en "Churn crítico" — prevención antes de deserción.


-- ============================================================
-- EJERCICIO 34: CTE con aggregation + JOIN posterior
-- FUNCIÓN: CTE como tabla derivada para JOIN
-- ============================================================

WITH promedios_grupo AS (
    SELECT
        Parental_Education_Level,
        Internet_Access,
        ROUND(AVG(Exam_Score), 2)      AS prom_puntaje,
        ROUND(AVG(Hours_Studied), 2)   AS prom_horas,
        COUNT(*)                       AS n
    FROM students
    GROUP BY Parental_Education_Level, Internet_Access
)
SELECT
    s.student_id,
    s.Parental_Education_Level,
    s.Internet_Access,
    s.Exam_Score,
    g.prom_puntaje,
    s.Exam_Score - g.prom_puntaje AS vs_su_grupo,
    g.n AS tamaño_grupo
FROM students s
JOIN promedios_grupo g
    ON s.Parental_Education_Level = g.Parental_Education_Level
    AND s.Internet_Access = g.Internet_Access
ORDER BY vs_su_grupo DESC;

-- POR QUÉ (lógica técnica):
-- 1. La CTE actúa como tabla derivada — calculada una vez, reutilizada en el JOIN.
-- 2. JOIN en dos columnas evita ambigüedad en el cruce de grupos.
-- 3. vs_su_grupo es la métrica clave: compara al individuo con su propio contexto, no con el promedio global.

-- USO EN NEGOCIO:
-- Un estudiante puede tener un puntaje de 70 (bajo globalmente) pero ser el top de su grupo
-- (educación media + sin internet) — el contexto cambia completamente la interpretación.


-- ============================================================
-- EJERCICIO 35: Pipeline completo — raw → limpieza → métricas → ranking
-- FUNCIÓN: CTEs encadenadas — caso de portafolio completo
-- ============================================================

-- PIPELINE COMPLETO: de datos crudos a tabla lista para dashboard

WITH raw AS (
    -- Paso 1: seleccionar columnas relevantes, excluir nulls
    SELECT
        student_id,
        Hours_Studied,
        Attendance,
        Exam_Score,
        Previous_Scores,
        Tutoring_Sessions,
        School_Type,
        Family_Income,
        Motivation_Level,
        Learning_Disabilities
    FROM students
    WHERE Exam_Score IS NOT NULL
      AND Hours_Studied IS NOT NULL
      AND Attendance IS NOT NULL
),
limpio AS (
    -- Paso 2: normalizar y crear variables derivadas
    SELECT
        student_id,
        School_Type,
        Family_Income,
        Motivation_Level,
        Learning_Disabilities,
        Exam_Score,
        Previous_Scores,
        Exam_Score - Previous_Scores                          AS mejora,
        Hours_Studied + Tutoring_Sessions * 2                 AS esfuerzo_ponderado,
        CASE WHEN Attendance >= 85 THEN 'Alta' WHEN Attendance >= 70 THEN 'Media' ELSE 'Baja' END AS cat_asistencia
    FROM raw
),
metricas AS (
    -- Paso 3: calcular métricas de grupo y posición relativa
    SELECT
        *,
        AVG(Exam_Score)    OVER (PARTITION BY School_Type, Family_Income) AS benchmark_grupo,
        ROW_NUMBER()       OVER (PARTITION BY School_Type ORDER BY Exam_Score DESC) AS rank_en_escuela,
        NTILE(5)           OVER (ORDER BY Exam_Score)                              AS quintil_global,
        SUM(esfuerzo_ponderado) OVER (PARTITION BY School_Type
                                      ORDER BY student_id
                                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS esfuerzo_acumulado
    FROM limpio
),
resultado_final AS (
    -- Paso 4: enriquecer con etiquetas y filtros de negocio
    SELECT
        student_id,
        School_Type,
        Family_Income,
        Motivation_Level,
        Learning_Disabilities,
        Exam_Score,
        mejora,
        cat_asistencia,
        ROUND(benchmark_grupo, 2)            AS benchmark,
        ROUND(Exam_Score - benchmark_grupo, 2) AS vs_benchmark,
        rank_en_escuela,
        quintil_global,
        esfuerzo_acumulado,
        CASE
            WHEN quintil_global = 5 AND mejora > 0 THEN 'Estrella en ascenso'
            WHEN quintil_global = 5               THEN 'Top performer'
            WHEN quintil_global = 1 AND mejora < 0 THEN 'Caso crítico'
            WHEN Learning_Disabilities = 'Yes'    THEN 'Atención especial'
            ELSE 'Seguimiento estándar'
        END AS etiqueta_accion
    FROM metricas
)
SELECT *
FROM resultado_final
ORDER BY School_Type, rank_en_escuela
LIMIT 50;

-- POR QUÉ (lógica técnica):
-- 1. Cada CTE es un paso explícito del pipeline — raw → limpio → metricas → resultado_final.
-- 2. Las window functions se concentran en un solo paso (metricas) para no mezclar responsabilidades.
-- 3. La etiqueta_accion convierte quintiles y flags en instrucciones claras para el equipo operativo.

-- USO EN NEGOCIO:
-- Este es el patrón de una "tabla de hechos enriquecida" — el output que alimenta un dashboard
-- ejecutivo. Cualquier herramienta de BI (Tableau, Power BI, Metabase) puede conectarse
-- directamente a esta query y mostrar los indicadores sin transformación adicional.
-- Dominar este patrón te hace valioso en cualquier equipo de analytics.
