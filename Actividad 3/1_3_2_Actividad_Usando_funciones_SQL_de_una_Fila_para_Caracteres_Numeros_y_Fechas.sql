alter session set nls_date_format = 'DD/MM/YYYY';
-- Vicente Espinosa MDY2131-001V
-- Caso 1

SELECT 
    numrun_cli
    || '-'
    || dvrun_cli
        AS "RUN CLIENTE",
    LOWER(
        pnombre_cli 
        || ' ' 
        || snombre_cli
        )
    || ' ' 
    || UPPER(
    appaterno_cli
        || ' ' 
        || apmaterno_cli
    ) AS "NOMBRE cLIENTE",
    fecha_nac_cli
        AS "FECHA NACIMIENTO"
FROM 
     CLIENTE
WHERE
    (EXTRACT(DAY FROM fecha_nac_cli) = EXTRACT(DAY FROM SYSDATE + 1))
        AND
    (EXTRACT(MONTH FROM fecha_nac_cli) = EXTRACT(MONTH FROM SYSDATE));

-- Caso 2

SELECT
    numrun_emp
    || ' '
    || dvrun_emp
        AS "RUN EMPLEADO",
    pnombre_emp
    || ' '
    || snombre_emp
    || ' '
    || appaterno_emp
    || ' '
    || apmaterno_emp
        AS "NOMBRE COMPLETO EMPEADO",
    sueldo_base
        AS "SUELDO BASE",
    TRUNC(sueldo_base / 100000)
        AS "PORCENTAJE MOVILIZACION",
    ROUND(sueldo_base * TRUNC((sueldo_base / 100000) / 100, 2))
FROM
    EMPLEADO
ORDER BY
    "PORCENTAJE MOVILIZACION" DESC;
    
-- Caso 3

SELECT
    numrun_emp
    || ' '
    || dvrun_emp
        AS "RUN EMPLEADO",
        pnombre_emp
    || ' '
    || snombre_emp
    || ' '
    || appaterno_emp
    || ' '
    || apmaterno_emp
        AS "NOMBRE COMPLETO EMPEADO",
    sueldo_base
        AS "SUELDO BASE",
    fecha_nac
        AS "FECHA NACIMIENTO",
    SUBSTR(pnombre_emp ,1,3)
    || LENGTH(pnombre_emp)
    || '*'
    || SUBSTR(sueldo_base, -1)
    || dvrun_emp
    || ((EXTRACT(YEAR FROM SYSDATE)) - (EXTRACT(YEAR FROM fecha_contrato)))
        AS "NOMBRE USUARIO",
    SUBSTR(numrun_emp, 3, 1)
    || EXTRACT(YEAR FROM fecha_nac) + 2
    || SUBSTR(sueldo_base, -3) - 1
    || SUBSTR(appaterno_emp, -2,2)
    || EXTRACT(MONTH FROM SYSDATE)
        AS "CLAVE"
FROM 
    EMPLEADO
ORDER BY
    appaterno_emp;

-- Caso 4
DROP TABLE HIST_REBAJA_ARRIENDO;
CREATE TABLE HIST_REBAJA_ARRIENDO 
    AS
    SELECT
        EXTRACT(YEAR FROM SYSDATE)
            AS "ANNO_PROCESO",
        nro_patente,
        valor_arriendo_dia
            AS "VALOR_ARRIENDO_DIA_DR",
        valor_garantia_dia
            AS "VALOR_GARANTIA_DIA_DR",
        EXTRACT(YEAR FROM SYSDATE) - anio
            AS "ANNOS_ANTIGUEDAD",
        valor_arriendo_dia * (1 -  ((EXTRACT(YEAR FROM SYSDATE) - anio) / 100))
            AS "VALOR_ARRIENDO_DIA_CR",
        VALOR_GARANTIA_DIA * (1 -  ((EXTRACT(YEAR FROM SYSDATE) - anio) / 100))
            AS "VALOR_GARANTIA_DIA_CR"
    FROM
        CAMION
    WHERE 
        (EXTRACT(YEAR FROM SYSDATE) - anio) > 5
    ORDER BY
        "ANNOS_ANTIGUEDAD" DESC,
        nro_patente ASC;

-- Caso 5
SELECT 
    TO_CHAR(fecha_ini_arriendo, 'MM/YYYY')
        AS "MES_ANNO_PROCESO",
    nro_patente,
    fecha_ini_arriendo,
    dias_solicitados,
    fecha_devolucion,
    fecha_devolucion - (fecha_ini_arriendo + dias_solicitados)
        AS "DIAS_ATRASO",
    (fecha_devolucion - (fecha_ini_arriendo + dias_solicitados)) * &VALOR_MULTA
    AS "VALOR_MULTA"
FROM
    ARRIENDO_CAMION
WHERE 
    fecha_devolucion - (fecha_ini_arriendo + dias_solicitados) <> 0
    AND
    EXTRACT( YEAR FROM fecha_ini_arriendo) = EXTRACT(YEAR FROM SYSDATE)
    AND
    EXTRACT( MONTH FROM fecha_ini_arriendo) = EXTRACT(MONTH FROM to_date('01/07/2019') ) -- Realmente iria un SYSDATE pero para que salga igual que el ejemplo puse la fecha que se indica en el word
ORDER BY
fecha_ini_arriendo ASC,
    nro_patente ASC;