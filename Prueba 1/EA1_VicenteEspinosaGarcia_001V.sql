-- Caso 1

SELECT
    TO_CHAR(fech_incorporacion, 'DD/MM/YY')
        AS "FECHA DE INCORPORACION",
    INITCAP(
        nom_empleado
        || ' '
        || a_paterno
    )
        AS "NOMBRE COMPLETO",
    TO_CHAR(fechnac_empleado, 'DD/MM/YY')
        AS "FECHA DE NACIMIENTO",
    EXTRACT(YEAR FROM fechnac_empleado)
        AS "AÑO DE NACIMIENTO",
    'EL CUMPLEAÑOS DEL EMPLEADO ES EL ' ||
    EXTRACT(DAY FROM fechnac_empleado) ||
    ' del ' ||
    EXTRACT(MONTH FROM fechnac_empleado) ||
    ' de ' ||
    EXTRACT(YEAR FROM fechnac_empleado)
        AS "CUMPLEAÑOS",
    salario
        AS "SALARIO SIN AUMENTO",
    CASE
        WHEN salario < 350000 THEN
            salario * 1.3
        WHEN salario BETWEEN 350000 AND 400000 THEN
            salario * 1.2
        WHEN salario BETWEEN 400001 AND 500000 THEN
            salario * 1.1
        ELSE
            salario * 1.05
    END AS "SALARIO CON AUMENTO"
FROM
    empleado
ORDER BY
    "AÑO DE NACIMIENTO" DESC;
    
-- Caso 2

SELECT
    TRUNC(MONTHS_BETWEEN(
        SYSDATE,
        fech_incorporacion
        
    ) / 12)
        AS "AÑOS DE ANTIGUEDAD",
    INITCAP(
        nom_empleado
        || ' '
        || a_paterno
    )
        AS "NOMBRE COMPLETO",
    TRUNC(MONTHS_BETWEEN(
        SYSDATE,
        fechnac_empleado
    ) / 12)
        AS "EDAD",
    salario,
    CASE
        WHEN sexo = 'F' THEN
            'FEMENINO'
        WHEN sexo = 'M' THEN
            'MASCULINO'
    END AS "SEXO",
    TO_CHAR(ROUND(salario / 6, 2), 'L999G999D99')
        AS "SALARIO DIVIDIDO EN 6 FORMATO 1",
    TO_CHAR(ROUND(salario / 6), 'L999G999')
        AS "SALARIO DIVIDIDO EN 6 FORMATO 2"
FROM
    empleado
WHERE
    INITCAP(a_paterno)LIKE 'M%'
ORDER BY
    fechnac_empleado;

-- Caso 3
SELECT
    TO_CHAR(fech_incorporacion, 'DD/MM/YY')
        AS "FECHA DE INCORPORACION",
    INITCAP(
        nom_empleado
        || ' '
        || a_paterno
    ) AS "NOMBRE COMPLETO",
    TO_CHAR(fechnac_empleado, 'DD/MM/YY')
        AS "FECHA DE NACIMIENTO",
    LOWER(SUBSTR(a_paterno, 1, 3) ||
    '_' ||
    SUBSTR(cod_empleado, 1, 3) ||
    EXTRACT(MONTH FROM fechnac_empleado) ||
    '@labo.cl')
        AS "CORREO",
    UPPER(
        SUBSTR(direccion, 1, 1)
    ) ||
    LOWER(
        SUBSTR(
            nom_empleado,
            -2,
            2
        ) ||
        SUBSTR(
            cod_empleado,
            1,
            3
        )
    )
        AS "CONTRASEÑA TEMPORAL",
    cod_sucursal
        AS "CODIGO SUCURSAL"
FROM 
    empleado
WHERE 
    cod_sucursal IN(54, 52, 50)
ORDER BY
    cod_empleado ASC,
    direccion DESC;
    
-- Caso 4

SELECT
    cod_medicamento
        AS "CODIGO MEDICAMENTO",
    nombre_medicamento
        AS "NOMBRE MEDICAMENTO",
    INITCAP(laboratorio)
        AS "LABORATORIO",
    precio_medicamento
        AS "PRECIO",
    CASE
        WHEN laboratorio LIKE '%Bayer' THEN
            TO_CHAR(precio_medicamento * 1.2, 'L99G999D99')
        WHEN laboratorio LIKE '%Chile' THEN
            TO_CHAR(precio_medicamento * 1.15, 'L99G999D99')
    END AS "PRECIO NUEVO"
FROM
    medicamento
WHERE
    laboratorio LIKE '%' || &laboratorio
ORDER BY
    "PRECIO NUEVO" DESC,
    nombre_medicamento ASC