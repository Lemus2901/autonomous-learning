# 📘 SQL Cheatsheet v1 — Fundamentos y Window Functions

Guía profesional de referencia rápida con ejemplos aplicados al dataset **student_performance**.

---

# 🧱 1. FUNDAMENTOS SQL

## 🔹 INNER JOIN

### 🧩 Snippet de código
```sql
SELECT s.Student_ID, s.Exam_Score, sc.School_Name
FROM students s
INNER JOIN schools sc
    ON s.School_ID = sc.School_ID;
```

### ⚙️ Por qué funciona
• Une registros que coinciden en ambas tablas
• Usa claves para relacionar información
• Evita datos huérfanos

### 💼 Explicación de negocio
Permite combinar datos académicos con información institucional para generar reportes integrales.

---

## 🔹 LEFT JOIN

### 🧩 Snippet de código
```sql
SELECT s.Student_ID, t.Tutoring_Type
FROM students s
LEFT JOIN tutoring t
    ON s.Student_ID = t.Student_ID;
```

### ⚙️ Por qué funciona
• Conserva todos los registros de la tabla principal
• Los faltantes se rellenan con NULL
• Útil para detectar ausencia de datos relacionados

### 💼 Explicación de negocio
Sirve para identificar estudiantes que no han recibido tutorías.

---

## 🔹 GROUP BY + HAVING

### 🧩 Snippet de código
```sql
SELECT Parental_Involvement, AVG(Exam_Score) AS avg_score
FROM student_performance
GROUP BY Parental_Involvement
HAVING AVG(Exam_Score) > 67;
```

### ⚙️ Por qué funciona
• GROUP BY agrupa registros
• AVG calcula métricas por grupo
• HAVING filtra resultados agregados

### 💼 Explicación de negocio
Permite identificar qué grupos familiares superan cierto umbral de rendimiento.

---

## 🔹 Subqueries

### 🧩 Snippet de código
```sql
SELECT *
FROM student_performance
WHERE Exam_Score > (
    SELECT AVG(Exam_Score) FROM student_performance
);
```

### ⚙️ Por qué funciona
• Consulta interna calcula referencia
• Consulta externa compara contra ese valor
• Permite filtros dinámicos

### 💼 Explicación de negocio
Ayuda a detectar estudiantes por encima del promedio general.

---

# 🧠 2. LECTURABILIDAD — CTEs

## 🔹 Common Table Expressions (CTEs)

### 🧩 Snippet de código
```sql
WITH avg_scores AS (
    SELECT Parental_Involvement,
           AVG(Exam_Score) AS avg_score
    FROM student_performance
    GROUP BY Parental_Involvement
)
SELECT *
FROM avg_scores
WHERE avg_score > 67;
```

### ⚙️ Por qué funciona
• Divide consultas complejas en pasos
• Mejora legibilidad
• Facilita mantenimiento

### 💼 Explicación de negocio
Permite estructurar reportes académicos complejos de forma clara.

---

# 🪟 3. WINDOW FUNCTIONS (Núcleo avanzado)

## 🔹 ROW_NUMBER()

### 🧩 Snippet de código
```sql
SELECT Student_ID,
       ROW_NUMBER() OVER(ORDER BY Exam_Score DESC) AS position
FROM student_performance;
```

### ⚙️ Por qué funciona
• Numera filas sin repetir posiciones
• Respeta orden especificado
• No agrupa registros

### 💼 Explicación de negocio
Permite crear rankings únicos de rendimiento estudiantil.

---

## 🔹 RANK()

### 🧩 Snippet de código
```sql
SELECT Student_ID,
       RANK() OVER(ORDER BY Exam_Score DESC) AS ranking
FROM student_performance;
```

### ⚙️ Por qué funciona
• Empates comparten posición
• Puede dejar huecos en ranking
• Útil para clasificaciones oficiales

### 💼 Explicación de negocio
Sirve para premiaciones académicas con posiciones compartidas.

