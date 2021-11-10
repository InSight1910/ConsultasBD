-- CASO 1
INSERT INTO bonif_arriendos_mensual
(
SELECT
    TO_CHAR(SYSDATE, 'YYYYMM') AS "ANNO_MED",
    emp.numrun_emp,
    INITCAP(
        emp.pnombre_emp || ' ' || emp.snombre_emp || ' ' || emp.appaterno_emp || ' ' || emp.apmaterno_emp
    ) AS "NOMBRE_EMPLEADO",
    emp.sueldo_base,
    COUNT(arcam.id_arriendo) AS "TOTAL_ARRIENDO_MENSUAL",
    ROUND(emp.sueldo_base * porcBonc."porcentaje")
FROM
    empleado emp
    INNER JOIN camion cam ON (emp.numrun_emp = cam.numrun_emp)
    LEFT JOIN arriendo_camion arcam ON (
        arcam.nro_patente = cam.nro_patente
        AND EXTRACT(
            YEAR
            FROM
                SYSDATE
        ) = EXTRACT(
            YEAR
            FROM
                arcam.fecha_ini_arriendo
        )
        AND EXTRACT(
            MONTH
            FROM
                SYSDATE
        ) -2 = EXTRACT(
            MONTH
            FROM
                arcam.fecha_ini_arriendo
        )
    )
    INNER JOIN (
        SELECT
            cam.numrun_emp,
            COUNT(arcam.id_arriendo) / 100 AS "porcentaje"
        FROM
            arriendo_camion arcam
            INNER JOIN camion cam ON (cam.nro_patente = arcam.nro_patente)
        WHERE
            EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) = EXTRACT(
                YEAR
                FROM
                    arcam.fecha_ini_arriendo
            )
            AND EXTRACT(
                MONTH
                FROM
                    SYSDATE
            ) -2 = EXTRACT(
                MONTH
                FROM
                    arcam.fecha_ini_arriendo
            )
        GROUP BY
            cam.numrun_emp
    ) porcBonc ON (emp.numrun_emp = porcBonc.numrun_emp)
GROUP BY
    TO_CHAR(SYSDATE, 'YYYYMM'),
    emp.numrun_emp,
    INITCAP(
        emp.pnombre_emp || ' ' || emp.snombre_emp || ' ' || emp.appaterno_emp || ' ' || emp.apmaterno_emp
    ),
    emp.sueldo_base,
    emp.appaterno_emp,
    porcBonc."porcentaje"
)
ORDER BY
    emp.appaterno_emp;
delete from bonif_arriendos_mensual;
select * from bonif_arriendos_mensual;

-- CASO 2
INSERT INTO clientes_arriendos_menos_prom (
SELECT
    EXTRACT(YEAR FROM SYSDATE)
        AS "ANNO_PROCESO",
    INITCAP(cli.pnombre_cli || ' ' || cli.snombre_cli || ' ' || cli.appaterno_cli || ' ' || cli.apmaterno_cli)
        AS "NOMBRE_CLIENTE",
    COUNT(arcam.id_arriendo)
        AS "TOTAL_ARRIENDOS"
FROM
    cliente cli
LEFT JOIN arriendo_camion arcam
    ON (
        arcam.numrun_cli = cli.numrun_cli
            AND
        EXTRACT(YEAR FROM SYSDATE) = EXTRACT(YEAR FROM arcam.fecha_ini_arriendo)
        )
GROUP BY
    INITCAP(cli.pnombre_cli || ' ' || cli.snombre_cli || ' ' || cli.appaterno_cli || ' ' || cli.apmaterno_cli),
    EXTRACT(YEAR FROM SYSDATE),
    cli.appaterno_cli
HAVING
    COUNT(arcam.id_arriendo) <= (
    SELECT
        ROUND(AVG(COUNT(arcam.id_arriendo)))
    FROM
        cliente cli
    LEFT JOIN arriendo_camion arcam
        ON (
            arcam.numrun_cli = cli.numrun_cli
                AND
            EXTRACT(YEAR FROM SYSDATE) = EXTRACT(YEAR FROM arcam.fecha_ini_arriendo)
            )  
    GROUP BY
        cli.numrun_cli
    )
)
ORDER BY
    cli.appaterno_cli
;

-- CASO 3
CREATE TABLE CLIENTES_SIN_ARRIENDOS AS (
SELECT
    *
FROM 
    cliente cli
WHERE
    cli.numrun_cli IN (
        SELECT
            cli.numrun_cli
        FROM
            cliente cli
        LEFT JOIN arriendo_camion arcam
            ON (cli.numrun_cli = arcam.numrun_cli AND ROUND(MONTHS_BETWEEN(SYSDATE, arcam.fecha_ini_arriendo)/12) BETWEEN 0 AND 2)
        HAVING 
            COUNT(arcam.id_arriendo) = 0
        GROUP BY
            cli.numrun_cli
    ));
