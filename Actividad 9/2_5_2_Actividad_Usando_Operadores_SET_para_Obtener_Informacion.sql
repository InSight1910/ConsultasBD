-- CASO 1
-- INFORME 1
(
    SELECT
        tsal.descripcion || ',' || sal.descripcion AS "SISTEMA_SALUD",
        COUNT(ate.ate_id) AS "TOTAL ATENCIONES",
        'CON Descuento' AS "CORRESPONDE DESCUENTO"
    FROM
        atencion ate
        INNER JOIN paciente pac ON (
            ate.pac_run = pac.pac_run
            AND EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) = EXTRACT(
                YEAR
                FROM
                    ate.fecha_atencion
            )
            AND EXTRACT(
                MONTH
                FROM
                    TO_DATE('01/10/2021', 'DD/MM/YYYY')
            ) = EXTRACT(
                MONTH
                FROM
                    ate.fecha_atencion
            )
        )
        RIGHT JOIN salud sal ON (sal.sal_id = pac.sal_id)
        RIGHT JOIN tipo_salud tsal ON (tsal.tipo_sal_id = sal.tipo_sal_id)
    HAVING
        COUNT(ate.ate_id) > (
            SELECT
                ROUND(AVG(COUNT_ATE))
            FROM
                (
                    SELECT
                        COUNT(ate.ate_id) AS "COUNT_ATE"
                    FROM
                        atencion ate
                        INNER JOIN paciente pac ON (
                            ate.pac_run = pac.pac_run
                            AND EXTRACT(
                                YEAR
                                FROM
                                    SYSDATE
                            ) = EXTRACT(
                                YEAR
                                FROM
                                    ate.fecha_atencion
                            )
                            AND EXTRACT(
                                MONTH
                                FROM
                                    TO_DATE('01/10/2021', 'DD/MM/YYYY')
                            ) = EXTRACT(
                                MONTH
                                FROM
                                    ate.fecha_atencion
                            )
                        )
                        RIGHT JOIN salud sal ON (sal.sal_id = pac.sal_id)
                        RIGHT JOIN tipo_salud tsal ON (tsal.tipo_sal_id = sal.tipo_sal_id)
                    GROUP BY
                        ate.fecha_atencion
                )
        )
    GROUP BY
        sal.descripcion,
        tsal.descripcion
)
UNION
(
    SELECT
        tsal.descripcion || ',' || sal.descripcion AS "SISTEMA_SALUD",
        COUNT(ate.ate_id) AS "TOTAL ATENCIONES",
        'SIN Descuento' AS "CORRESPONDE DESCUENTO"
    FROM
        atencion ate
        INNER JOIN paciente pac ON (
            ate.pac_run = pac.pac_run
            AND EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) = EXTRACT(
                YEAR
                FROM
                    ate.fecha_atencion
            )
            AND EXTRACT(
                MONTH
                FROM
                    TO_DATE('01/10/2021', 'DD/MM/YYYY')
            ) = EXTRACT(
                MONTH
                FROM
                    ate.fecha_atencion
            )
        )
        RIGHT JOIN salud sal ON (sal.sal_id = pac.sal_id)
        RIGHT JOIN tipo_salud tsal ON (tsal.tipo_sal_id = sal.tipo_sal_id)
    HAVING
        COUNT(ate.ate_id) <= (
            SELECT
                ROUND(AVG(COUNT_ATE))
            FROM
                (
                    SELECT
                        COUNT(ate.ate_id) AS "COUNT_ATE"
                    FROM
                        atencion ate
                        INNER JOIN paciente pac ON (
                            ate.pac_run = pac.pac_run
                            AND EXTRACT(
                                YEAR
                                FROM
                                    SYSDATE
                            ) = EXTRACT(
                                YEAR
                                FROM
                                    ate.fecha_atencion
                            )
                            AND EXTRACT(
                                MONTH
                                FROM
                                    TO_DATE('01/10/2021', 'DD/MM/YYYY')
                            ) = EXTRACT(
                                MONTH
                                FROM
                                    ate.fecha_atencion
                            )
                        )
                        RIGHT JOIN salud sal ON (sal.sal_id = pac.sal_id)
                        RIGHT JOIN tipo_salud tsal ON (tsal.tipo_sal_id = sal.tipo_sal_id)
                    GROUP BY
                        ate.fecha_atencion
                )
        )
    GROUP BY
        sal.descripcion,
        tsal.descripcion
)
ORDER BY
    "SISTEMA_SALUD";

