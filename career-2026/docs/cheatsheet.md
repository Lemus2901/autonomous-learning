# SQL Cheatsheet v2 — Stack Profesional Mes 1
**Plan Data Scientist 180 días | Semanas 1–2**  
Dataset: Student Performance (`students`)  
Estructura: Snippet → 3 bullets técnicos → Caso de negocio

---

## PILAR 1 — Fundamentos

### INNER JOIN

```sql
SELECT
    s.student_id,
    s.exam_score,
    t.teacher_name
FROM students s
INNER JOIN teachers t ON s.school_type = t.school_type;
```

**Por qué:**
- Devuelve solo las filas que tienen coincidencia en **ambas** tablas.
- Si un estudiante no tiene teacher asociado, **no aparece** en el resultado.
- Es el JOIN más eficiente porque descarta filas sin match temprano.

> **Negocio:** Obtener solo los estudiantes que tienen un tutor asignado para calcular métricas de rendimiento comparables. Evita incluir datos incompletos que distorsionen los KPIs.

---

### LEFT JOIN

```sql
SELECT
    s.student_id,
    s.exam_score,
    t.teacher_name
FROM students s
LEFT JOIN teachers t ON s.school_type = t.school_type;
```

**Por qué:**
- Devuelve **todas** las filas de la tabla izquierda, aunque no haya match.
- Las columnas de la tabla derecha aparecen como `NULL` cuando no hay coincidencia.
- Útil para detectar registros huérfanos (sin relación).

> **Negocio:** Identificar estudiantes que aún no tienen tutor asignado. Los `NULL` en `teacher_name` son la señal de alerta para el equipo de coordinación académica.

---

### GROUP BY

```sql
SELECT
    parental_involvement,
    AVG(exam_score)      AS promedio_examen,
    COUNT(student_id)    AS total_estudiantes
FROM students
GROUP BY parental_involvement
ORDER BY promedio_examen DESC;
```

**Por qué:**
- Colapsa múltiples filas en una sola por cada valor único del grupo.
- Todas las columnas del SELECT deben estar en GROUP BY o dentro de una función de agregación.
- Sin GROUP BY, las funciones como `AVG()` operan sobre toda la tabla.

> **Negocio:** Comparar el rendimiento promedio según el nivel de involucramiento parental. Insumo directo para decidir dónde enfocar programas de apoyo familiar.

---

### HAVING

```sql
SELECT
    school_type,
    AVG(exam_score) AS promedio
FROM students
GROUP BY school_type
HAVING AVG(exam_score) > 70;
```

**Por qué:**
- `HAVING` filtra **después** de la agregación; `WHERE` filtra **antes**.
- No puedes usar alias del SELECT dentro de `HAVING` en la mayoría de motores.
- Se ejecuta después de `GROUP BY` y antes de `ORDER BY`.

> **Negocio:** Mostrar solo los tipos de escuela cuyo rendimiento promedio supera el umbral mínimo de aprobación. Elimina del reporte los grupos que no cumplen el estándar institucional.

---

### Subquery

```sql
SELECT
    student_id,
    exam_score
FROM students
WHERE exam_score > (
    SELECT AVG(exam_score)
    FROM students
);
```

**Por qué:**
- La subquery se ejecuta primero y su resultado se usa como valor de comparación.
- Evita tener que calcular el promedio por separado y pegarlo manualmente.
- Las subqueries en `WHERE` se llaman *scalar subqueries* cuando devuelven un solo valor.

> **Negocio:** Identificar estudiantes sobre el promedio para programas de excelencia o becas. La subquery garantiza que el umbral se recalcula automáticamente si los datos cambian.

---

## PILAR 2 — Legibilidad con CTEs

### CTE básica (`WITH`)

```sql
WITH promedio_general AS (
    SELECT AVG(exam_score) AS avg_score
    FROM students
)
SELECT
    s.student_id,
    s.exam_score,
    p.avg_score,
    s.exam_score - p.avg_score AS diferencia_vs_promedio
FROM students s
CROSS JOIN promedio_general p
ORDER BY diferencia_vs_promedio DESC;
```

