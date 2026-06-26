# 📊 Seguimiento Nivel de Servicio de Ejecutivas — Power BI/DAX/Power Query(M)/SQL/Excel

Dashboard de gestión operativa desarrollado para una correduría de seguros, orientado a monitorear el cumplimiento del acuerdo de nivel de servicio (SLA), analizar rechazos de la aseguradora e identificar la carga laboral por ejecutiva.

---

## ❗ El problema

Willis Top Wilson no contaba con una forma estructurada de demostrarle a su cliente corporativo que el acuerdo de servicio pactado se estaba cumpliendo. El seguimiento del SLA y los rechazos se realizaba de forma manual, sin visibilidad consolidada ni periodicidad definida.

Esto representaba un riesgo directo para la retención del cliente: sin evidencia concreta del rendimiento operativo, cualquier percepción negativa del servicio podía derivar en la pérdida de un cliente importante.

Este dashboard convirtió datos operativos dispersos en un reporte periódico compartible con el cliente, con métricas claras de cumplimiento, análisis de rechazos y distribución de carga por ejecutiva.

---

## 🏢 Contexto de negocio

Willis Top Wilson (WTW) es una correduría de seguros que actúa como intermediaria entre sus clientes corporativos y las aseguradoras. En este caso, el cliente es Aguas Andes, empresa con una gran dotación de empleados que cuentan con un seguro complementario de salud contratado con Euro América.

WTW designó dos ejecutivas para gestionar todas las solicitudes, reembolsos y consultas de los empleados de Aguas Andes con su aseguradora. Para demostrarle al cliente que el acuerdo de servicio pactado se está cumpliendo — y así retener al Cliente de WTW — se requería un reporte periódico con evidencia concreta del rendimiento operativo.

Este dashboard es la solución a esa necesidad.

---

## 🗄️ Fuentes de datos

El reporte integra dos fuentes de datos de distinto origen:

| Fuente                     | Descripción                                                  | Conexión                |
| -------------------------- | ------------------------------------------------------------ | ----------------------- |
| **Casos (CRM)**            | CRM interno de WTW con backend SQL. Contiene el registro de todos los casos gestionados: tipo, estado, fechas, canal de atención y ejecutiva responsable. Los datos se extraen mediante una query SQL que cruza la tabla `casos` con la tabla `ejecutivos` vía JOIN por RUT. | SQL → Power BI          |
| **Rechazos (Aseguradora)** | Reporte de rechazos que entrega mensualmente la aseguradora con el detalle de cada caso rechazado: beneficiario, motivo, monto y canal. | SFTP → Excel → Power BI |

**Query de extracción — Benefit Engine**

```sql
SELECT
    c.id_caso           AS [Caso No],
    c.resumen           AS [Resumen],
    c.estado            AS [Estado],
    c.cliente           AS [Cliente],
    c.subtipo           AS [Subtipo],
    e.nombre            AS [Asignado a],
    c.tipo_solicitud    AS [Tipo de solicitud],
    c.canal_solicitud   AS [Canal de solicitud],
    c.fecha_creacion    AS [Fecha de creación],
    c.fecha_cierre      AS [Fecha y Hora Hora de finalización],
    c.fecha_vencimiento AS [Fecha de vencimiento],
    c.tiempo_restante   AS [Tiempo restante],
    c.compania_seguro   AS [Compañía de Seguros]
FROM casos c
INNER JOIN ejecutivos e ON c.rut_ejecutivo = e.rut
```

Ambas fuentes son transformadas y consolidadas en Power Query (M) antes de alimentar el modelo semántico. Los scripts están disponibles en la carpeta [`PowerQuery/`](PowerQuery/).

---

## 🔧 Transformación y modelo semántico

En Power Query se realizaron procesos de limpieza, normalización de columnas, homologación de categorías entre fuentes y creación de una tabla de fechas personalizada para soportar análisis temporales.

El modelo semántico está construido bajo un esquema estrella, con relaciones entre la tabla de hechos principal y las dimensiones de ejecutiva, fecha, subtipo de caso y canal de atención.

**Medidas DAX destacadas:**

- `% Cumplimiento SLA` — casos dentro de SLA sobre total de casos gestionados
- `Brecha SLA` — diferencia entre el cumplimiento real y la meta estimada
- `Meta SLA (Estimada)` — objetivo dinámico calculado según acuerdo
- `Media Cumplimiento SLA` — promedio mensual del cumplimiento
- `Desv Cumplimiento SLA` — desviación estándar para detectar variabilidad
- `Monto Rechazado Total` — suma del dinero rechazado por la aseguradora
- `Beneficiarios Únicos` — conteo distinto de empleados afectados por rechazos

---

## 📋 Páginas del reporte

### 1. Casos Gestionados por Ejecutiva