-- INFORME 2
(
    SELECT
        TO_CHAR(pac.pac_run, '09G999G999') || '-' || pac.dv_run AS "RUT PACIENTE",
        INITCAP(
            pac.pnombre || ' ' || pac.snombre || ' ' || pac.apaterno || ' ' || pac.amaterno || ' '
        ) AS "NOMBRE PACIENTE",
        ROUND(
            MONTHS_BETWEEN(SYSDATE, pac.fecha_nacimiento) / 12
        ) AS "AÑOS",
        'Le corresponde un ' || porc3edad.porcentaje_descto || '% de descuento en la primera consulta del año ' || (
            EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) + 1
        ) AS "PORCENTAJE DESCUENTO",
        'Beneficio por tercera edad' AS "OBSERVACION"
    FROM
        paciente pac
        LEFT JOIN atencion ate ON (
            pac.pac_run = ate.pac_run
            AND EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) = EXTRACT(
                YEAR
                FROM
                    ate.fecha_atencion
            )
        )
        JOIN porc_descto_3ra_edad porc3edad ON ROUND(
            MONTHS_BETWEEN(SYSDATE, pac.fecha_nacimiento) / 12
        ) BETWEEN porc3edad.anno_ini
        AND porc3edad.anno_ter
    WHERE
        ROUND(
            MONTHS_BETWEEN(SYSDATE, pac.fecha_nacimiento) / 12,
            1
        ) >= 64.5
    GROUP BY
        TO_CHAR(pac.pac_run, '09G999G999') || '-' || pac.dv_run,
        INITCAP(
            pac.pnombre || ' ' || pac.snombre || ' ' || pac.apaterno || ' ' || pac.amaterno || ' '
        ),
        pac.fecha_nacimiento,
        'Le corresponde un ' || porc3edad.porcentaje_descto || '% de descuento en la primera consulta del año ' || (
            EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) + 1
        ),
        'Beneficio por tercera edad'
    HAVING
        COUNT(ate.ate_id) > 4
)
UNION
(
    SELECT
        TO_CHAR(pac.pac_run, '09G999G999') || '-' || pac.dv_run AS "RUT PACIENTE",
        INITCAP(
            pac.pnombre || ' ' || pac.snombre || ' ' || pac.apaterno || ' ' || pac.amaterno || ' '
        ) AS "NOMBRE PACIENTE",
        ROUND(
            MONTHS_BETWEEN(SYSDATE, pac.fecha_nacimiento) / 12
        ) AS "AÑOS",
        'Le corresponde un 2% de descuento en la primera consulta del año ' || (
            EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) + 1
        ) AS "PORCENTAJE DESCUENTO",
        'Beneficio por cantidad de atenciones medicas' AS "OBSERVACION"
    FROM
        paciente pac
        LEFT JOIN atencion ate ON (
            pac.pac_run = ate.pac_run
            AND EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) = EXTRACT(
                YEAR
                FROM
                    ate.fecha_atencion
            )
        )
    WHERE
        ROUND(
            MONTHS_BETWEEN(SYSDATE, pac.fecha_nacimiento) / 12,
            1
        ) < 64.5
    GROUP BY
        TO_CHAR(pac.pac_run, '09G999G999') || '-' || pac.dv_run,
        INITCAP(
            pac.pnombre || ' ' || pac.snombre || ' ' || pac.apaterno || ' ' || pac.amaterno || ' '
        ),
        pac.fecha_nacimiento,
        'Le corresponde un 2% de descuento en la primera consulta del año ' || (
            EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) + 1
        ),
        'Beneficio por cantidad de atenciones medicas'
    HAVING
        COUNT(ate.ate_id) > 4
)
ORDER BY
    "RUT PACIENTE";

