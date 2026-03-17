-- =====================================================
-- PREGUNTA 1: Brecha digital y de recursos académicos
-- =====================================================

SELECT
    Access_to_Resources,
    Internet_Access,
    COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
WHERE Access_to_Resources IN ('High', 'Low')
  AND Internet_Access IN ('Yes', 'No')
GROUP BY Access_to_Resources, Internet_Access
ORDER BY avg_exam_score DESC;

-- ¿Por qué es útil para negocio educativo?
-- • Permite medir desigualdad académica causada por acceso tecnológico.
-- • Justifica inversión en infraestructura digital escolar.
-- • Identifica grupos vulnerables que necesitan apoyo prioritario.


-- =====================================================
-- PREGUNTA 2: Impacto de horas de estudio en rendimiento
-- =====================================================

SELECT
    CASE
        WHEN Hours_Studied < 10 THEN 'Bajo'
        WHEN Hours_Studied < 20 THEN 'Medio'
        ELSE 'Alto'
    END AS study_level,
    COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
GROUP BY study_level
ORDER BY avg_exam_score DESC;

-- ¿Por qué es útil para negocio educativo?
-- • Permite identificar hábitos de estudio efectivos.
-- • Ayuda a diseñar planes de refuerzo académico.
-- • Orienta recomendaciones personalizadas según dedicación académica.





-- =====================================================
-- PREGUNTA 3: Influencia del apoyo parental
-- =====================================================

SELECT
    Parental_Involvement,
    COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
GROUP BY Parental_Involvement
ORDER BY avg_exam_score DESC;

-- ¿Por qué es útil para negocio educativo?
-- • Permite evaluar el impacto del entorno familiar en el rendimiento.
-- • Ayuda a diseñar programas de acompañamiento para padres.
-- • Sustenta estrategias de orientación familiar en instituciones educativas.





-- =====================================================
-- PREGUNTA 4: Influencia del acceso a internet
-- =====================================================

SELECT
    Internet_Access,
    COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
GROUP BY Internet_Access
ORDER BY avg_exam_score DESC;

-- ¿Por qué es útil para negocio educativo?
-- • Justifica inversión en conectividad y acceso digital.
-- • Evidencia el impacto de recursos online en el desempeño.
-- • Permite reducir brechas tecnológicas entre estudiantes.




-- =====================================================
-- PREGUNTA 5: Impacto de la asistencia en el rendimiento
-- =====================================================

SELECT
    CASE
        WHEN Attendance < 60 THEN 'Baja'
        WHEN Attendance < 85 THEN 'Media'
        ELSE 'Alta'
    END AS attendance_level,
    COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
GROUP BY attendance_level
ORDER BY avg_exam_score DESC;

-- ¿Por qué es útil para negocio educativo?
-- • Permite identificar si la presencia en clase influye directamente en el rendimiento.
-- • Ayuda a justificar políticas contra el ausentismo escolar.
-- • Facilita la detección temprana de estudiantes en riesgo académico.





-- =====================================================
-- PREGUNTA 6: Impacto de horas de sueño en rendimiento
-- =====================================================

SELECT
    CASE
        WHEN Sleep_Hours < 6 THEN 'Pocas'
        WHEN Sleep_Hours < 8 THEN 'Adecuadas'
        ELSE 'Óptimas'
    END AS sleep_level,
    COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
GROUP BY sleep_level
ORDER BY avg_exam_score DESC;

-- ¿Por qué es útil para negocio educativo?
-- • Relaciona hábitos de salud con desempeño académico.
-- • Permite diseñar campañas de bienestar estudiantil.
-- • Ayuda a prevenir bajo rendimiento por fatiga o mala concentración.






-- =====================================================
-- PREGUNTA 7: Impacto de tutorías académicas
-- =====================================================

SELECT
    Tutoring_Sessions,
    COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
GROUP BY Tutoring_Sessions
ORDER BY avg_exam_score DESC;

-- ¿Por qué es útil para negocio educativo?
-- • Permite evaluar la efectividad de programas de refuerzo escolar.
-- • Ayuda a justificar inversión en tutorías académicas.
-- • Identifica estudiantes que más se benefician del acompañamiento.
