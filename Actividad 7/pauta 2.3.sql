--caso 1
SELECT
    TO_CHAR(cli.numrun, '09G999G999') || '-' || cli.dvrun AS "RUN CLIENTE",
    INITCAP(
        cli.pnombre || ' ' || cli.snombre || ' ' || cli.appaterno || ' ' || cli.apmaterno
    ) AS "NOMBRE CLIENTE",
    TO_CHAR(cli.fecha_nacimiento, 'dd" de "Month') AS "FECHA DE NACIMIENTO",
    INITCAP(suc.direccion) || '/' || UPPER(reg.nombre_region) AS "Direccion Sucursal/REGION SUCURSAL"
FROM
    cliente cli
    INNER JOIN region reg ON(cli.cod_region = reg.cod_region)
    INNER JOIN sucursal_retail suc ON(
        suc.cod_region = reg.cod_region
        AND suc.cod_comuna = cli.cod_comuna
        AND suc.cod_provincia = cli.cod_provincia
        AND suc.cod_region = cli.cod_region
    )
WHERE
    EXTRACT(
        MONTH
        FROM
            cli.fecha_nacimiento
    ) = EXTRACT(
        MONTH
        FROM
            ADD_MONTHS(SYSDATE, 1)
    )
ORDER BY
    "FECHA DE NACIMIENTO" ASC,
    cli.appaterno;

--caso 2
SELECT
    TO_CHAR(cli.numrun, '09G999G999') || '-' || cli.dvrun AS "RUN CLIENTE",
    UPPER(
        cli.pnombre || ' ' || cli.snombre || ' ' || cli.appaterno || ' ' || cli.apmaterno
    ) AS "NOMBRE CLIENTE",
    TO_CHAR(SUM(ttcli.monto_transaccion), '$999G999G999') AS "MONTOS COMPRAS/AVANCES/S.AVANCES",
    TO_CHAR(
        ROUND(SUM(ttcli.monto_transaccion) / 10000, 0) * 250,
        '999G999G999'
    ) AS "TOTAL PUNTOS ACUMULADOS"
FROM
    cliente cli
    INNER JOIN tarjeta_cliente tcli ON(cli.numrun = tcli.numrun)
    INNER JOIN transaccion_tarjeta_cliente ttcli ON(tcli.nro_tarjeta = ttcli.nro_tarjeta)
WHERE
    EXTRACT(
        YEAR
        FROM
            ttcli.fecha_transaccion
    ) = EXTRACT(
        YEAR
        FROM
            ADD_MONTHS(SYSDATE, -12)
    )
GROUP BY
    TO_CHAR(cli.numrun, '09G999G999') || '-' || cli.dvrun,
    UPPER(
        cli.pnombre || ' ' || cli.snombre || ' ' || cli.appaterno || ' ' || cli.apmaterno
    ),
    cli.appaterno
ORDER BY
    "TOTAL PUNTOS ACUMULADOS" ASC,
    cli.appaterno ASC;

--caso 3
SELECT
    TO_CHAR(ttcli.fecha_transaccion, 'mmyyyy') AS "MES TRANSACCI�N",
    INITCAP(tttar.nombre_tptran_tarjeta) AS "TIPO TRANSACCI�N",
    TO_CHAR(
        SUM(ttcli.monto_total_transaccion),
        '$999G999G999'
    ) AS "MONTO AVANCES/SUPER AVANCES",
    TO_CHAR(
        ROUND(
            SUM(
                ttcli.monto_total_transaccion *(ap.porc_aporte_sbif / 100)
            ),
            0
        ),
        '$999G999G999'
    ) AS "APORTE A LA SBIF"
FROM
    transaccion_tarjeta_cliente ttcli
    RIGHT JOIN tipo_transaccion_tarjeta tttar ON(
        ttcli.cod_tptran_tarjeta = tttar.cod_tptran_tarjeta
    )
    INNER JOIN aporte_sbif ap ON(
        ttcli.monto_total_transaccion BETWEEN ap.monto_inf_av_sav
        AND ap.monto_sup_av_sav
    )
WHERE
    tttar.cod_tptran_tarjeta IN(102, 103)
GROUP BY
    TO_CHAR(ttcli.fecha_transaccion, 'mmyyyy'),
    INITCAP(tttar.nombre_tptran_tarjeta)
ORDER BY
    "MES TRANSACCI�N" ASC,
    "TIPO TRANSACCI�N" ASC;

--caso 4 
SELECT
    TO_CHAR(cli.numrun, '09G999G999') || '-' || cli.dvrun AS "RUN CLIENTE",
    REPLACE(
        UPPER(
            cli.pnombre || ' ' || cli.snombre || ' ' || cli.appaterno || ' ' || cli.apmaterno
        ),
        '  ',
        ' '
    ) AS "NOMBRE CLIENTE",
    TO_CHAR(
        NVL(SUM(ttcli.monto_transaccion), 0),
        '$999G999G999'
    ) AS "COMPRAS/AVANCES/S.AVANCES",