**Por qué:**
- Nombra un bloque de lógica reutilizable, como una variable en programación.
- Reemplaza subqueries anidadas que son difíciles de leer y mantener.
- El motor la ejecuta una vez y la almacena temporalmente en memoria.

> **Negocio:** Estructurar reportes de fin de mes que comparan el rendimiento individual contra el promedio institucional. Un analista puede leer la query de arriba abajo sin perderse en paréntesis anidados.

---

### CTEs encadenadas (múltiples pasos)

```sql
WITH estudiantes_alto_rendimiento AS (
    SELECT student_id, exam_score, hours_studied
    FROM students
    WHERE exam_score >= 80
),
promedio_horas AS (
    SELECT AVG(hours_studied) AS avg_horas
    FROM estudiantes_alto_rendimiento
)
SELECT
    e.student_id,
    e.exam_score,
    e.hours_studied,
    p.avg_horas,
    e.hours_studied - p.avg_horas AS diff_horas
FROM estudiantes_alto_rendimiento e
CROSS JOIN promedio_horas p
ORDER BY e.exam_score DESC;
```

**Por qué:**
- Cada CTE construye sobre la anterior, como pasos secuenciales de un pipeline.
- Facilita el debugging: puedes probar cada bloque individualmente.
- Hace que la query sea auto-documentada: el nombre de cada CTE describe qué hace.

> **Negocio:** Analizar cuántas horas estudian los alumnos de alto rendimiento en comparación con su propio subgrupo. Insumo para definir el "perfil de estudiante exitoso" basado en datos.

---

### CTE para eliminar duplicados

```sql
WITH ranked_students AS (
    SELECT
        student_id,
        exam_score,
        ROW_NUMBER() OVER (
            PARTITION BY student_id
            ORDER BY exam_score DESC
        ) AS rn
    FROM students
)
SELECT student_id, exam_score
FROM ranked_students
WHERE rn = 1;
```

**Por qué:**
- Combina CTE + Window Function para el patrón clásico de deduplicación.
- El `WHERE rn = 1` en la CTE externa filtra solo el registro top por estudiante.
- Sin la CTE, esta lógica requeriría una subquery anidada menos legible.

> **Negocio:** Garantizar que cada estudiante aparezca una sola vez en el reporte final usando su mejor calificación. Evita inflar métricas por registros duplicados.

---

## PILAR 3 — Window Functions

### ROW_NUMBER()

```sql
SELECT
    student_id,
    exam_score,
    ROW_NUMBER() OVER (ORDER BY exam_score DESC) AS ranking_global
FROM students
ORDER BY ranking_global;
```

**Por qué:**
- Asigna números únicos y consecutivos — nunca hay empates.
- Si dos estudiantes tienen el mismo score, el orden entre ellos es arbitrario pero único.
- Ideal para paginación o para quedarse con exactamente 1 registro por grupo.

> **Negocio:** Generar un ranking oficial de estudiantes para el tablero de honor. Al ser único, evita ambigüedades en posiciones compartidas y permite paginar resultados en apps.

---

### RANK() y DENSE_RANK()

```sql
SELECT
    student_id,
    exam_score,
    RANK() OVER (ORDER BY exam_score DESC)       AS rank_con_saltos,
    DENSE_RANK() OVER (ORDER BY exam_score DESC) AS rank_sin_saltos
FROM students
ORDER BY exam_score DESC;
```

**Por qué:**
- `RANK()` respeta empates pero **salta** números (1, 2, 2, 4).
- `DENSE_RANK()` respeta empates **sin saltar** (1, 2, 2, 3).
- Ambos son deterministas cuando hay empates, a diferencia de `ROW_NUMBER()`.

> **Negocio:** `RANK()` para competencias donde los empates comparten posición y el siguiente puesto queda vacante. `DENSE_RANK()` para clasificaciones continuas como percentiles o niveles de desempeño sin huecos.

