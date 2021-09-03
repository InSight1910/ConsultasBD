SELECT
    numrut_cli
    || '-'
    || dvrut_cli 
        AS "RUT CLIENTE",
    nombre_cli
    || ' '
    || appaterno_cli
    || ' '
    || apmaterno_cli
        AS "NOMBRE CLIENTE",
    renta_cli
        AS "RENTA",
    fonofijo_cli
        AS "TELEFONO FIJO",
    celular_cli
        AS "CELULAR"
FROM
    cliente
WHERE
    id_estcivil in (1)
    OR
    (
        id_estcivil IN (3,4)
        AND
        renta_cli >= 800000
    ) 
ORDER BY
    appaterno_cli ASC,
    nombre_cli ASC