-- CASO 2
(
    SELECT
        LOWER(esp.nombre) AS "ESPECIALIDAD",
        TO_CHAR(med.med_run, '09G999G999') || '-' || med.dv_run AS "RUT",
        UPPER(
            med.apaterno || ' ' || med.amaterno || ' ' || med.pnombre || ' ' || med.snombre
        ) AS "MEDICO"
    FROM
        medico med
        INNER JOIN especialidad_medico emed ON(med.med_run = emed.med_run)
        INNER JOIN especialidad esp ON(emed.esp_id = esp.esp_id)
)
INTERSECT
(
    SELECT
        LOWER(esp.nombre) AS "ESPECIALIDAD",
        TO_CHAR(med.med_run, '09G999G999') || '-' || med.dv_run AS "RUT",
        UPPER(
            med.apaterno || ' ' || med.amaterno || ' ' || med.pnombre || ' ' || med.snombre
        ) AS "MEDICO"
    FROM
        medico med
        INNER JOIN especialidad_medico emed ON(med.med_run = emed.med_run)
        INNER JOIN especialidad esp ON(emed.esp_id = esp.esp_id)
    WHERE
        esp.esp_id IN(
            SELECT
                ate.esp_id
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
                COUNT(ate.ate_id) > 10
            GROUP BY
                ate.esp_id
        )
)
ORDER BY
    "ESPECIALIDAD" ASC,
    "MEDICO" ASC;

-- CASO 3
(
    SELECT
        uni.nombre AS "UNIDAD",
        INITCAP(
            med.apaterno || ' ' || med.amaterno || ' ' || med.pnombre || ' ' || med.snombre
        ) AS "MEDICO"
    FROM
        medico med
        INNER JOIN unidad uni ON (uni.uni_id = med.uni_id)
    WHERE
        ROUND(MONTHS_BETWEEN(SYSDATE, med.fecha_contrato) / 12) > 10
)
INTERSECT
(
    SELECT
        uni.nombre AS "UNIDAD",
        INITCAP(
            med.apaterno || ' ' || med.amaterno || ' ' || med.pnombre || ' ' || med.snombre
        ) AS "MEDICO"
    FROM
        medico med
        LEFT JOIN atencion ate ON (
            ate.med_run = med.med_run
            AND EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) -1 = EXTRACT(
                YEAR
                FROM
                    ate.fecha_atencion
            )
        )
        INNER JOIN unidad uni ON (uni.uni_id = med.uni_id)
    GROUP BY
        uni.nombre,
        INITCAP(
            med.apaterno || ' ' || med.amaterno || ' ' || med.pnombre || ' ' || med.snombre
        )
    HAVING
        COUNT(ate.ate_id) < (
            SELECT
                MAX("CONT_ATE")
            FROM
                (
                    SELECT
                        COUNT(ate.ate_id) AS "CONT_ATE"
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
        )
);

SELECT
    uni.nombre AS "UNIDAD",
    INITCAP(
        med.apaterno || ' ' || med.amaterno || ' ' || med.pnombre || ' ' || med.snombre
    ) AS "MEDICO",
    ROUND(MONTHS_BETWEEN(SYSDATE, med.fecha_contrato) / 12)
FROM
    medico med
    INNER JOIN unidad uni ON (uni.uni_id = med.uni_id)
WHERE
    ROUND(MONTHS_BETWEEN(SYSDATE, med.fecha_contrato) / 12) > 10;