SELECT * FROM clientes_sin_arriendos;
delete from cliente cli WHERE cli.numrun_cli IN (
    SELECT
        cli.numrun_cli
    FROM
        cliente cli
    LEFT JOIN arriendo_camion arcam
        ON (cli.numrun_cli = arcam.numrun_cli AND ROUND(MONTHS_BETWEEN(SYSDATE, arcam.fecha_ini_arriendo)/12) BETWEEN 0 AND 2)
    HAVING 
        COUNT(arcam.id_arriendo) = 0
    GROUP BY
        cli.numrun_cli
);
SELECT * FROM cliente;

-- CASO 4
SELECT
    EXTRACT(YEAR FROM SYSDATE)
        AS "ANN_PROCESO",
    cam.nro_patente,
    cam.valor_arriendo_dia,
    cam.valor_garantia_dia,
    COUNT(arcam.id_arriendo)
FROM
    camion cam
LEFT JOIN arriendo_camion arcam
    ON (arcam.nro_patente = cam.nro_patente AND EXTRACT(YEAR FROM SYSDATE) = EXTRACT(YEAR FROM arcam.fecha_ini_arriendo))
GROUP BY
    EXTRACT(YEAR FROM SYSDATE),
    cam.nro_patente,
    cam.valor_arriendo_dia,
    cam.valor_garantia_dia;

UPDATE 
    camion 
SET 
    valor_arriendo_dia = valor_arriendo_dia * 0.775,
    valor_garantia_dia = valor_garantia_dia*0.775
WHERE
    nro_patente IN (
        SELECT
            cam.nro_patente
        FROM
            camion cam
        LEFT JOIN arriendo_camion arcam
            ON (arcam.nro_patente = cam.nro_patente AND EXTRACT(YEAR FROM SYSDATE) = EXTRACT(YEAR FROM arcam.fecha_ini_arriendo))
        GROUP BY
            cam.nro_patente
        HAVING
            COUNT(arcam.id_arriendo) < 4
    );
SELECT * FROM camion;

-- CASO 5
INSERT INTO informacion_sii
SELECT
    emp.numrun_emp,
    emp.dvrun_emp,
    EXTRACT(YEAR FROM SYSDATE)
        AS "ANNO_TRIBUTARIO",
    UPPER(emp.pnombre_emp || ' ' || emp.snombre_emp || ' ' || emp.appaterno_emp || ' ' || emp.apmaterno_emp)
        AS "NOMBRE_EMP",
    MONTHS_BETWEEN(SYSDATE, TO_DATE('01/01/' || EXTRACT(YEAR FROM SYSDATE)))
        AS "MESES_TRABAJADOS_ANNO",
    ROUND(MONTHS_BETWEEN(SYSDATE, emp.fecha_contrato)/12)
        AS "ANNOS_TRABAJADOS",
    emp.sueldo_base
        AS "SUELDO_BASE_MENSUAL",
    emp.sueldo_base * 12
        AS "SUELDO_BASE_ANUAL",
    CASE
        WHEN ROUND(MONTHS_BETWEEN(SYSDATE, emp.fecha_contrato)/12) <= 1 THEN
            0
        ELSE
            ROUND(sueldo_base * (ROUND(MONTHS_BETWEEN(SYSDATE, emp.fecha_contrato)/12)/100) * 12)
    END AS "BONO_POR_ANNOS_ANUAL",
    ROUND(emp.sueldo_base * 0.12 * 12)
        AS "MOVILIZACION_ANUAL",
    ROUND(emp.sueldo_base * 0.2 ) * 12
        AS "COLACION_ANUAL",
    ROUND(
    emp.sueldo_base * 12 + 
    (emp.sueldo_base * 0.12 * 12) + 
    (emp.sueldo_base * 0.2 * 12) + 
    CASE
        WHEN ROUND(MONTHS_BETWEEN(SYSDATE, emp.fecha_contrato)/12) <= 1 THEN
            0
        ELSE
            sueldo_base * 12 * (ROUND((MONTHS_BETWEEN(SYSDATE, emp.fecha_contrato)/12)-1)/100)
    END
    )
        AS "SUELDO_BRUTO_ANUAL",
    ROUND(
    emp.sueldo_base +
    CASE
        WHEN ROUND(MONTHS_BETWEEN(SYSDATE, emp.fecha_contrato)/12) <= 1 THEN
            0
        ELSE
            sueldo_base * (ROUND((MONTHS_BETWEEN(SYSDATE, emp.fecha_contrato)/12)-1)/100)
    END
    ) * 12
        AS "RENTA_IMPONIBLE_ANUAL"
FROM 
    empleado emp
ORDER BY
    emp.numrun_emp;
COMMIT;