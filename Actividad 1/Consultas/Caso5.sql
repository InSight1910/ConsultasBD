SELECT 
    numrut_emp
    || ' '
    || dvrut_emp as "RUN EMPLEADO",
    nombre_emp 
    || ' '
    || appaterno_emp 
    || ' '
    || apmaterno_emp AS "NOMBRE EMPLEADO",
    sueldo_emp AS "SALARIO ACTUAL",
    sueldo_emp *1.135 AS "SALARIO REAJUSTADO",
    sueldo_emp * 0.135 AS "REAJUSTE"
FROM 
    empleado
ORDER BY
    REAJUSTE DESC,
    appaterno_emp DESC;