-- CASO 4
-- dos annos
(
    SELECT
        TO_CHAR(ate.fecha_atencion, 'YYYY/MM') AS "AÑO Y MES",
        COUNT(ate.ate_id) AS "TOTAL DE ATENCIONES",
        TO_CHAR(SUM(ate.costo), 'L999G999G999G999') AS "VALOR TOTAL DE ATENCIONES"
    FROM
        atencion ate
    WHERE
        EXTRACT(
            YEAR
            FROM
                SYSDATE
        ) -2 = EXTRACT(
            YEAR
            FROM
                ate.fecha_atencion
        )
    GROUP BY
        TO_CHAR(ate.fecha_atencion, 'YYYY/MM')
    HAVING
        COUNT(ate.ate_id) >= 40
)
UNION
(
    SELECT
        TO_CHAR(ate.fecha_atencion, 'YYYY/MM') AS "AÑO Y MES",
        COUNT(ate.ate_id) AS "TOTAL DE ATENCIONES",
        TO_CHAR(SUM(ate.costo), 'L999G999G999G999') AS "VALOR TOTAL DE ATENCIONES"
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
        TO_CHAR(ate.fecha_atencion, 'YYYY/MM')
    HAVING
        COUNT(ate.ate_id) >= 15
)
UNION
(
    SELECT
        TO_CHAR(ate.fecha_atencion, 'YYYY/MM') AS "AÑO Y MES",
        COUNT(ate.ate_id) AS "TOTAL DE ATENCIONES",
        TO_CHAR(SUM(ate.costo), 'L999G999G999G999') AS "VALOR TOTAL DE ATENCIONES"
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
    GROUP BY
        TO_CHAR(ate.fecha_atencion, 'YYYY/MM')
    HAVING
        COUNT(ate.ate_id) >= (
            SELECT
                ROUND(AVG(CONT_ATE))
            FROM
                (
                    SELECT
                        COUNT(ate.ate_id) AS "CONT_ATE"
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
                    GROUP BY
                        EXTRACT(
                            MONTH
                            FROM
                                ate.fecha_atencion
                        )
                )
        )
)
ORDER BY
    "AÑO Y MES";