CASE
        WHEN NVL(SUM(ttcli.monto_transaccion), 0) BETWEEN 0
        AND 100000 THEN 'SIN CATEGORIZACION'
        WHEN NVL(SUM(ttcli.monto_transaccion), 0) BETWEEN 100001
        AND 1000000 THEN 'BRONCE'
        WHEN NVL(SUM(ttcli.monto_transaccion), 0) BETWEEN 1000001
        AND 4000000 THEN 'PLATA'
        WHEN NVL(SUM(ttcli.monto_transaccion), 0) BETWEEN 4000001
        AND 8000000 THEN 'SILVER'
        WHEN NVL(SUM(ttcli.monto_transaccion), 0) BETWEEN 8000001
        AND 15000000 THEN 'GOLD'
        ELSE 'PLATINUM'
    END AS "CATEGORIA DEL CLIENTE"
FROM
    cliente cli
    LEFT JOIN tarjeta_cliente tcli ON(cli.numrun = tcli.numrun)
    LEFT JOIN transaccion_tarjeta_cliente ttcli ON(tcli.nro_tarjeta = ttcli.nro_tarjeta)
    AND(
        EXTRACT(
            YEAR
            FROM
                ttcli.fecha_transaccion
        ) = EXTRACT(
            YEAR
            FROM
                SYSDATE
        ) -1
    )
GROUP BY
    TO_CHAR(cli.numrun, '09G999G999') || '-' || cli.dvrun,
    REPLACE(
        UPPER(
            cli.pnombre || ' ' || cli.snombre || ' ' || cli.appaterno || ' ' || cli.apmaterno
        ),
        '  ',
        ' '
    ),
    cli.appaterno
ORDER BY
    cli.appaterno ASC,
    "COMPRAS/AVANCES/S.AVANCES" DESC;

--caso 5
SELECT
    TO_CHAR(cli.numrun, '09G999G999') || '-' || cli.dvrun AS "RUN CLIENTE",
    REPLACE(
        INITCAP(
            cli.pnombre || ' ' || SUBSTR(cli.snombre, 1, 1) || '. ' || cli.appaterno || ' ' || cli.apmaterno
        ),
        ' . ',
        ' '
    ) AS "NOMBRE CLIENTE",
    COUNT(ttcli.nro_transaccion) AS "TOTAL SUPER AVANCES VIGENTES",
    TO_CHAR(SUM(ttcli.monto_transaccion), '$999G999G999') AS "MONTO TOTAL SUPER AVANCES"
FROM
    cliente cli
    INNER JOIN tarjeta_cliente tcli ON(cli.numrun = tcli.numrun)
    INNER JOIN transaccion_tarjeta_cliente ttcli ON(tcli.nro_tarjeta = ttcli.nro_tarjeta)
    INNER JOIN tipo_transaccion_tarjeta tttar ON(
        ttcli.cod_tptran_tarjeta = tttar.cod_tptran_tarjeta
    )
WHERE
    tttar.cod_tptran_tarjeta = 103
    AND EXTRACT(
        YEAR
        FROM
            SYSDATE
    ) = EXTRACT(
        YEAR
        FROM
            ttcli.fecha_transaccion
    )
GROUP BY
    TO_CHAR(cli.numrun, '09G999G999') || '-' || cli.dvrun,
    REPLACE(
        INITCAP(
            cli.pnombre || ' ' || SUBSTR(cli.snombre, 1, 1) || '. ' || cli.appaterno || ' ' || cli.apmaterno
        ),
        ' . ',
        ' '
    ),
    cli.appaterno
ORDER BY
    cli.appaterno ASC;

--caso 6
--INFORME 1
SELECT
    TO_CHAR(cli.numrun, '09G999G999') || '-' || cli.dvrun AS "RUN CLIENTE",
    REPLACE(
        INITCAP(
            cli.pnombre || ' ' || SUBSTR(cli.snombre, 1, 1) || '. ' || cli.appaterno || ' ' || cli.apmaterno
        ),
        ' . ',
        ' '
    ) AS "NOMBRE CLIENTE",
    suc.direccion AS "DIRECCION",
    prov.nombre_provincia AS "PROVINCIA",
    reg.nombre_region AS "REGION" --compras
,
    COUNT(NULLIF(NULLIF(ttcli.cod_tptran_tarjeta, 102), 103)) AS "COMPRAS VIGENTES",
    TO_CHAR(
        SUM(
            DECODE(
                ttcli.cod_tptran_tarjeta,
                101,
                ttcli.monto_total_transaccion,
                0
            )
        ),
        '$999G999G999'
    ) AS "MONTO TOTAL COMPRAS" --avances
,
    COUNT(NULLIF(NULLIF(ttcli.cod_tptran_tarjeta, 101), 103)) AS "AVANCES VIGENTES",
    TO_CHAR(
        SUM(
            DECODE(
                ttcli.cod_tptran_tarjeta,
                102,
                ttcli.monto_total_transaccion,
                0
            )
        ),
        '$999G999G999'
    ) AS "MONTO TOTAL AVANCES" --super avances
