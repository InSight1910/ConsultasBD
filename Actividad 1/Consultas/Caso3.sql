SELECT 
    nombre_emp 
    || ' '
    || appaterno_emp 
    || ' '
    || apmaterno_emp 
        AS "NOMBRE EMPLEADO",
    sueldo_emp
        AS "SUELDO",
    sueldo_emp * .5 
        AS "BONO POR CAPACITACION"
FROM empleado;