---

### PARTITION BY — El corazón de las ventanas

```sql
SELECT
    student_id,
    school_type,
    exam_score,
    RANK() OVER (
        PARTITION BY school_type
        ORDER BY exam_score DESC
    ) AS ranking_por_escuela
FROM students
ORDER BY school_type, ranking_por_escuela;
```

**Por qué:**
- `PARTITION BY` divide la tabla en grupos independientes antes de aplicar la función.
- Cada grupo tiene su propio orden y numeración sin mezclarse con los demás.
- Sin `PARTITION BY`, la función opera sobre toda la tabla como un solo bloque.

> **Negocio:** Comparar estudiantes dentro de su propio contexto (pública vs privada) en lugar de contra toda la institución. Evita penalizar o premiar por el entorno en lugar del esfuerzo individual.

---

### LAG() — Mirar hacia atrás

```sql
SELECT
    student_id,
    hours_studied,
    exam_score,
    LAG(exam_score, 1, 0) OVER (
        ORDER BY hours_studied
    )                                             AS score_anterior,
    exam_score - LAG(exam_score, 1, 0) OVER (
        ORDER BY hours_studied
    )                                             AS diferencia_marginal
FROM students
ORDER BY hours_studied;
```

**Por qué:**
- `LAG(col, offset, default)` trae el valor de `offset` filas atrás en la ventana.
- El tercer argumento evita `NULL` en la primera fila de la partición.
- No requiere self-join, simplificando el código y mejorando el rendimiento.

> **Negocio:** Calcular el rendimiento marginal por hora adicional de estudio. Si la diferencia promedio es +2 puntos/hora, la institución puede fijar un umbral mínimo recomendado basado en evidencia real.

---

### LEAD() — Mirar hacia adelante

```sql
SELECT
    student_id,
    exam_score,
    LEAD(exam_score, 1, 0) OVER (
        ORDER BY exam_score
    )                                             AS score_siguiente,
    LEAD(exam_score, 1, 0) OVER (
        ORDER BY exam_score
    ) - exam_score                                AS puntos_para_subir
FROM students
ORDER BY exam_score;
```

**Por qué:**
- `LEAD(col, offset, default)` trae el valor de `offset` filas adelante en la ventana.
- La diferencia `siguiente - actual` representa la brecha hacia el próximo nivel.
- Es el complemento natural de `LAG()` para análisis de brechas bidireccionales.

> **Negocio:** Base para sistemas de gamificación — mostrarle al estudiante cuántos puntos necesita para superar al compañero inmediatamente superior. Aumenta la motivación con metas alcanzables y concretas.

---

### SUM() OVER — Running Total

```sql
SELECT
    student_id,
    parental_involvement,
    tutoring_sessions,
    SUM(tutoring_sessions) OVER (
        PARTITION BY parental_involvement
        ORDER BY student_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS tutoring_acumulado
FROM students
ORDER BY parental_involvement, student_id;
```

**Por qué:**
- `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` define el marco desde el inicio hasta la fila actual.
- Sin este marco explícito, algunos motores calculan la suma total del grupo en lugar del acumulado.
- El `PARTITION BY` reinicia el acumulado en cada grupo, esencial para métricas por segmento.

> **Negocio:** Monitorear cómo se acumula el uso de tutorías por perfil familiar a lo largo del tiempo. Permite identificar en qué punto del semestre se concentra la demanda y planificar recursos docentes con anticipación.

---

## PILAR 4 — Optimización Básica

### Regla 1: Nunca uses SELECT *

```sql
-- ANTES: trae todas las columnas, consume más memoria y I/O
SELECT *
FROM students
WHERE school_type = 'Public';

-- DESPUÉS: solo las columnas necesarias
SELECT student_id, exam_score, hours_studied
FROM students
WHERE school_type = 'Public';
```

