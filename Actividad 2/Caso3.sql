SELECT
    nombre_emp
    || ' '
    || appaterno_emp
    || ' '
    || apmaterno_emp
        AS "NOMBRE EMPLEADO",
    sueldo_emp
        AS "SUELDO ACTUAL",
    sueldo_emp * (((&&percent) / 100)+1)
        AS "SUELDO REAJUSTADO",
    sueldo_emp * ((&percent) / 100)
        AS "REAJUSTE"
FROM
    empleado
ORDER BY
    "REAJUSTE" DESC;
    
SELECT
    nombre_emp
    || ' '
    || appaterno_emp
    || ' '
    || apmaterno_emp
        AS "NOMBRE EMPLEADO",
    sueldo_emp
        AS "SUELDO ACTUAL",
    sueldo_emp * (((&&percent) / 100)+1)
        AS "SUELDO REAJUSTADO",
    sueldo_emp * ((&percent) / 100)
        AS "REAJUSTE"
FROM
    empleado
WHERE 
    sueldo_emp  
    BETWEEN 
            (&condicion_inicial) 
        AND 
            (&condicion_final)
ORDER BY
    "REAJUSTE" DESC;