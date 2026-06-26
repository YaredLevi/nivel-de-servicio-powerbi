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