,
    COUNT(NULLIF(NULLIF(ttcli.cod_tptran_tarjeta, 101), 102)) AS "SUPER AVANCES VIGENTES",
    TO_CHAR(
        SUM(
            DECODE(
                ttcli.cod_tptran_tarjeta,
                103,
                ttcli.monto_total_transaccion,
                0
            )
        ),
        '$999G999G999'
    ) AS "MONTO TOTAL SUPER AVANCES"
FROM
    cliente cli
    INNER JOIN region reg ON(cli.cod_region = reg.cod_region)
    INNER JOIN sucursal_retail suc ON(
        suc.cod_region = reg.cod_region
        AND suc.cod_comuna = cli.cod_comuna
        AND suc.cod_provincia = cli.cod_provincia
        AND suc.cod_region = cli.cod_region
    )
    INNER JOIN provincia prov ON(
        cli.cod_provincia = prov.cod_provincia
        AND suc.cod_provincia = prov.cod_provincia
        AND prov.cod_region = reg.cod_region
        AND prov.cod_region = cli.cod_region
        AND prov.cod_region = suc.cod_region
    )
    LEFT JOIN tarjeta_cliente tcli ON(cli.numrun = tcli.numrun)
    LEFT JOIN transaccion_tarjeta_cliente ttcli ON(
        ttcli.nro_tarjeta = tcli.nro_tarjeta
        AND EXTRACT(
            YEAR
            FROM
                ttcli.fecha_transaccion
        ) = & annio
    )
GROUP BY
    TO_CHAR(cli.numrun, '09G999G999') || '-' || cli.dvrun,
    REPLACE(
        INITCAP(
            cli.pnombre || ' ' || SUBSTR(cli.snombre, 1, 1) || '. ' || cli.appaterno || ' ' || cli.apmaterno
        ),
        ' . ',
        ' '
    ),
    suc.direccion,
    prov.nombre_provincia,
    reg.nombre_region,
    suc.id_sucursal,
    cli.appaterno
ORDER BY
    reg.nombre_region ASC,
    suc.id_sucursal ASC,
    cli.appaterno ASC;

--INFORME 2
SELECT
    suc.id_sucursal AS "ID_SUCURSAL",
    suc.direccion AS "DIRECCION",
    prov.nombre_provincia AS "PROVINCIA",
    reg.nombre_region AS "REGION",
    suc.direccion AS "DIRECCION" --compras
,
    COUNT(NULLIF(NULLIF(ttcli.cod_tptran_tarjeta, 102), 103)) AS "COMPRAS VIGENTES",
    TO_CHAR(
        SUM(
            DECODE(
                ttcli.cod_tptran_tarjeta,
                101,
                ttcli.monto_total_transaccion,
                0
            )
        ),
        '$999G999G999'
    ) AS "MONTO TOTAL COMPRAS" --avances
,
    COUNT(NULLIF(NULLIF(ttcli.cod_tptran_tarjeta, 101), 103)) AS "AVANCES VIGENTES",
    TO_CHAR(
        SUM(
            DECODE(
                ttcli.cod_tptran_tarjeta,
                102,
                ttcli.monto_total_transaccion,
                0
            )
        ),
        '$999G999G999'
    ) AS "MONTO TOTAL AVANCES" --super avances
,
    COUNT(NULLIF(NULLIF(ttcli.cod_tptran_tarjeta, 101), 102)) AS "SUPER AVANCES VIGENTES",
    TO_CHAR(
        SUM(
            DECODE(
                ttcli.cod_tptran_tarjeta,
                103,
                ttcli.monto_total_transaccion,
                0
            )
        ),
        '$999G999G999'
    ) AS "MONTO TOTAL SUPER AVANCES"
FROM
    cliente cli
    INNER JOIN region reg ON(cli.cod_region = reg.cod_region)
    INNER JOIN sucursal_retail suc ON(
        suc.cod_region = reg.cod_region
        AND suc.cod_comuna = cli.cod_comuna
        AND suc.cod_provincia = cli.cod_provincia
        AND suc.cod_region = cli.cod_region
    )
    INNER JOIN provincia prov ON(
        cli.cod_provincia = prov.cod_provincia
        AND suc.cod_provincia = prov.cod_provincia
        AND prov.cod_region = reg.cod_region
        AND prov.cod_region = cli.cod_region
        AND prov.cod_region = suc.cod_region
    )
    LEFT JOIN tarjeta_cliente tcli ON(cli.numrun = tcli.numrun)
    LEFT JOIN transaccion_tarjeta_cliente ttcli ON(
        ttcli.nro_tarjeta = tcli.nro_tarjeta
        AND EXTRACT(
            YEAR
            FROM
                ttcli.fecha_transaccion
        ) = & annio
    )
GROUP BY
    suc.id_sucursal,
    suc.direccion,
    prov.nombre_provincia,
    reg.nombre_region,
    suc.id_sucursal
ORDER BY
    reg.nombre_region ASC,
    suc.id_sucursal ASC;