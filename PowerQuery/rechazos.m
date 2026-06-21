let
    Origen = SharePoint.Files("https://wtwonline-my.sharepoint.com/personal/yared_ordenes_towerswatson_com", [ApiVersion = 15]),
    #"Filas filtradas" = Table.SelectRows(Origen, each ([Name] = "rechazos.xlsx")),
    #"rechazos xlsx" = #"Filas filtradas"{[
        Name           = "rechazos.xlsx",
        #"Folder Path" = "https://wtwonline-my.sharepoint.com/personal/yared_ordenes_towerswatson_com/Documents/Documentos/Aguas Andinas reporte/"
    ]}[Content],
    #"Libro de Excel importado" = Excel.Workbook(#"rechazos xlsx"),
    Rechazos_Sheet = #"Libro de Excel importado"{[Item="Rechazos",Kind="Sheet"]}[Data],
    #"Encabezados promovidos" = Table.PromoteHeaders(Rechazos_Sheet, [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{
        {"refund_id",          Int64.Type},
        {"Nro#(tab)Plan",      Int64.Type},
        {"Rut beneficiario",   type text},
        {"Beneficiario",       type text},
        {"Rut titular",        type text},
        {"Fecha solicitud",    type date},
        {"Fecha de prestacion",type date},
        {"Tipo comunicacion",  type text},
        {"Email",              type text},
        {"Celular",            type text},
        {"Estado",             type text},
        {"Nro Liquidacion",    Int64.Type},
        {"Monto Solicitado",   type text},
        {"Monto Pagado",       type text},
        {"Motivo",             type text},
        {"Categoria Motivo",   type text},
        {"Proceso de carga",   type text},
        {"Fecha de pago",      type date},
        {"Doc. Tributario",    type text},
        {"Documento repetido", type text},
        {"Con seguro",         type text}
    }),
    #"Beneficiario capitalizado" = Table.TransformColumns(#"Tipo cambiado", {
        {"Beneficiario", Text.Proper, type text}
    }),
    #"Columna condicional agregada" = Table.AddColumn(#"Beneficiario capitalizado", "Canal momentaneo",
        each if [Tipo comunicacion] = "Email"    then "Email"
        else if [Tipo comunicacion] = "Whatsapp" then "Whatsapp"
        else "Sin información")
in
    #"Columna condicional agregada"
