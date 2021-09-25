SELECT
    TO_CHAR(numrun_cli,'09G999G999')|| '-' || dvrun_cli AS "RUN EMPLEADO",
    INITCAP(appaterno_cli
    || ' '
    || substr(apmaterno_cli, 1,1) || '.'
    || ' '
    || pnombre_cli) AS "NOMBRE CLIENTE",
    direccion,
    NVL(to_char(fono_fijo_cli), 'NO POSEE TELEFONO FIJO')
        AS "TELEFONO FIJO",
    NVL(to_char(celular_cli), 'NO POSEE CELULAR')
        AS "CELULAR",
    id_comuna
        AS "COMUNA"
FROM
    cliente
ORDER BY
    &order;
    
-- Caso 2

SELECT
    'El empleado '
    || pnombre_emp
    || ' '
    || appaterno_emp
    || ' '
    || apmaterno_emp
    || ' estuvo de cumplea?s el '
    || EXTRACT(DAY FROM fecha_nac)
    || ' de '
    || INITCAP(TO_CHAR(fecha_nac,'MONTH'))
    || '. Cumplio '
    || (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM fecha_nac))
    || ' a?os'
        AS "LISTADO DE CUMPLEA?OS"
FROM
    empleado
WHERE
    EXTRACT(MONTH FROM fecha_nac) = EXTRACT(MONTH FROM TO_DATE('01/08/2020')) -1
ORDER BY
    EXTRACT(DAY FROM fecha_nac) ASC,
    appaterno_emp ASC;
    
--CASO 3

SELECT 
    tipo_camion.nombre_tipo_camion
        AS "TIPO CAMION",
    camion.nro_patente,
    camion.anio
        AS "A?O",
    NVL(TO_CHAR(camion.valor_arriendo_dia, 'L99G999'), 0)
        AS "VALOR ARRIENDO DIA",
    NVL(TO_CHAR(camion.valor_garantia_dia, 'L999G999'), TO_CHAR(0, 'L9'))
        AS "VALOR GARANTIA DIA",
    TO_CHAR((NVL(camion.valor_arriendo_dia, 0) + NVL(camion.valor_garantia_dia, 0)), 'L999G999')
        AS "VALOR TOTAL DIA"
FROM 
    camion
INNER JOIN
    tipo_camion
        ON camion.id_tipo_camion = tipo_camion.id_tipo_camion
ORDER BY
    tipo_camion.nombre_tipo_camion ASC,
    "VALOR ARRIENDO DIA" DESC,
    camion.valor_garantia_dia ASC,
    camion.nro_patente ASC;
    
-- Caso 4

SELECT
    TO_CHAR(SYSDATE, 'MM/YYYY')
        AS "FECHA PROCESO",
    TO_CHAR(numrun_emp, '09G999G999')
    || '-'
    || dvrun_emp
        AS "RUN EMPLEADO",
    pnombre_emp
    || ' '
    || snombre_emp
    || ' '
    || appaterno_emp
    || ' '
    || apmaterno_emp
        AS "NOMBRE EMPLEADO",
    TO_CHAR(sueldo_base, 'L9G999G999')
        AS "SUELDO BASE",
    CASE
        WHEN sueldo_base BETWEEN 320000 and 450000 THEN
            TO_CHAR((&&utilidades * 0.005), 'L999G999G999')
        WHEN sueldo_base BETWEEN 450001 and 600000 THEN
            TO_CHAR(&utilidades * 0.0035, 'L999G999G999')
        WHEN sueldo_base BETWEEN 600001 and 900000 THEN
            TO_CHAR(&utilidades * 0.0025, 'L999G999G999')
        WHEN sueldo_base BETWEEN 900001 and 1800000 THEN
            TO_CHAR(&utilidades * 0.0015, 'L999G999G999')
        WHEN sueldo_base > 1800000 THEN
            TO_CHAR(&utilidades * 0.001, 'L999G999G999')
    END
FROM 
    empleado
ORDER BY
    appaterno_emp;
    
-- Caso 5

