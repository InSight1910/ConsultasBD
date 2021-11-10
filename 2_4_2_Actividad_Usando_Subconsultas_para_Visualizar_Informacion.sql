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
    TO_CHAR(pac.pac_run, '09G999G999') || '-' || pac.dv_run AS "RUN PACIENTE",
    INITCAP(
        pac.pnombre || ' ' || pac.snombre || ' ' || pac.apaterno || ' ' || pac.amaterno
    ) AS "NOMBRE PACIENTE",
    ROUND((MONTHS_BETWEEN(SYSDATE, fecha_nacimiento) / 12)) AS "EDAD",
    'Le corresponde  un ' || porc.porcentaje_descto || '% de descuento en la primera consulata medica del año ' || (
        EXTRACT(
            YEAR
            FROM
                SYSDATE
        ) + 1
    ) AS "PORCENTAJE DESCUENTO"
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
    LOWER(esp.nombre) as "ESPECIALIDAD",
    TO_CHAR(me.med_run, '09G999G999') || '-' || me.dv_run AS "RUT",
    UPPER(
        me.pnombre ||' '|| me.snombre ||' '|| me.apaterno ||' '|| me.amaterno
    ) AS "MEDICO"
FROM
    medico me
    INNER JOIN especialidad_medico esme ON (me.med_run = esme.med_run)
    INNER JOIN especialidad esp ON(esme.esp_id = esp.esp_id)
WHERE
    esp.esp_id IN (SELECT
                            esp.esp_id
                            FROM
                                especialidad esp
                                LEFT JOIN atencion at ON (esp.esp_id=at.esp_id) AND EXTRACT(YEAR FROM at.fecha_atencion) 
                                = EXTRACT(YEAR FROM SYSDATE) -1
                            HAVING
                                COUNT(at.ate_id) BETWEEN 0 AND 10
                            GROUP BY
                                esp.esp_id
                             )
ORDER BY
    "ESPECIALIDAD" ASC,
    me.apaterno ASC;

-- CASO 3
DELETE TABLE MEDICOS_SERVICIO_COMUNIDAD;

CREATE TABLE MEDICOS_SERVICIO_COMUNIDAD AS
SELECT
    uni.nombre AS "UNIDAD",
    INITCAP(
        med.pnombre || ' ' || med.snombre || ' ' || med.apaterno || ' ' || med.amaterno
    ) AS "MEDICO",
    med.telefono AS "TELEFONO",
    UPPER(SUBSTR(uni.nombre, 1, 2)) || LOWER(SUBSTR(med.apaterno, -3, 2)) || SUBSTR(med.telefono, -3) || TO_CHAR(med.fecha_contrato, 'ddmm') || '@medicocktk.cl' AS "CORREO_MEDICO",
    COUNT(at.ate_id) AS "ATENCIONES MEDICAS"
FROM
    medico med
    INNER JOIN unidad uni ON (med.uni_id = uni.uni_id)
    LEFT OUTER JOIN atencion at ON (
        at.med_run = med.med_run
        AND EXTRACT(
            YEAR
            FROM
                at.fecha_atencion
        ) = EXTRACT(
            YEAR
            FROM
                ADD_MONTHS(SYSDATE, -12)
        )
    )
GROUP BY
    uni.nombre,
    med.pnombre,
    med.snombre,
    med.apaterno,
    med.amaterno,
    med.telefono,
    med.fecha_contrato
HAVING
    COUNT(at.ate_id) < (
        SELECT
            MAX(COUNT(at.ate_id)) AS "AT_MED"
        FROM
            atencion at
        WHERE
            EXTRACT(
                YEAR
                FROM
                    at.fecha_atencion
            ) = EXTRACT(
                YEAR
                FROM
                    ADD_MONTHS(SYSDATE, -12)
            )
        GROUP BY
            at.med_run
    )
ORDER BY
    uni.nombre ASC,
    med.apaterno ASC;

SELECT
    *
FROM
    MEDICOS_SERVICIO_COMUNIDAD;

-- CASO 4
-- INFORME 1
SELECT
    TO_CHAR(ate.fecha_atencion, 'YYYY/MM') AS "AÑO Y MES",
    COUNT(ate.ate_id) AS "TOTAL ATENCIONES",
    TO_CHAR(SUM(ate.costo), 'L999G999G999') AS "VALOR TOTAL"
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
    TO_CHAR(pac.pac_run, '09G999G999') || '-' || pac.dv_run AS "RUN PACIENTE",
    INITCAP(
        pac.pnombre || ' ' || pac.snombre || ' ' || pac.apaterno || ' ' || pac.amaterno
    ) AS "NOMBRE PACIENTE",
    ate.ate_id AS "ID ATENCION",
    TO_CHAR(pate.fecha_venc_pago, 'DD/MM/YYYY') AS "FECHA VENCIMIENTO PAGO",
    TO_CHAR(pate.fecha_pago, 'DD/MM/YYYY') AS "FECHA PAGO",
    pate.fecha_pago - pate.fecha_venc_pago AS "DIAS MOROSOS",
    TO_CHAR(
        (pate.fecha_pago - pate.fecha_venc_pago) * 2000,
        'L999G999G999'
    ) AS "VALOR MULTA"
FROM
    paciente pac
    INNER JOIN atencion ate ON (ate.pac_run = pac.pac_run)
    INNER JOIN pago_atencion pate ON (pate.ate_id = ate.ate_id)
WHERE
    pate.fecha_pago - pate.fecha_venc_pago > (
        SELECT
            ROUND(AVG(fecha_pago - fecha_venc_pago))
        FROM
            pago_atencion
        WHERE
            fecha_pago - fecha_venc_pago > 0
    )
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
    TO_CHAR(md.med_run, '09G999G999') || '-' || md.dv_run AS "RUN MEDICO",
    UPPER(
        md.pnombre || ' ' || md.snombre || ' ' || md.apaterno || ' ' || md.amaterno
    ) AS "NOMBRE MEDICO",
    COUNT(ate.ate_id) AS "TOTAL ATENCIONES MEDICAS",
    TO_CHAR(md.sueldo_base, 'L999G999G999') AS "SUELDO BASE",
    TO_CHAR(
        ROUND(
            (
                SELECT
                    (& & ganancias * 0.005) / COUNT(*)
                FROM
                    (
                        SELECT
                            COUNT(ate.med_run) AS "CANT_ATE"
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
    ) AS "BONIFICACION POR GANANCIAS",
    TO_CHAR(
        ROUND(
            md.sueldo_base + (
                SELECT
                    (& ganancias * 0.005) / COUNT(*)
                FROM
                    (
                        SELECT
                            COUNT(ate.med_run) AS "CANT_ATE"
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
    ) AS "SUELDO TOTAL"
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

undefine ganancias;
----------------------------------------------------------------
SELECT
	esp.esp_id,
	COUNT(ate.ate_id)
FROM
	atencion ate
INNER JOIN especialidad_medico esm
	ON (esm.med_run = ate.med_run)
RIGHT JOIN especialidad esp
	ON (esm.esp_id = esp.esp_id AND EXTRACT(
		YEAR
		FROM
			ate.fecha_atencion
	) = EXTRACT(
		YEAR
		FROM
			ADD_MONTHS(SYSDATE, -12)
	))
GROUP BY
	esp.esp_id