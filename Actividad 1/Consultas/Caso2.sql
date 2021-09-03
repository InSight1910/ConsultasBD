SELECT 
    numrut_cli AS "NUMERO RUT", 
    dvrut_cli AS "DIGITO VERIFICADOR", 
    appaterno_cli || ' ' || 
    apmaterno_cli || ' ' ||
    nombre_cli AS "NOMBRE CLIENTE", 
    renta_cli AS "RENTA", 
    fonofijo_cli AS "TELEFONO FIJO", 
    celular_cli AS "CELULAR" 
FROM 
    cliente
ORDER BY 
    appaterno_cli ASC,
    apmaterno_cli ASC