-- CASO 5
(
    SELECT
        'MEDICO CON BENEFICIO DEL 5% DE LAS GANANCIAS' AS "BONIFICACION GANANCIAS",
        TO_CHAR(med.med_run, '09G999G999') || '-' || med.dv_run AS "RUN MEDICO",
        INITCAP(
            med.pnombre || ' ' || med.snombre || ' ' || med.apaterno || ' ' || med.amaterno
        ) AS "NOMBRE MEDICO",
        COUNT(ate.ate_id) AS "TOTAL ATENCIONES",
        TO_CHAR(med.sueldo_base, 'L999G999G999') AS "SUELDO BASE",
        TO_CHAR(
            ROUND(
                (& & ganancias * 0.005) / (
                    SELECT
                        COUNT(med_run)
                    FROM
                        (
                            SELECT
                                med.med_run
                            FROM
                                medico med
                                INNER JOIN atencion ate ON (
                                    med.med_run = ate.med_run
                                    AND EXTRACT(
                                        YEAR
                                        FROM
                                            SYSDATE
                                    ) = EXTRACT(
                                        YEAR
                                        FROM
                                            ate.fecha_atencion
                                    )
                                )
                            GROUP BY
                                med.med_run
                            HAVING
                                COUNT(ate.ate_id) > 7
                        )
                )
            ),
            'L999G999G999'
        ) AS "BONIFICACION POR GANANCIAS",
        TO_CHAR(
            med.sueldo_base + ROUND(
                (& & ganancias * 0.005) / (
                    SELECT
                        COUNT(med_run)
                    FROM
                        (
                            SELECT
                                med.med_run
                            FROM
                                medico med
                                INNER JOIN atencion ate ON (
                                    med.med_run = ate.med_run
                                    AND EXTRACT(
                                        YEAR
                                        FROM
                                            SYSDATE
                                    ) = EXTRACT(
                                        YEAR
                                        FROM
                                            ate.fecha_atencion
                                    )
                                )
                            GROUP BY
                                med.med_run
                            HAVING
                                COUNT(ate.ate_id) > 7
                        )
                )
            ),
            'L999G999G999G999'
        ) AS "SUELDO TOTAL"
    FROM
        medico med
        INNER JOIN atencion ate ON (
            med.med_run = ate.med_run
            AND EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) = EXTRACT(
                YEAR
                FROM
                    ate.fecha_atencion
            )
        )
    GROUP BY
        'MEDICO CON BENEFICIO DEL 5% DE LAS GANANCIAS',
        TO_CHAR(med.med_run, '09G999G999') || '-' || med.dv_run,
        INITCAP(
            med.pnombre || ' ' || med.snombre || ' ' || med.apaterno || ' ' || med.amaterno
        ),
        med.sueldo_base
    HAVING
        COUNT(ate.ate_id) > 7
)
UNION
(
    SELECT
        'MEDICO CON BENEFICIO DEL 2% DE LAS GANANCIAS' AS "BONIFICACION GANANCIAS",
        TO_CHAR(med.med_run, '09G999G999') || '-' || med.dv_run AS "RUN MEDICO",
        INITCAP(
            med.pnombre || ' ' || med.snombre || ' ' || med.apaterno || ' ' || med.amaterno
        ) AS "NOMBRE MEDICO",
        COUNT(ate.ate_id) AS "TOTAL ATENCIONES",
        TO_CHAR(med.sueldo_base, 'L999G999G999') AS "SUELDO BASE",
        TO_CHAR(
            ROUND(
                (& & ganancias * 0.002) / (
                    SELECT
                        COUNT(med_run)
                    FROM
                        (
                            SELECT
                                med.med_run
                            FROM
                                medico med
                                INNER JOIN atencion ate ON (
                                    med.med_run = ate.med_run
                                    AND EXTRACT(
                                        YEAR
                                        FROM
                                            SYSDATE
                                    ) = EXTRACT(
                                        YEAR
                                        FROM
                                            ate.fecha_atencion
                                    )
                                )
                            GROUP BY
                                med.med_run
                            HAVING
                                COUNT(ate.ate_id) <= 7
                        )
                )
            ),
            'L999G999G999'
        ) AS "BONIFICACION POR GANANCIAS",
        TO_CHAR(
            med.sueldo_base + ROUND(
                (& & ganancias * 0.005) / (
                    SELECT
                        COUNT(med_run)
                    FROM
                        (
                            SELECT
                                med.med_run
                            FROM
                                medico med
                                INNER JOIN atencion ate ON (
                                    med.med_run = ate.med_run
                                    AND EXTRACT(
                                        YEAR
                                        FROM
                                            SYSDATE
                                    ) = EXTRACT(
                                        YEAR
                                        FROM
                                            ate.fecha_atencion
                                    )
                                )
                            GROUP BY
                                med.med_run
                            HAVING
                                COUNT(ate.ate_id) <= 7
                        )
                )
            ),
            'L999G999G999G999'
        ) AS "SUELDO TOTAL"
    FROM
        medico med
        INNER JOIN atencion ate ON (
            med.med_run = ate.med_run
            AND EXTRACT(
                YEAR
                FROM
                    SYSDATE
            ) = EXTRACT(
                YEAR
                FROM
                    ate.fecha_atencion
            )
        )
    GROUP BY
        'MEDICO CON BENEFICIO DEL 2% DE LAS GANANCIAS',
        TO_CHAR(med.med_run, '09G999G999') || '-' || med.dv_run,
        INITCAP(
            med.pnombre || ' ' || med.snombre || ' ' || med.apaterno || ' ' || med.amaterno
        ),
        med.sueldo_base
    HAVING
        COUNT(ate.ate_id) <= 7
)
ORDER BY
    "RUN MEDICO";