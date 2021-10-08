-- CASO 1

SELECT 
    TO_CHAR(cli.numrun, '09G999G999')
        || '-' || cli.dvrun 
            AS "RUN CLIENTE"
    ,INITCAP(
        cli.pnombre
        || ' '
        || cli.snombre
        || ' '
        || cli.appaterno
        || ' '
        || cli.apmaterno
    ) AS "NOMBRE CLIENTE"
    , po.nombre_prof_ofic
        AS "PROFESION/OFICIO"
    , TO_CHAR(cli.fecha_nacimiento, 'DD " de " MONTH')
        AS "DIA DE CUMPLEA�OS"
FROM
    cliente cli
INNER JOIN profesion_oficio po
    ON po.cod_prof_ofic = cli.cod_prof_ofic
WHERE
    EXTRACT(MONTH FROM ADD_MONTHS(to_date('01/08/1111'), 1)) = EXTRACT(MONTH FROM cli.fecha_nacimiento)
ORDER BY
    "DIA DE CUMPLEA�OS" ASC,
    cli.appaterno ASC;
    
-- CASO 2
SELECT
    TO_CHAR(cli.numrun, '09G999G999')
        || '-' || cli.dvrun 
            AS "RUN CLIENTE"
    ,UPPER(
        cli.pnombre
        || ' '
        || cli.snombre
        || ' '
        || cli.appaterno
        || ' '
        || cli.apmaterno
    ) AS "NOMBRE CLIENTE"
    , TO_CHAR(SUM(cc.monto_solicitado), 'L999G999G999')
    , TO_CHAR((SUM(cc.monto_solicitado) / 100000) * 1200, 'L999G999G999')
        AS "TOTAL PESOS TODOSUMA"
FROM
    cliente cli
INNER JOIN credito_cliente cc
    ON cc.nro_cliente = cli.nro_cliente
WHERE 
    EXTRACT(YEAR FROM ADD_MONTHS(SYSDATE, -12)) = EXTRACT(YEAR FROM cc.fecha_otorga_cred)
GROUP BY
    cli.pnombre,
    cli.snombre,
    cli.apmaterno,
    cli.appaterno,
    cli.numrun,
    cli.dvrun
ORDER BY
     (SUM(cc.monto_solicitado) / 100000) * 1200 ASC,
     cli.appaterno ASC;
     
     
-- CASO 3
SELECT
    TO_CHAR(cc.fecha_otorga_cred, 'MMYYYY')
        AS "MES TRANSACCION"
    , c.nombre_credito
        AS "TIPO CREDITO"
    , SUM(cc.monto_credito)
        AS "MONTO SOLICITADO CREDITO"
    , SUM(CASE
        WHEN cc.monto_credito BETWEEN 100000 AND 1000000 THEN
            cc.monto_credito * 0.01
        WHEN cc.monto_credito BETWEEN 1000001 AND 2000000 THEN
            cc.monto_credito * 0.02
        WHEN cc.monto_credito BETWEEN 2000001 AND 4000000 THEN
            cc.monto_credito * 0.03
        WHEN cc.monto_credito BETWEEN 4000001 AND 6000000 THEN
            cc.monto_credito * 0.04
        ELSE
            cc.monto_credito * 0.07
    END) AS "APORTE A LA SBIF"
FROM
    credito_cliente cc
INNER JOIN credito c
    ON c.cod_credito = cc.cod_credito
WHERE
    EXTRACT(YEAR FROM ADD_MONTHS(SYSDATE, -12)) = EXTRACT(YEAR FROM cc.fecha_otorga_cred)
GROUP BY
    TO_CHAR(cc.fecha_otorga_cred, 'MMYYYY'),
    c.nombre_credito
ORDER BY
    "MES TRANSACCION" ASC,
    "TIPO CREDITO" ASC;

-- CASO 4
SELECT
    TO_CHAR(cli.numrun, '09G999G999')
        || '-' || cli.dvrun 
            AS "RUN CLIENTE"
    ,UPPER(
        cli.pnombre
        || ' '
        || cli.snombre
        || ' '
        || cli.appaterno
        || ' '
        || cli.apmaterno
    ) AS "NOMBRE CLIENTE",
    SUM(pic.monto_total_ahorrado) AS "MONTO TOTAL AHORRADO", 
    CASE 
        WHEN SUM(pic.monto_total_ahorrado) BETWEEN 100000 AND 1000000 THEN
            'BRONCE'
        WHEN SUM(pic.monto_total_ahorrado) BETWEEN 1000001 AND 4000000 THEN
            'PLATA'
        WHEN SUM(pic.monto_total_ahorrado) BETWEEN 4000001 AND 8000000 THEN
            'SILVER'
        WHEN SUM(pic.monto_total_ahorrado) BETWEEN 8000001 AND 15000000 THEN
            'GOLD'
        WHEN SUM(pic.monto_total_ahorrado) > 15000000 THEN
            'PLATINIUM'
    END AS "CATEGORIA CLIENTE"
