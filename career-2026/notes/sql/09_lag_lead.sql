-- ============================================================
-- DÍA 9 — Funciones de Navegación: LAG() y LEAD()
-- Dataset: Student Performance
-- Objetivo: Análisis de cohortes y retención con nivel industria
-- ============================================================


-- ============================================================
-- LAG #1 — Rendimiento Marginal por Horas de Estudio
-- ============================================================
-- Utilidad: Identifica cuántos puntos de diferencia hay entre
-- estudiantes por cada hora adicional de estudio registrada.
-- Permite recomendar un umbral mínimo de horas con base en datos.
-- ============================================================
SELECT
    
    hours_studied,
    exam_score,
    -- Trae el exam_score del estudiante con una hora menos de estudio
    LAG(exam_score) OVER (
        ORDER BY hours_studied
    ) AS score_estudiante_anterior,
    -- Calcula la diferencia: rendimiento marginal de una hora extra
    exam_score - LAG(exam_score) OVER (
        ORDER BY hours_studied
    ) AS diferencia_marginal
FROM student_performace
ORDER BY hours_studied;


-- ============================================================
-- LAG #2 — Sueño y Rendimiento
-- ============================================================
-- Utilidad: Detecta si hay un umbral de sueño por debajo del
-- cual el rendimiento cae drásticamente. Útil para programas
-- de bienestar estudiantil basados en evidencia.
-- ============================================================
SELECT
    
    exam_score,
    sleep_hours,
    -- Trae las horas de sueño del estudiante con score inmediatamente superior
    LAG(sleep_hours) OVER (
        ORDER BY exam_score DESC
    ) AS sleep_estudiante_superior,
    -- Diferencia en sueño respecto al estudiante de mejor rendimiento
    sleep_hours - LAG(sleep_hours) OVER (
        ORDER BY exam_score DESC
    ) AS diff_sueno
FROM student_performace
ORDER BY exam_score DESC;


-- ============================================================
-- LAG #3 — Asistencia Comparativa dentro del Mismo Tipo de Escuela
-- ============================================================
-- Utilidad: Compara la asistencia dentro del mismo entorno educativo
-- (Público vs Privado) para ver si el historial académico previo
-- está correlacionado con el compromiso actual.
-- PARTITION BY es clave: evita comparar estudiantes de diferentes
-- tipos de escuela entre sí.
-- ============================================================
SELECT
    
    school_type,
    previous_scores,
    attendance,
    -- PARTITION BY garantiza que LAG opere SOLO dentro del mismo school_type
    LAG(attendance) OVER (
        PARTITION BY school_type
        ORDER BY previous_scores
    ) AS asistencia_anterior,
    -- Diferencia de asistencia respecto al registro previo en el mismo grupo
    attendance - LAG(attendance) OVER (
        PARTITION BY school_type
        ORDER BY previous_scores
    ) AS diff_asistencia
FROM student_performace
ORDER BY school_type, previous_scores;


-- ============================================================
-- LEAD #1 — Brecha de Puntos para el Siguiente Rango
-- ============================================================
-- Utilidad: Base para sistemas de gamificación. Le muestra al
-- estudiante exactamente cuántos puntos necesita para superar
-- al compañero que está justo por encima en el ranking.
-- ============================================================
SELECT
    
    exam_score,
    -- Trae el score del estudiante inmediatamente superior en el ranking
    LEAD(exam_score) OVER (
        ORDER BY exam_score
    ) AS score_siguiente,
    -- Puntos que le faltan para alcanzar al siguiente
    LEAD(exam_score) OVER (
        ORDER BY exam_score
    ) - exam_score AS puntos_para_subir
FROM student_performace
ORDER BY exam_score;


-- ============================================================
-- LEAD #2 — Proyección de Impacto de Tutorías
-- ============================================================
-- Utilidad: Visualiza el salto potencial en calificación si un
-- estudiante incrementa su frecuencia de tutorías. Justifica
-- el ROI de invertir en sesiones adicionales.
-- ============================================================
SELECT
    
    tutoring_sessions,
    exam_score,
    -- Score del estudiante que tomó una sesión de tutoría más
    LEAD(exam_score) OVER (
        ORDER BY tutoring_sessions
    ) AS score_con_mas_tutorias,
    -- Cuánto podría mejorar con una sesión adicional
    LEAD(exam_score) OVER (
        ORDER BY tutoring_sessions
    ) - exam_score AS salto_potencial
FROM student_performace
ORDER BY tutoring_sessions;


-- ============================================================
-- LEAD #3 — Impacto de Actividad Física por Nivel de Motivación
-- ============================================================
-- Utilidad: Analiza variabilidad intra-grupo en actividad física.
-- Si dentro de "High Motivation" la actividad varía mucho,
-- hay otros factores influyendo que vale la pena investigar.
-- PARTITION BY asegura comparar solo dentro del mismo nivel
-- de motivación, no entre grupos distintos.
-- ============================================================
SELECT
    
    motivation_level,
    physical_activity,
    -- Actividad física del siguiente estudiante en el mismo grupo de motivación
    LEAD(physical_activity) OVER (
        PARTITION BY motivation_level
        ORDER BY physical_activity
    ) AS actividad_siguiente,
    -- Diferencia de actividad física dentro del mismo grupo
    LEAD(physical_activity) OVER (
        PARTITION BY motivation_level
        ORDER BY physical_activity
    ) - physical_activity AS diff_actividad
FROM student_performace
ORDER BY motivation_level, physical_activity;