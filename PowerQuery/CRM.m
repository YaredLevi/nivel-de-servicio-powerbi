let
    Origen = Sql.Database("srv-wtw-prod", "BenefitEngineDB", 
        [Query = "
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
        "]),
    #"Reemplazos Compañía" = List.Accumulate(
        {
            {"VIDA CAMARA", "Vida Camara"},
            {"EUROAMERICA", "EuroAmerica"},
            {"Euroamerica", "EuroAmerica"},
            {"ZURICH",      "Zurich"},
            {"SURA",        "Sura"},
            {"METLIFE",     "MetLife"},
            {"SECURITY",    "Vida Security"},
            {"CONSORCIO",   "Consorcio"},
            {"consorcio",   "Consorcio"},
            {"BICE VIDA",   "Bice Vida"},
            {"HELP",        "Help Seguros"},
            {"CHUBB",       "Chubb Seguros"},
            {"MAPFRE",      "Mapfre"}
        },
        Origen,
        (tabla, par) => Table.ReplaceValue(tabla, par{0}, par{1}, Replacer.ReplaceText, {"Compañía de Seguros"})
    ),
    #"Valor reemplazado" = Table.ReplaceValue(#"Reemplazos Compañía","Prorroga_1","Prorroga",Replacer.ReplaceText,{"Subtipo"}),
    #"+ Col Pais" = Table.AddColumn(#"Valor reemplazado", "Pais",
        each if Text.Contains([Asignado a], "Santiago") then "Chile"
        else if Text.Contains([Asignado a], "Medellin") then "Colombia"
        else null),
    #"Asignado a Limpio" = Table.TransformColumns(#"+ Col Pais", {{"Asignado a", each
        try
            let
                sinParentesis = Text.Trim(Text.BeforeDelimiter(_, "(")),
                partes        = Text.Split(sinParentesis, ","),
                apellido      = Text.Trim(partes{0}),
                nombre        = Text.Trim(partes{1})
            in
                nombre & " " & apellido
        otherwise _
    , type text}}),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Asignado a Limpio",{
        {"Fecha de creación",                 type date},
        {"Fecha y Hora Hora de finalización", type date},
        {"Fecha de vencimiento",              type date}
    }),
    #"Mayus Resumen" = Table.TransformColumns(#"Tipo cambiado", {{"Resumen", each
        Text.Upper(Text.Start(_, 1)) & Text.Lower(Text.Middle(_, 1, Text.Length(_) - 1)),
        type text}}),
    #"Mayus Cliente" = Table.TransformColumns(#"Mayus Resumen",{{"Cliente", Text.Proper, type text}}),
    #"+ Col Estado SLA" = Table.AddColumn(#"Mayus Cliente", "Estado SLA",
        each if Text.Contains([Tiempo restante], "-") then "Fuera de SLA" else "Dentro de SLA"),
    #"Valor reemplazado1" = Table.ReplaceValue(#"+ Col Estado SLA","Mail","Email",Replacer.ReplaceText,{"Canal de Solicitud"}),
    #"Valor reemplazado2" = Table.ReplaceValue(#"Valor reemplazado1","Llamado Telefonico","Llamado Telefónico",Replacer.ReplaceText,{"Canal de Solicitud"}),
    #"Renombrar Asignado a" = Table.RenameColumns(#"Valor reemplazado2",{{"Asignado a", "Ejecutivo"}}),
    #"Filas filtradas" = Table.SelectRows(#"Renombrar Asignado a", each Date.IsInCurrentYear([Fecha de creación]))
in
    #"Filas filtradas"