---

## 🔹 DENSE_RANK()

### 🧩 Snippet de código
```sql
SELECT Student_ID,
       DENSE_RANK() OVER(ORDER BY Exam_Score DESC) AS ranking
FROM student_performance;
```

### ⚙️ Por qué funciona
• Empates comparten posición
• No deja huecos
• Ranking continuo

### 💼 Explicación de negocio
Útil para segmentación por niveles de desempeño.

---

## 🔹 LAG()

### 🧩 Snippet de código
```sql
SELECT Student_ID,
       Exam_Score,
       LAG(Exam_Score) OVER(ORDER BY Exam_Score) AS prev_score
FROM student_performance;
```

### ⚙️ Por qué funciona
• Accede al valor anterior
• Permite comparar cambios
• No requiere self join

### 💼 Explicación de negocio
Permite analizar variaciones de rendimiento entre evaluaciones.

---

## 🔹 LEAD()

### 🧩 Snippet de código
```sql
SELECT Student_ID,
       Exam_Score,
       LEAD(Exam_Score) OVER(ORDER BY Exam_Score) AS next_score
FROM student_performance;
```

### ⚙️ Por qué funciona
• Accede al valor siguiente
• Facilita análisis de progresión
• Ideal para series ordenadas

### 💼 Explicación de negocio
Ayuda a proyectar evolución académica.

---

## 🔹 SUM() OVER — Totales acumulados

### 🧩 Snippet de código
```sql
SELECT Student_ID,
       Hours_Studied,
       SUM(Hours_Studied) OVER(
           ORDER BY Previous_Scores
       ) AS running_total
FROM student_performance;
```

### ⚙️ Por qué funciona
• Acumula valores progresivamente
• Mantiene filas originales
• No requiere GROUP BY

### 💼 Explicación de negocio
Permite analizar acumulados de esfuerzo académico.

---

## 🔹 PARTITION BY

### 🧩 Snippet de código
```sql
SELECT Parental_Involvement,
       Student_ID,
       RANK() OVER(
           PARTITION BY Parental_Involvement
           ORDER BY Exam_Score DESC
       ) AS rank_within_group
FROM student_performance;
```

### ⚙️ Por qué funciona
• Divide datos por grupos
• Reinicia cálculos por categoría
• Permite comparaciones internas

### 💼 Explicación de negocio
Sirve para comparar estudiantes dentro de su mismo contexto social.

---

# ⚡ 4. OPTIMIZACIÓN BÁSICA

## 🔹 Evitar SELECT *

### 🧩 Snippet de código
```sql
SELECT Student_ID, Exam_Score
FROM student_performance;
```

### ⚙️ Por qué funciona
• Reduce uso de memoria
• Mejora velocidad
• Evita traer columnas innecesarias

### 💼 Explicación de negocio
Optimiza dashboards y reportes grandes.

---

## 🔹 Early Filtering

### 🧩 Snippet de código
```sql
SELECT *
FROM student_performance
WHERE Exam_Score > 80;
```

### ⚙️ Por qué funciona
• Reduce volumen de datos temprano
• Mejora rendimiento de joins
• Disminuye costo computacional

### 💼 Explicación de negocio
Acelera análisis en bases de datos académicas masivas.

---

# 🧭 Diferencia clave: ORDER BY vs PARTITION BY

| Característica | ORDER BY | PARTITION BY |
|---------------|----------|---------------|
| Función | Ordena todos los datos | Divide datos en grupos |
| Reinicio de cálculos | No | Sí |
| Uso típico | Rankings globales | Rankings por categoría |

---

# ✅ Objetivo del documento

Este cheatsheet permite:

• Repasar rápidamente conceptos clave
• Documentar habilidades técnicas profesionalmente
• Explicar análisis SQL a perfiles no técnicos
• Servir como base para proyectos de portafolio

---

**Autor:** Andrés Lemus  
**Ruta sugerida:** docs/cheatsheet.md

