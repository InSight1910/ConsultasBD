-- CASO 1
-- INFORME 1
SELECT
    tps.descripcion || ',' || s.descripcion AS "SISTEMA SALUD",
    COUNT(at.ate_id) AS "TOTAL ATENCIONES"
FROM
    atencion at
    INNER JOIN paciente pcte ON (at.pac_run = pcte.pac_run)
    INNER JOIN salud s ON (pcte.sal_id = s.sal_id)
    INNER JOIN tipo_salud tps on (s.tipo_sal_id = tps.tipo_sal_id)
WHERE
    EXTRACT(
        MONTH
        FROM
            fecha_atencion
    ) = EXTRACT(
        MONTH
        FROM
            SYSDATE
    ) - 1
    AND EXTRACT(
        YEAR
        FROM
            fecha_atencion
    ) = EXTRACT(
        YEAR
        FROM
            SYSDATE
    )
    AND tps.descripcion in ('Fonasa', 'Isapre')
GROUP BY
    tps.descripcion,
    s.descripcion
HAVING
    COUNT(at.ate_id) > (
        SELECT
            ROUND(AVG(CANT_ATE)) AS "PROMEDIO"
        FROM
            (
                SELECT
                    ate.fecha_atencion AS "FECHA_ATENCION",
                    COUNT(ate.ate_id) AS "CANT_ATE"
                FROM
                    atencion ate
                WHERE
                    EXTRACT(
                        MONTH
                        FROM
                            fecha_atencion
                    ) = EXTRACT(
                        MONTH
                        FROM
                            SYSDATE
                    ) - 1
                    AND EXTRACT(
                        YEAR
                        FROM
                            fecha_atencion
                    ) = EXTRACT(
                        YEAR
                        FROM
                            SYSDATE
                    )
                GROUP BY
                    ate.fecha_atencion
            )
    )
ORDER BY
    "SISTEMA SALUD" ASC;

-- INFORME 2
SELECT
    TO_CHAR(pac.pac_run, '09G999G999') || '-' || pac.dv_run 
        AS "RUN PACIENTE",
    INITCAP(
        pac.pnombre || ' ' || pac.snombre || ' ' || pac.apaterno || ' ' || pac.amaterno
    ) 
        AS "NOMBRE PACIENTE",
    ROUND((MONTHS_BETWEEN(SYSDATE, fecha_nacimiento) / 12)) 
        AS "EDAD",
    'Le corresponde  un ' || porc.porcentaje_descto || '% de descuento en la primera consulata medica del a�o ' || (
        EXTRACT(
            YEAR
            FROM
                SYSDATE
        ) + 1
    )
        AS "PORCENTAJE DESCUENTO"
FROM
    paciente pac
    JOIN porc_descto_3ra_edad porc ON ROUND((MONTHS_BETWEEN(SYSDATE, fecha_nacimiento) / 12)) BETWEEN porc.anno_ini
    AND porc.anno_ter
WHERE
    TRUNC(
        (MONTHS_BETWEEN(SYSDATE, fecha_nacimiento) / 12),
        1
    ) >= 64.5
    AND pac.pac_run IN (
        SELECT
            pac_run AS "PAC_RUN"
        FROM
            atencion ate
        WHERE
            EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) = EXTRACT(
                YEAR
                FROM
                    ate.fecha_atencion
            )
        HAVING
            COUNT(ate.ate_id) > 4
        GROUP BY
            ate.pac_run
    );

-- CASO 2
SELECT
    es.nombre 
        AS "ESPECIALIDAD",
    TO_CHAR(md.med_run, '09G999G999') || '-' || md.dv_run
        AS "RUT",
    UPPER(
        md.pnombre || ' ' || md.snombre || ' ' || md.apaterno || ' ' || md.amaterno
    ) 
        AS "MEDICO"
FROM
    medico md
    INNER JOIN especialidad_medico em ON (em.med_run = md.med_run)
    INNER JOIN especialidad es ON (es.esp_id = em.esp_id)
WHERE
    es.nombre IN (
        SELECT
            es.nombre
        FROM
            atencion ate
            INNER JOIN especialidad_medico em ON (em.med_run = ate.med_run)
            INNER JOIN especialidad es ON (es.esp_id = em.esp_id)
        HAVING
            COUNT(ate.esp_id) < 10
        GROUP BY
            ate.esp_id,
            es.nombre
    )
ORDER BY
    "ESPECIALIDAD",
    "RUT";

SELECT
	em.med_run,
	COUNT(md.med_run)
FROM
	atencion ate
	INNER JOIN especialidad_medico em ON (em.med_run = ate.med_run)
	INNER JOIN medico md ON (md.med_run = em.med_run)
	INNER JOIN especialidad es ON (es.esp_id = em.esp_id)
WHERE
	EXTRACT(YEAR FROM ate.fecha_atencion) = EXTRACT(YEAR FROM SYSDATE) - 1
GROUP BY
	em.med_run;

-- CASO 3
SELECT
    un.nombre
        AS "UNIDAD",
    UPPER(
        md.pnombre || ' ' || md.snombre || ' ' || md.apaterno || ' ' || md.amaterno
    )
        AS "MEDICO",
    md.telefono
        AS "TELEFONO"
FROM
    medico md
    INNER JOIN unidad un ON (un.uni_id = md.uni_id)
WHERE
    md.med_run IN (
        SELECT
            ate.med_run AS "PAC_RUN"
        FROM
            atencion ate
        WHERE
            EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) -1 = EXTRACT(
                YEAR
                FROM
                    ate.fecha_atencion
            )
        HAVING
            COUNT(ate.med_run) < (
                SELECT
                    MAX(COUNT(ate.med_run)) AS "PAC_RUN"
                FROM
                    atencion ate
                WHERE
                    EXTRACT(
                        YEAR
                        FROM
                            SYSDATE
                    ) -1 = EXTRACT(
                        YEAR
                        FROM
                            ate.fecha_atencion
                    )
                GROUP BY
                    ate.med_run
            )
        GROUP BY
            ate.med_run
    )
