-- =====================================================
-- EJERCICIO 1
-- Segmentación por horas de estudio
-- Objetivo: ver cómo cambian las notas promedio según cuánto estudian
-- =====================================================

SELECT
    CASE
        WHEN Hours_Studied < 10 THEN 'Low Study'
        WHEN Hours_Studied < 20 THEN 'Medium Study'
        ELSE 'High Study'
    END AS Study_Level,
    
    AVG(Exam_Score) AS Average_Score

FROM students

GROUP BY Study_Level

ORDER BY Average_Score DESC;



-- =====================================================
-- EJERCICIO 2
-- Segmentación por asistencia
-- Objetivo: analizar impacto de la asistencia en el rendimiento
-- =====================================================

SELECT
    CASE
        WHEN Attendance < 60 THEN 'Low Attendance'
        WHEN Attendance < 85 THEN 'Medium Attendance'
        ELSE 'High Attendance'
    END AS Attendance_Level,
    
    AVG(Exam_Score) AS Average_Score

FROM students

GROUP BY Attendance_Level

ORDER BY Average_Score DESC;



-- =====================================================
-- EJERCICIO 3 (NIVEL PRO)
-- Segmentación combinada: estudio + asistencia
-- Objetivo: analizar efecto conjunto de hábitos en rendimiento
-- =====================================================

SELECT
    CASE
        WHEN Hours_Studied < 10 THEN 'Low Study'
        WHEN Hours_Studied < 20 THEN 'Medium Study'
        ELSE 'High Study'
    END AS Study_Level,

    CASE
        WHEN Attendance < 60 THEN 'Low Attendance'
        WHEN Attendance < 85 THEN 'Medium Attendance'
        ELSE 'High Attendance'
    END AS Attendance_Level,

    AVG(Exam_Score) AS Average_Score

FROM students

GROUP BY
    Study_Level,
    Attendance_Level

ORDER BY Average_Score DESC;