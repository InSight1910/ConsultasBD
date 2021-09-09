SELECT
    nombre_emp 
    || ' '
    || appaterno_emp 
    || ' '
    || apmaterno_emp 
        AS "NOMBRE EMPLEADO",
    sueldo_emp
        AS "SALARIO",
    sueldo_emp * 0.055
        AS "COLACION",
    sueldo_emp * 0.178
        AS "MOVILIZACION",
    sueldo_emp * 0.078
        AS "SALUD",
    sueldo_emp * 0.065
        AS "AFP",
    sueldo_emp 
    + sueldo_emp * 0.055 
    + sueldo_emp * 0.178 
    - sueldo_emp * 0.078 
    - sueldo_emp * 0.065
        AS "ALCANCE LIQUIDO"
FROM
    empleado
ORDER BY
    appaterno_emp;