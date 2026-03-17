# 🚀 Data Science & Applied ML: Road to Industry 2026

Este repositorio documenta mi proceso intensivo de **6 meses (24 semanas)** para construir un perfil Job-Ready en Ciencia de Datos aplicado a industria.

El objetivo no es acumular certificados, sino demostrar capacidad real para llevar modelos y análisis **desde exploración hasta producción**.

> **Regla de Oro:** Portafolio > Certificados.

---

## 🛠 Tech Stack

**Lenguajes**

* Python
* SQL (PostgreSQL / DuckDB)

**Machine Learning**

* Scikit-learn
* XGBoost
* LightGBM
* SHAP

**Producción / MLOps**

* FastAPI
* Docker
* MLflow
* GitHub Actions (CI/CD)

**GenAI**

* RAG con LlamaIndex / LangChain
* Evaluación de Retrieval (Precision & Recall)

**Analytics**

* dbt
* Power BI / Looker
* Análisis de KPIs de Negocio

---

## 📂 Estructura del Proyecto

El repositorio sigue una organización similar a la utilizada en equipos de datos profesionales:

```text
├── data/               # Datasets (muestras o links a fuentes)
├── docs/               # Case Studies (1-2 páginas por proyecto)
├── notebooks/          # Exploración y prototipado limpio (EDA)
├── notes/              # SQL Cheatsheets y notas de estadística
├── src/                # Código modular (entrenamiento y serving)
├── tests/              # Pruebas unitarias y data checks
├── .github/workflows/  # Pipelines de CI/CD
└── requirements.txt    # Dependencias reproducibles
```

---

## 🏆 Portafolio: Proyectos End-to-End

### 1️⃣ ML en Producción (MLOps)

**Problema:** Dataset tabular con validación temporal y feature engineering real.

**Solución:**

* Pipeline reproducible con MLflow
* Modelo entrenado con XGBoost / LightGBM
* API desplegada con FastAPI
* Contenerización con Docker

**Evidencia:**

* CI/CD funcional
* Tests automatizados
* Monitoreo básico de drift

---

### 2️⃣ Analytics & Decisiones de Negocio

**Problema:** Traducir métricas de negocio en hipótesis medibles.

**Solución:**

* Análisis de cohortes
* Segmentación
* Simulación de experimentos (A/B testing)

**Entregables:**

* Dashboard interactivo
* Memo ejecutivo con recomendaciones accionables

---

### 3️⃣ Aplicación GenAI (RAG)

**Problema:** Chat con documentos corporativos con trazabilidad de fuentes.

**Solución:**

* Pipeline RAG: Chunking → Embeddings → Vector DB
* Evaluación de retrieval (precision & recall)
* Medición de latencia

**Diferenciador:**

* Interfaz funcional
* Reporte de exactitud de citas

---

## 🗓️ Roadmap de 24 Semanas

**Mes 1:**

* SQL avanzado (Window Functions, CTEs, Optimization)
* Estadística aplicada

**Mes 2:**

* Feature Engineering
* Modelos de industria (XGBoost, LightGBM)
* Interpretabilidad con SHAP

**Mes 3:**

* FastAPI
* Docker
* MLflow
* CI/CD con GitHub Actions

**Mes 4:**

* Proyecto de negocio real
* KPIs y dashboarding

**Mes 5:**

* Especialización en GenAI / RAG
* Evaluación de Retrieval

**Mes 6:**

* Preparación laboral
* Optimización de CV
* Aplicaciones estratégicas

---

## ⚙️ Configuración del Entorno

Ejemplo con entorno virtual:

```bash
python -m venv env
source env/bin/activate
pip install -r requirements.txt
```

---

**Contacto:** https://www.linkedin.com/in/andres-lemus-7943882a9/

---

## 📊 Mini-Reto Semana 1 — Análisis de Rendimiento Estudiantil (SQL)

### 🧩 Problema

Las instituciones educativas necesitan entender qué factores influyen más en el rendimiento académico de sus estudiantes para tomar decisiones informadas sobre recursos, programas de apoyo y políticas internas.

Este mini-reto responde **7 preguntas de negocio clave** usando SQL puro sobre un dataset real de rendimiento estudiantil, con el objetivo de detectar desigualdad educativa, justificar inversión en infraestructura y focalizar apoyos académicos.