ORDER BY
    un.nombre,
    md.apaterno;

-- CASO 4
-- INFORME 1
SELECT
    TO_CHAR(ate.fecha_atencion, 'YYYY/MM')
        AS "A�O Y MES",
    COUNT(ate.ate_id) 
        AS "TOTAL ATENCIONES",
    TO_CHAR(SUM(ate.costo), 'L999G999G999')
        AS "VALOR TOTAL"
FROM
    atencion ate
WHERE
    MONTHS_BETWEEN(SYSDATE, ate.fecha_atencion) BETWEEN MONTHS_BETWEEN(SYSDATE, ate.fecha_atencion)
    AND MONTHS_BETWEEN(SYSDATE, ADD_MONTHS(ate.fecha_atencion, -48))
HAVING
    COUNT(ate.ate_id) >= (
        SELECT
            ROUND(AVG(COUNT(ate.ate_id)))
        FROM
            atencion ate
        GROUP BY
            TO_CHAR(ate.fecha_atencion, 'YYYY/MM')
    )
GROUP BY
    TO_CHAR(ate.fecha_atencion, 'YYYY/MM')
ORDER BY
    TO_CHAR(ate.fecha_atencion, 'YYYY/MM');

-- INFORME 2
SELECT
    TO_CHAR(pac.pac_run, '09G999G999') || '-' || pac.dv_run
        AS "RUN PACIENTE",
    INITCAP(
        pac.pnombre || ' ' || pac.snombre || ' ' || pac.apaterno || ' ' || pac.amaterno
    )
        AS "NOMBRE PACIENTE",
    ate.ate_id
        AS "ID ATENCION",
    TO_CHAR(pate.fecha_venc_pago, 'DD/MM/YYYY')
        AS "FECHA VENCIMIENTO PAGO",
    TO_CHAR(pate.fecha_pago, 'DD/MM/YYYY')
        AS "FECHA PAGO",
    pate.fecha_pago - pate.fecha_venc_pago
        AS "DIAS MOROSOS",
    TO_CHAR(
        (pate.fecha_pago - pate.fecha_venc_pago) * 2000,
        'L999G999G999'
    )
        AS "VALOR MULTA"
FROM
    paciente pac
    INNER JOIN atencion ate ON (ate.pac_run = pac.pac_run)
    INNER JOIN pago_atencion pate ON (pate.ate_id = ate.ate_id)
WHERE
    pate.fecha_pago - pate.fecha_venc_pago > 13
GROUP BY
    pac.pac_run,
    pac.dv_run,
    pac.pnombre,
    pac.snombre,
    pac.apaterno,
    pac.amaterno,
    ate.ate_id,
    pate.fecha_venc_pago,
    pate.fecha_pago
ORDER BY
    pate.fecha_venc_pago ASC,
    pate.fecha_pago - pate.fecha_venc_pago DESC;

-- CASO 5
SELECT
    TO_CHAR(md.med_run, '09G999G999') || '-' || md.dv_run
        AS "RUN MEDICO",
    UPPER(
        md.pnombre || ' ' || md.snombre || ' ' || md.apaterno || ' ' || md.amaterno
    )
        AS "NOMBRE MEDICO",
    COUNT(ate.ate_id)
        AS "TOTAL ATENCIONES MEDICAS",
    TO_CHAR(md.sueldo_base, 'L999G999G999')
        AS "SUELDO BASE",
    TO_CHAR(
        ROUND(
            (
                SELECT
                    (&& ganancias * 0.005) / COUNT(*)
                FROM
                    (
                        SELECT
                            COUNT(ate.med_run)
                                AS "CANT_ATE"
                        FROM
                            atencion ate
                        WHERE
                            EXTRACT(
                                YEAR
                                FROM
                                    SYSDATE
                            ) = EXTRACT(
                                YEAR
                                FROM
                                    ate.fecha_atencion
                            )
                        HAVING
                            COUNT(ate.ate_id) > 7
                        group by
                            ate.med_run
                    )
            )
        ),
        'L999G999G999'
    )
        AS "BONIFICACION POR GANANCIAS",
    TO_CHAR(
        ROUND(
            md.sueldo_base + (
                SELECT
                    (&ganancias * 0.005) / COUNT(*)
                FROM
                    (
                        SELECT
                            COUNT(ate.med_run)
                                AS "CANT_ATE"
                        FROM
                            atencion ate
                        WHERE
                            EXTRACT(
                                YEAR
                                FROM
                                    SYSDATE
                            ) = EXTRACT(
                                YEAR
                                FROM
                                    ate.fecha_atencion
                            )
                        HAVING
                            COUNT(ate.ate_id) > 7
                        group by
                            ate.med_run
                    )
            )
        ),
        'L999G999G999'
    )
        AS "SUELDO TOTAL"
FROM
    medico md
    INNER JOIN atencion ate ON (ate.med_run = md.med_run)
WHERE
    EXTRACT(
        YEAR
        FROM
            SYSDATE
    ) = EXTRACT(
        YEAR
        FROM
            ate.fecha_atencion
    )
HAVING
    COUNT(ate.ate_id) > 7
GROUP BY
    md.pnombre,
    md.snombre,
    md.apaterno,
    md.amaterno,
    md.med_run,
    md.dv_run,
    md.sueldo_base
ORDER BY
    md.med_run,
    md.apaterno;
-- undefine ganancias;