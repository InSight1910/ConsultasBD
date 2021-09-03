SELECT
    'El empleado '
    || upper("A1"."NOMBRE_EMP")
    || ' '
    || upper("A1"."APPATERNO_EMP")
    || ' '
    || upper("A1"."APMATERNO_EMP")
    || ' nacio el '
    || TO_CHAR(fecnac_emp, 'DD/MM/YYYY')
    AS "LISTADO  DE CUMPLEANOS"
FROM
    "MDY2131_P1"."EMPLEADO" "A1"
ORDER BY 
    fecnac_emp ASC,
    appaterno_emp ASC;