SELECT
  NUMRUN_EMP
  || '-'
  || DVRUN_EMP
    AS "RUN EMPLEADO",
  PNOMBRE_EMP
  || ' '
  || SNOMBRE_EMP
  || ' '
  || APPATERNO_EMP
  || ' '
  || APMATERNO_EMP
    AS "NOMBRE EMPLEADO",
  (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM FECHA_CONTRATO))
    AS "AÑOS CONTRATADO",
  TO_CHAR(SUELDO_BASE, 'L9G999G999')
    AS "SUELDO BASE",
  TO_CHAR(SUELDO_BASE * ((EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM FECHA_CONTRATO))/100), 'L999G999G999')
    AS "VALOR MOVILIZACION",
  CASE
      WHEN SUELDO_BASE >= 450000 THEN
        TO_CHAR((TRUNC(SUELDO_BASE) * (SUBSTR(SUELDO_BASE, 1,1) / 100)), 'L999G999')
      ELSE
        TO_CHAR((TRUNC(SUELDO_BASE) * (SUBSTR(SUELDO_BASE, 1,2) / 100)), 'L999G999')
  END AS "BONIF. EXTRA MOVILIZACION",
  CASE
      WHEN SUELDO_BASE >= 450000 THEN
        TO_CHAR(
        (
        SUELDO_BASE * ((EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM FECHA_CONTRATO))/100)
        +
        (TRUNC(SUELDO_BASE) * (SUBSTR(SUELDO_BASE, 1,1) / 100))
        )
        , 'L999G999G999')
      ELSE
        TO_CHAR(
        (
        SUELDO_BASE * ((EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM FECHA_CONTRATO))/100)
        +
        (TRUNC(SUELDO_BASE) * (SUBSTR(SUELDO_BASE, 1,2) / 100))
        )
        , 'L999G999G999')
  END AS "TOTAL MOVILIZACION"
  
FROM
  EMPLEADO
INNER JOIN
  COMUNA
  ON
    COMUNA.ID_COMUNA = EMPLEADO.ID_COMUNA
WHERE
  COMUNA.NOMBRE_COMUNA IN('María Pinto', 'Curacaví', 'El Monte', 'Paine', 'Pirque')
ORDER BY
  APPATERNO_EMP ASC;
  
-- Caso 6

SELECT 
    EXTRACT(YEAR FROM SYSDATE) 
        AS "AÑO TRIBUTARIO",
    TO_CHAR(NUMRUN_EMP, '99G999G999')
    || '-'
    || DVRUN_EMP
        AS "RUN EMPLEADO",
    PNOMBRE_EMP
    || ' '
    || SNOMBRE_EMP
    || ' '
    || APPATERNO_EMP
    || ' '
    || APMATERNO_EMP
        AS "NOMBRE EMPLEADO",
    CASE
        WHEN EXTRACT(YEAR FROM fecha_contrato)= EXTRACT(YEAR FROM SYSDATE) THEN
            ROUND((TO_DATE ('31/12/' || EXTRACT(YEAR FROM SYSDATE)) - FECHA_CONTRATO)/30,1)
        ELSE
            ROUND(MONTHS_BETWEEN(TO_DATE('31/12/' || EXTRACT(YEAR FROM SYSDATE)), TO_DATE('01/01/' || EXTRACT(YEAR FROM SYSDATE))))
    END AS "MESES TRABAJADOS EN EL ANNO",
    (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM fecha_contrato))
        AS "ANNOS TRABAJADOS",
    sueldo_base
        AS "SUELDO BASE MENSUAL",
    sueldo_base * 12
        AS "SUELDO BASE ANUAL",
    ROUND(sueldo_base * ((EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM fecha_contrato)) / 100)) * 12
        AS "BONO POR AÑOS ANUAL",
    ROUND((sueldo_base * 12 / 100) * 12)
        AS "MOVILIZACION ANUAL",
    ROUND((sueldo_base * 20 /100)) * 12
        AS "COLACION ANUAL",
    (
    (sueldo_base * 12)
    +
    (ROUND(sueldo_base * ((EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM fecha_contrato)) / 100)) * 12)
    +
    ROUND((sueldo_base * 0.12) * 12)
    +
    (ROUND(sueldo_base * 0.2) * 12)
    )
        AS "SUELDO BRUTO ANUAL",
   
    round(sueldo_base +
    (sueldo_base * ((EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM fecha_contrato)) / 100))) * 12
        AS "RENTA INPONIBLE ANUAL"
FROM
  EMPLEADO
ORDER BY
    "RUN EMPLEADO" ASC;
