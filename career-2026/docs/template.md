Sistema de Predicción de Churn en Tiempo Real

Este sistema implementa un pipeline robusto de nivel industrial para la predicción proactiva de abandono de clientes utilizando XGBoost y FastAPI. La solución integra una arquitectura orientada a la producción que abarca desde la ingeniería de atributos avanzada en SQL hasta el despliegue mediante contenedores, asegurando escalabilidad y una validación estadística rigurosa para impactar directamente en la retención de usuarios de alto valor.

Problema y Necesidad de Negocio

El área de retención ha identificado una erosión constante en la base de usuarios activos, impactando significativamente el Life Time Value (LTV) total. Siguiendo la premisa de "decisiones basadas en datos", el negocio requiere una herramienta que no solo identifique el riesgo de fuga, sino que permita una intervención causal antes de que el evento de churn se materialice.

Objetivo de Negocio

* KPI Primario: Reducción del 5% en la tasa de cancelación (Churn Rate) en el segmento de usuarios High-Value.
* Decisión Específica: Ejecución de un Experimento A/B (Control vs. Tratamiento) donde el grupo de tratamiento recibe cupones de fidelización dinámicos y atención prioritaria de Customer Success basados en el score de riesgo del modelo.
* Hipótesis Principal: Un descenso en la frecuencia_uso y un aumento en la latencia transaccional detectados mediante funciones de ventana en los últimos 90 días son predictores de alta fidelidad para la intención de abandono.

Datos: Fuentes y Limitaciones

La extracción de datos se realiza desde un Data Warehouse corporativo (Snowflake/BigQuery). Para garantizar la corrección de punto en el tiempo (point-in-time correctness) y evitar el sesgo de supervivencia, el procesamiento de features se apoya en SQL avanzado (CTEs y Window Functions).

Diccionario de Datos Críticos

Variable	Descripción	Tipo
id_cliente	Identificador único del usuario (PK)	Alfanumérico
antiguedad_meses	Tiempo total de permanencia calculado mediante DATEDIFF	Numérico (Int)
monto_promedio_trans	Gasto mensual promedio calculado con AVG() OVER	Numérico (Float)
frecuencia_uso	Conteo de sesiones activas en los últimos 30 días (Window Function)	Numérico (Int)
churn_target	Label binario: 1 si canceló en el periodo T+1	Booleano

Limitaciones y Sesgos

* Target Leakage: Se identificó y eliminó la variable status_cuenta_post_facturacion, ya que se actualizaba en el sistema de origen solo después de que el cliente iniciaba el proceso de cancelación.
* Validación Temporal: Se descartó el random shuffle en favor de un Time-Based Split. El modelo se entrena con datos de los meses M1-M10 y se valida con M11-M12 para simular condiciones reales de producción.
* Calidad de Datos: Se detectó un sesgo en la captura de monto_promedio_trans para usuarios registrados antes de 2023 debido a cambios en la arquitectura de microservicios de pagos.

Definición de Éxito (Métricas)

La evaluación del sistema trasciende el rendimiento algorítmico, alineándose con el impacto financiero directo.

1. Métrica Técnica: Optimización de Recall@K (con K=20%). Dado el desbalance de clases, el objetivo es capturar al 80% de los desertores potenciales dentro del top 20% de la población con mayor score de riesgo, superando el baseline de un modelo Random Forest v1.
2. Métrica de Negocio (ROI): El éxito financiero se define mediante la fórmula: Impacto = (Churn_Evitado * LTV_Segmento) - (Costo_Operativo_Cupones + CAPEX_Infraestructura). Se busca un retorno positivo en los primeros 6 meses post-despliegue.

Resultados y Hallazgos Visuales

* Análisis de Error (Placeholder): Visualización de la matriz de confusión y segmentación por antigüedad. El modelo muestra un rendimiento superior en clientes con más de 6 meses de historial, mientras que los "New Joiners" presentan un ruido estadístico mayor debido a la falta de señales en las funciones de ventana (LAG/LEAD).
* Interpretabilidad - SHAP (Placeholder): Gráfico de Summary Plot. La variable frecuencia_uso (calculada vía SQL) es el principal motor de la predicción, confirmando la hipótesis de negocio inicial sobre el compromiso del usuario.
* Comparativa de Experimentos:

Versión	Modelo	Validación	Recall@20%	Estado en MLflow
v1	Random Forest (Baseline)	K-Fold (Random)	0.62	Archivo
v2	XGBoost + SQL Features	Time-Split	0.79	Production (Registry)

Stack Tecnológico (Nivel Industria)

La arquitectura sigue los estándares de "Stack Objetivo 2026", priorizando la reproducibilidad y el ciclo de vida de ML.

* Procesamiento: Python (Pandas/NumPy) y SQL (CTEs y Window Functions para Feature Engineering).
* Modelado: XGBoost con validación de hiperparámetros estructurada.
* MLOps:
  * MLflow: Gestión del Model Registry (Estados: Staging, Production) y tracking de artefactos.
  * FastAPI: Inferencia de baja latencia con validación de tipos vía Pydantic.
  * Docker: Containerización completa para paridad entre entornos.
* CI/CD & Orquestación: GitHub Actions configurado para ejecución de Pytest (unit/data tests), linting y build automático de imagen.

Guía de Reproducibilidad (Cómo Correr)

El proyecto utiliza un enfoque de "un solo comando" para minimizar la fricción operativa.

1. Instalación de dependencias

Se utiliza uv para una gestión de dependencias ultrarrápida y determinista:

# Sincronizar el entorno virtual
uv sync


2. Ejecución del Sistema

El despliegue local incluye la API y el servidor de tracking mediante un archivo Makefile:

# Levanta los servicios definidos en docker-compose
make run


3. Prueba de Inferencia (API)

Consulta al endpoint de predicción utilizando datos validados por el esquema de Pydantic:

curl -X POST "http://localhost:8000/predict" \
     -H "Content-Type: application/json" \
     -d '{"antiguedad_meses": 15, "monto_promedio_trans": 120.50, "frecuencia_uso": 2}'


Riesgos y Próximos Pasos

Como consultor de estrategia de datos, identifico los siguientes puntos críticos para la escalabilidad:

* Riesgos Potenciales:
  * Data Drift: Cambios macroeconómicos que alteren el LTV y el comportamiento de gasto (requiere monitoreo con Evidently/MLflow).
  * Latencia de Features: El cálculo de Window Functions en tiempo real puede impactar la respuesta de la API (considerar un Feature Store).
  * Costos de Infraestructura: El escalado horizontal de contenedores si el tráfico de inferencia crece un 200% mes a mes.
* Siguientes Pasos (Backlog):
  * Implementación de un pipeline de Reentrenamiento Automático disparado por degradación de métricas en producción.
  * Integración de dbt para la capa de transformación de datos y linaje en el Data Warehouse.
  * Desarrollo de un Dashboard en Streamlit para que los stakeholders visualicen el impacto del Experimento A/B en tiempo real.