<div style="display:flex; gap:16px; align-items:flex-start;">
  <img src="Screenshot/PAGINA 1 - CANAL.png" alt="Página 1 - Canal" width="49%">
  <img src="Screenshot/PAGINA 1 - SUBTIPO.png" alt="Página 1 - Subtipo" width="49%">
</div>

Monitoreo de la carga operativa mensual del equipo.

- Tarjeta KPI: total de casos gestionados (1.237)
- Filtros interactivos: por ejecutiva y por subtipo de caso
- Gráfico de dona: distribución de casos entre Catalina Contreras (51,5%) y Claudia Sil (48,5%), mostrando una carga equilibrada
- Línea de tendencia mensual: peak en febrero con 613 casos, caída progresiva hacia abril con 39 casos
- Botones dinámicos superpuestos:
  - **Casos por Subtipo / Casos por Canal** — cambian la visualización inferior sin cambiar de hoja
  - **Mostrar / Ocultar Tablero de Subtipos** — despliega una tabla de detalle superpuesta sobre el gráfico de líneas
- Subtipos: Solicitud de asesoría, Seguimiento de movimientos, Reembolso ambulatorio, dental y hospitalario
- Canales: Email, Llamado telefónico, Presencial, WhatsApp

### 2. Rechazos Mensual

<div style="display:flex; gap:16px; align-items:flex-start;">
  <img src="Screenshot/PAGINA 2.png" alt="Página 1 - Canal" width="49%">
</div>

Análisis de los rechazos que sufren los empleados de Aguas Andes por parte de Euro América.

- KPIs: **661** casos rechazados · **$135M** monto total rechazado · **452** beneficiarios únicos afectados
- Filtros: canal de comunicación, categoría de motivo, mes
- Barras horizontales por motivo:
  - Documento incompleto: 260 casos *(principal causa)*
  - Gasto reembolsado con anterioridad: 190 casos
  - Solicitud reembolso ISAPRE: 83 casos
  - Producto no cubierto por el seguro: 40 casos
  - Gastos anteriores al inicio de vigencia: 33 casos
  - Gastos fuera de plazo: 30 casos
- Línea de tendencia mensual: 329 rechazos en enero → 332 en febrero
- Torta por canal: 64,15% sin información de canal registrada
- Tabla de beneficiarios: detalle individual con RUT censurado, monto rechazado y total de rechazos

> 💡 **Insight:** el motivo "documento incompleto" concentra el 39% de los rechazos. Con una campaña informativa dirigida a los empleados se puede reducir significativamente ese número.

### 3. SLA — Nivel de Servicio

<div style="display:flex; gap:16px; align-items:flex-start;">
  <img src="Screenshot/PAGINA 3.png" alt="Página 1 - Canal" width="49%">
</div>

El corazón del reporte. Esta hoja es la que WTW comparte directamente con Aguas Andes como evidencia del cumplimiento del acuerdo de servicio.

- KPIs principales: Casos gestionados: **1.237** · Dentro SLA: **1.149** · Fuera SLA: **88** · Cumplimiento: **92,9%** · Meta: **94,1%** · Brecha: **-1,2%**
- Barras por ejecutiva:
  - Catalina Contreras: **97,6%** ✅ supera la meta
  - Claudia Sil: **87,8%** ⚠️ bajo la meta
- Dona: 92,89% dentro de SLA vs 7,11% fuera
- Tendencia mensual: Enero 91,3% → Febrero 96,9% → Marzo 84,1% ← caída crítica → Abril 100% ← recuperación total
- Estadísticas: Media 90,8% · Desviación estándar 5,26%

> 💡 La caída de marzo a 84,1% y la recuperación inmediata a 100% en abril son el tipo de dato que justifica la existencia de este reporte: permite detectar anomalías, investigar sus causas y demostrar capacidad de corrección.

---

## 🛠️ Stack técnico

| Herramienta             | Uso                                                          |
| ----------------------- | ------------------------------------------------------------ |
| **Power BI Desktop**    | Diseño de reportes, visualizaciones e interactividad         |
| **SQL**                 | Extracción y cruce de datos desde el CRM Benefit Engine      |
| **DAX**                 | Medidas calculadas: SLA, brecha, media, desviación, montos   |
| **Power Query (M)**     | ETL: limpieza, transformación e integración de fuentes       |
| **Modelo semántico**    | Esquema estrella con tabla de fechas y relaciones definidas  |
| **Bookmarks + Botones** | Navegación dinámica y vistas superpuestas sin cambio de hoja |

---


**Yared Levi Órdenes Vásquez**  
Ingeniero en Informática · BI Developer  
📎 [LinkedIn](https://www.linkedin.com/in/yaredlevi)  
💻 [GitHub](https://github.com/yaredlevi)