### 📁 Datos

**Dataset:** `student_performance`
**Archivo SQL:** `notes/sql/day_05_student_performance_queries.sql`
**Notebook:** `notebooks/05_caso_de_estudio_sql.ipynb`

| Variable | Descripción |
|---|---|
| `Exam_Score` | Puntaje final del examen (variable objetivo) |
| `Access_to_Resources` | Nivel de acceso a recursos educativos (High / Medium / Low) |
| `Internet_Access` | Acceso a internet (Yes / No) |
| `Hours_Studied` | Horas de estudio semanales |
| `Parental_Involvement` | Nivel de apoyo parental (High / Medium / Low) |
| `Attendance` | Porcentaje de asistencia a clases |
| `Sleep_Hours` | Horas de sueño por noche |
| `Tutoring_Sessions` | Número de sesiones de tutoría por mes |

### 🧩 Preguntas de Negocio

| # | Pregunta |
|---|---|
| 1 | ¿Existe diferencia en el rendimiento entre estudiantes con altos vs bajos recursos académicos y acceso a internet? |
| 2 | ¿Cuánto influye la cantidad de horas de estudio en el puntaje del examen? |
| 3 | ¿El nivel de apoyo de los padres influye en el puntaje promedio? |
| 4 | ¿Existe diferencia significativa en el puntaje entre estudiantes con y sin acceso a internet? |
| 5 | ¿Cómo afecta el nivel de asistencia a clases al puntaje promedio? |
| 6 | ¿Dormir más horas se relaciona con un mejor desempeño académico? |
| 7 | ¿Los estudiantes que asisten a más sesiones de tutoría obtienen mejores puntajes? |

### 🧠 Hallazgos Clave

#### P1 — Brecha Digital y de Recursos Académicos

```sql
SELECT Access_to_Resources, Internet_Access,
    COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
WHERE Access_to_Resources IN ('High', 'Low') AND Internet_Access IN ('Yes', 'No')
GROUP BY Access_to_Resources, Internet_Access
ORDER BY avg_exam_score DESC;
```

| Recursos | Internet | Promedio |
|---|---|---|
| High | Yes | **68.19** |
| High | No | 66.99 |
| Low | Yes | 66.29 |
| Low | No | 65.06 |

> Existe una brecha académica asociada tanto al acceso a recursos como a conectividad digital. Identifiqué que los estudiantes con limitaciones en ambos factores presentan el rendimiento más bajo, lo que permite priorizar inversión en colegios vulnerables y justificar programas de acceso a internet, medido por una brecha de **3.1 puntos** entre el grupo más favorecido y el más vulnerable.



---

#### P2 — Impacto de las Horas de Estudio

```sql
SELECT
    CASE WHEN Hours_Studied < 10 THEN 'Bajo'
         WHEN Hours_Studied < 20 THEN 'Medio'
         ELSE 'Alto' END AS study_level,
    COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
GROUP BY study_level ORDER BY avg_exam_score DESC;
```

| Nivel de Estudio | Promedio |
|---|---|
| Alto (≥20h) | **68.49** |
| Medio (10–19h) | 65.99 |
| Bajo (<10h) | 63.82 |

> Se construyó una segmentación por horas de estudio que reveló una diferencia de **~4.7 puntos** entre el nivel Alto y Bajo, permitiendo identificar hábitos efectivos y orientar planes de refuerzo académico personalizados. ⚠️ El grupo "Bajo" es de menor tamaño, por lo que las comparaciones deben interpretarse con cautela.



---

#### P3 — Influencia del Apoyo Parental

```sql
SELECT Parental_Involvement, COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
GROUP BY Parental_Involvement ORDER BY avg_exam_score DESC;
```

| Apoyo Parental | Estudiantes | Promedio |
|---|---|---|
| High | 1,908 | **68.09** |
| Medium | 3,362 | 67.10 |
| Low | 1,337 | 66.36 |

> Existe una relación positiva leve (~1.7 pts entre nivel Alto y Bajo). El apoyo parental tiene una influencia moderada pero consistente, lo que sustenta el diseño de programas de orientación familiar en instituciones educativas.



