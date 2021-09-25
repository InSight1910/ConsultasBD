-- Caso 1
SELECT
    carreraid
        AS "IDENTIFICACION DE LA CARRERA"
    ,COUNT(*)
        AS "TOTAL ALUMNOS MATRICULADOS",
    'Le corresponden ' ||
    TRIM(TO_CHAR((COUNT(*) * &valor), 'L999G999G999')) ||
    ' del presupuesto total asignado para publicidad'
    AS "MONTO POR PUBLICIDAD"
FROM
    alumno
GROUP BY
    carreraid
ORDER BY
    "TOTAL ALUMNOS MATRICULADOS" DESC,
    carreraid ASC;
    
-- Caso 2
SELECT
    carreraid
        AS "CARRERA"
    ,COUNT(*)
        AS "TOTAL ALUMNOS MATRICULADOS"
FROM
    alumno
GROUP BY
    carreraid
HAVING
    COUNT(*) > 4
ORDER BY
    carreraid ASC;
    
-- Caso 3
SELECT DISTINCT
    TO_CHAR(run_jefe, '09G999G999')
        AS "RUN JEFE SIN DV"
    ,COUNT(*)
        AS "TOTAL DE EMPLEADOS A SU CARGO"
    ,MAX(salario)
        AS "SALARIO MAXIMO"
    , COUNT(*) * 10 ||
    '% del Salario Maximo'
    ,TO_CHAR(MAX(salario) * ((COUNT(*) * 10) / 100), 'L999G999G999')
        AS "BONIFICACION"
FROM
    empleado
WHERE
    run_jefe IS NOT NULL
GROUP BY
    run_jefe
ORDER BY
    "TOTAL DE EMPLEADOS A SU CARGO" ASC;
    
-- Caso 4
SELECT
    empleado.id_escolaridad
        AS "ESCOLARIDAD",
    escolaridad_emp.desc_escolaridad
        AS "DESCRIPCION ESCOLARIDAD",
    COUNT(*)
        AS "TOTAL EMPLEADOS",
    TO_CHAR(MAX(empleado.salario), 'L999G999G999')
        AS "SALARIO MAXIMO",
    TO_CHAR(MIN(empleado.salario), 'L999G999G999')
        AS "SALARIO MAXIMO",
    TO_CHAR(SUM(empleado.salario), 'L999G999G999')
        AS "SALARIO TOTAL",
    TO_CHAR(ROUND(AVG(empleado.salario)), 'L999G999G999')
        AS "SALARIO PROMEDIO"
FROM
    empleado
INNER JOIN
    escolaridad_emp
    ON empleado.id_escolaridad = escolaridad_emp.id_escolaridad
GROUP BY
    empleado.id_escolaridad,
    escolaridad_emp.desc_escolaridad
ORDER BY
    "TOTAL EMPLEADOS" DESC;

-- Caso 5

SELECT 
    TITULOID
        AS "CODIGO DEL LIBRO",
    COUNT(*)
        AS "TOTAL DE VECES SOLICITADO",
    CASE
        WHEN COUNT(*) <= 1 THEN
            'No se require nuevos ejemplares'
        WHEN COUNT(*) BETWEEN 2 AND 3 THEN
            'Se requiere comprar 1 nuevo ejemplar'
        WHEN COUNT(*) BETWEEN 4 AND 5 THEN
            'Se requiere comprar 2 nuevos ejemplares'
        WHEN COUNT(*) > 5 THEN
            'Se requiere comprar 4 nuevos ejemplares'
    END AS "SUGERENCIA"
FROM 
    PRESTAMO
WHERE 
    EXTRACT(YEAR FROM FECHA_INI_PRESTAMO) = EXTRACT(YEAR FROM SYSDATE) - 1 
GROUP BY
    TITULOID
ORDER BY
    COUNT(*) DESC;

-- CASO 6

SELECT
    TO_CHAR(run_emp, '09G999G999')
        AS "RUN EMPLEADO"
    , TO_CHAR(fecha_ini_prestamo, 'MM/YYYY')
        AS "MES PRESTAMO"
    , COUNT(*)
        AS "TOTAL PRESTAMOS ATENDIDOS"
FROM
    prestamo
WHERE
    EXTRACT(YEAR FROM fecha_ini_prestamo) = EXTRACT(YEAR FROM SYSDATE) - 1
GROUP BY
    run_emp
    , fecha_ini_prestamo
order by
    "MES PRESTAMO";