FROM
    cliente cli
INNER JOIN producto_inversion_cliente pic
    ON pic.nro_cliente = cli.nro_cliente
GROUP BY
    cli.pnombre,
    cli.snombre,
    cli.apmaterno,
    cli.appaterno,
    cli.numrun,
    cli.dvrun,
    cli.nro_cliente
ORDER BY
    cli.appaterno ASC,
    "MONTO TOTAL AHORRADO" desc;
    
-- CASO 5
SELECT
    EXTRACT(YEAR FROM SYSDATE)
        AS "A�O TRIBUTARIO"
    , TO_CHAR(cli.numrun, '09G999G999')
        || '-' || cli.dvrun 
            AS "RUN CLIENTE"
    , INITCAP(
        cli.pnombre
        || ' '
        || NVL(SUBSTR(cli.snombre, 1,1) || '.', '')
        || ' '
        || cli.appaterno
        || ' '
        || cli.apmaterno
    ) AS "NOMBRE CLIENTE"
    , count(pic.cod_prod_inv)
        AS "TOTAL PROD. INV AFECTOS IMPTO"
    , TO_CHAR(SUM(pic.monto_total_ahorrado), 'L999G999G999')
FROM 
    cliente cli
INNER JOIN producto_inversion_cliente pic
    ON pic.nro_cliente = producto_inversion pi
    ON pi.cod_prod_inv = pic.cod_prod_i cli.nro_cliente
INNER JOINnv
GROUP BY 
    cli.pnombre,
    cli.snombre,
    cli.apmaterno,
    cli.appaterno,
    cli.numrun,
    cli.dvrun,
    cli.nro_cliente,
    pi.nombre_prod_inv
HAVING
    pi.nombre_prod_inv LIKE 'Fondos Mutuos%' or  pi.nombre_prod_inv LIKE 'Dep%' 
ORDER BY
    cli.appaterno ASC;

-- CASO 6
-- INFORME 1
SELECT
     TO_CHAR(cli.numrun, '09G999G999')
        || '-' || UPPER(cli.dvrun)
            AS "RUN CLIENTE"
    , INITCAP(
        cli.pnombre
        || ' '
        || NVL(cli.snombre, '')
        || ' '
        || cli.appaterno
        || ' '
        || cli.apmaterno)AS "NOMBRE CLIENTE"
    , COUNT(cc.nro_solic_credito)
        AS "TOTAL CREDTOS SOLICITADOS"
    , TO_CHAR(SUM(cc.monto_solicitado), 'L999G999G999')
FROM
    cliente cli
INNER JOIN 
    credito_cliente cc
        ON cc.nro_cliente = cli.nro_cliente
WHERE
    EXTRACT(YEAR FROM ADD_MONTHS(SYSDATE, -12)) = EXTRACT(YEAR FROM cc.fecha_otorga_cred)
GROUP BY
    cli.pnombre,
    cli.snombre,
    cli.apmaterno,
    cli.appaterno,
    cli.numrun,
    cli.dvrun
ORDER BY
    cli.appaterno ASC;

-- INFORME 2
SELECT
    TO_CHAR(cli.numrun, '09G999G999')
        || '-' || UPPER(cli.dvrun)
            AS "RUN CLIENTE"
    , INITCAP(
        cli.pnombre
        || ' '
        || NVL(cli.snombre, '')
        || ' '
        || cli.appaterno
        || ' '
        || cli.apmaterno)AS "NOMBRE CLIENTE"
    ,   case
        when tm.cod_tipo_mov = 1 THEN
            mv.monto_movimiento
    end as "x"
FROM
    cliente cli
INNER JOIN
    movimiento mv
        ON mv.nro_cliente = cli.nro_cliente
INNER JOIN
    tipo_movimiento tm
        ON mv.cod_tipo_mov = tm.cod_tipo_mov
GROUP BY
    cli.nro_cliente,
    cli.pnombre,
    cli.snombre,
    cli.apmaterno,
    cli.appaterno,
    cli.numrun,
    cli.dvrun,
    tm.cod_tipo_mov,
    mv.monto_movimiento
ORDER BY
    cli.appaterno ASC;