---

#### P4 — Influencia del Acceso a Internet

```sql
SELECT Internet_Access, COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
GROUP BY Internet_Access ORDER BY avg_exam_score DESC;
```

> Los estudiantes con acceso a internet presentan un puntaje promedio ligeramente superior. Sin embargo, el internet por sí solo no garantiza mejor desempeño — su impacto depende de factores complementarios como hábitos de estudio y acompañamiento docente. Hay una fuerte desproporción en el tamaño de los grupos que limita conclusiones definitivas.



---

#### P5 — Impacto de la Asistencia a Clases

```sql
SELECT
    CASE WHEN Attendance < 60 THEN 'Baja'
         WHEN Attendance < 85 THEN 'Media'
         ELSE 'Alta' END AS attendance_level,
    COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
GROUP BY attendance_level ORDER BY avg_exam_score DESC;
```

> Se observó una relación directa y significativa entre asistencia y rendimiento. Identifiqué que los estudiantes con alta asistencia logran mejores puntajes promedio, lo que permite justificar políticas contra el ausentismo y detectar tempranamente estudiantes en riesgo académico.



---

#### P6 — Influencia de las Horas de Sueño *(hallazgo sorprendente)*

```sql
SELECT
    CASE WHEN Sleep_Hours < 6 THEN 'Pocas'
         WHEN Sleep_Hours < 8 THEN 'Adecuadas'
         ELSE 'Óptimas' END AS sleep_level,
    COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
GROUP BY sleep_level ORDER BY avg_exam_score DESC;
```

| Sueño | Promedio |
|---|---|
| Pocas (<6h) | 67.40 |
| Adecuadas (6–7h) | 67.22 |
| Óptimas (≥8h) | 67.19 |

> 🔍 **Hallazgo contraintuitivo:** Contrario a lo esperado, las horas de sueño no presentan diferencia significativa en el rendimiento (variación < 0.3 pts). Esto sugiere que otros factores académicos tienen mayor influencia en el puntaje final, y que el sueño podría actuar más como variable de bienestar que de rendimiento directo.



---

#### P7 — Impacto de las Tutorías Académicas

```sql
SELECT Tutoring_Sessions, COUNT(*) AS total_students,
    ROUND(AVG(Exam_Score), 2) AS avg_exam_score
FROM student_performance
GROUP BY Tutoring_Sessions ORDER BY avg_exam_score DESC;
```

> Se observó una relación positiva entre cantidad de tutorías y rendimiento. Las tutorías muestran ser una estrategia efectiva: ampliar su cobertura para estudiantes con bajo desempeño inicial puede elevar el promedio general institucional. Los niveles extremos de tutorías tienen pocos estudiantes y deben interpretarse con cautela.



---

### 📊 Resumen de Factores por Impacto

| Factor | Diferencia observada | Impacto |
|---|---|---|
| Horas de estudio | ~4.7 pts | 🔴 Alto |
| Asistencia a clases | Significativa | 🔴 Alto |
| Brecha digital (recursos + internet) | 3.1 pts | 🔴 Alto |
| Tutorías académicas | Positivo y creciente | 🟡 Moderado |
| Apoyo parental | ~1.7 pts | 🟡 Moderado |
| Acceso a internet (aislado) | Leve | 🟢 Bajo |
| Horas de sueño | < 0.3 pts | 🟢 Bajo |

### ⚠️ Limitaciones

* El dataset no incluye variables socioeconómicas detalladas (ingreso familiar, zona geográfica)
* Algunos grupos tienen tamaños desproporcionados que pueden sesgar comparaciones directas
* Las relaciones observadas son correlacionales — no implican causalidad

### 🚀 Próximos Pasos

* Implementar modelos predictivos (ML) sobre `Exam_Score` usando las variables identificadas
* Aplicar análisis SHAP para cuantificar la contribución real de cada factor
* Evaluar interacciones entre variables (ej. horas de estudio × acceso a recursos)

### ▶️ Cómo Reproducir

```bash
# Opción 1 — SQL directo
SOURCE day_06_minireto.sql;

# Opción 2 — Notebook
jupyter 06_minireto_sql.ipynb
```