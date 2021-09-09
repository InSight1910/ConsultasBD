SELECT
    numrut_emp
    || '-'
    || dvrut_emp 
        AS "RUN EMPLEADO",
    nombre_emp
    || ' '
    || appaterno_emp
    || ' '
    || apmaterno_emp
        AS "NOMBRE EMPLEADO",
    sueldo_emp
        AS "SALARIO ACTUAL",
    sueldo_emp * (&porcentaje / 100)
        AS "BONIFICACION EXTRA"
FROM
    empleado
INNER JOIN
    categoria_empleado
        ON categoria_empleado.id_categoria_emp = empleado.id_categoria_emp
WHERE 
    categoria_empleado.desc_categoria_emp <> 'Ejecutivo de Arriendo'
        AND
    empleado.sueldo_emp < 500000
ORDER BY
    empleado.appaterno_emp