**Por qué:**
- `SELECT *` transfiere todas las columnas aunque el análisis use solo 3 de 20.
- En motores columnar (BigQuery, Redshift, Snowflake) el costo se cobra por bytes leídos.
- Columnas específicas permiten al motor usar índices y proyecciones optimizadas.

> **Negocio:** En entornos cloud, una query con `SELECT *` sobre una tabla de 10M filas puede costar 10x más que la misma query con columnas específicas. El ahorro es directo y medible en la factura mensual del equipo.

---

### Regla 2: Filtra temprano (Early Filtering)

```sql
-- ANTES: window function opera sobre toda la tabla
SELECT *,
    SUM(tutoring_sessions) OVER (
        PARTITION BY parental_involvement
        ORDER BY student_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS tutoring_acumulado
FROM students;

-- DESPUÉS: WHERE reduce filas antes de que opere la ventana
SELECT
    student_id,
    parental_involvement,
    tutoring_sessions,
    SUM(tutoring_sessions) OVER (
        PARTITION BY parental_involvement
        ORDER BY student_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS tutoring_acumulado
FROM students
WHERE parental_involvement IN ('Low', 'Medium', 'High')
ORDER BY parental_involvement, student_id;
```

**Por qué:**
- Las window functions se ejecutan **después** del `WHERE` — filtrar antes reduce el conjunto que procesa el `OVER()`.
- Menos filas = menos memoria = menos tiempo de cómputo en el motor.
- En pipelines reales este patrón puede reducir el tiempo de ejecución entre un 40% y 70%.

> **Negocio:** Las queries lentas bloquean dashboards y reportes ejecutivos. Filtrar temprano es la diferencia entre un reporte que carga en 2 segundos vs uno que tarda 30. Los stakeholders — y el SLA del equipo — lo notan.

---

### Regla 3: CTEs sobre subqueries anidadas

```sql
-- ANTES: subquery anidada difícil de leer y debuggear
SELECT student_id, exam_score
FROM (
    SELECT student_id, exam_score,
           AVG(exam_score) OVER () AS avg_global
    FROM students
) sub
WHERE exam_score > avg_global;

-- DESPUÉS: CTE legible y mantenible
WITH promedios AS (
    SELECT
        student_id,
        exam_score,
        AVG(exam_score) OVER () AS avg_global
    FROM students
)
SELECT student_id, exam_score
FROM promedios
WHERE exam_score > avg_global;
```

**Por qué:**
- Las CTEs se pueden leer de arriba abajo como un ensayo, sin saltar entre paréntesis.
- Facilitan el debugging: puedes ejecutar solo el bloque `WITH` para validar resultados intermedios.
- El motor las ejecuta una vez y las reutiliza, evitando recálculos innecesarios.

> **Negocio:** Un analista senior puede revisar una query con CTEs en minutos. La misma lógica con subqueries anidadas puede tomar horas de interpretación. La legibilidad es un activo del equipo, no solo del autor.

---

## Orden de Ejecución SQL

```
FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → WINDOW FUNCTIONS → ORDER BY → LIMIT
```

> **Por qué importa en entrevistas:** Explica por qué no puedes usar alias del `SELECT` en el `WHERE`, y por qué los filtros en `WHERE` se aplican antes que las window functions — lo que hace que el early filtering sea efectivo.

---

## Tabla de Referencia Rápida

| Función | Empates | Saltos | Cuándo usarla |
|---|---|---|---|
| `ROW_NUMBER()` | No | N/A | Deduplicar, paginar |
| `RANK()` | Sí | Sí (1,2,2,4) | Competencias con posiciones vacantes |
| `DENSE_RANK()` | Sí | No (1,2,2,3) | Percentiles, niveles continuos |
| `LAG()` | N/A | N/A | Variación vs registro anterior |
| `LEAD()` | N/A | N/A | Brecha vs registro siguiente |
| `SUM() OVER` | N/A | N/A | Acumulados progresivos por grupo |

---

*Generado: Día 9 — Semana 2 | Plan Data Scientist 180 días*  
*Ruta en repo: `docs/cheatsheet.md`*
