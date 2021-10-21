SELECT * FROM cliente WHERE numrun LIKE '16%';
SELECT DISTINCT
    to_char(cli.numrun, '09G999G999')
    || '-'
    || cli.dvrun AS "RUN CLIENTE",
    initcap(cli.pnombre
            || ' '
            || cli.snombre
			|| ' '
            || cli.appaterno
            || ' '
            || cli.apmaterno) 
				AS "NOMBRE CLIENTE"
	, to_char(cli.fecha_nacimiento, 'DD" de "MONTH')
		AS "FECHA DE CUMPLEAÑOS"
	, sr.direccion || '/' || rg.nombre_region
FROM
    cliente cli
INNER JOIN comuna cm
	ON cm.cod_comuna = cli.cod_comuna
INNER JOIN sucursal_retail sr
	ON sr.cod_comuna = cli.cod_comuna
INNER JOIN region rg
	ON rg.cod_region = sr.cod_region
WHERE 
	sr.cod_region = &id_sucursal
	AND
		EXTRACT(MONTH FROM add_months(to_date('01/08/2021'), 1)) = EXTRACT(MONTH FROM cli.fecha_nacimiento);
		
-- Caso 2

SELECT
    to_char(cli.numrun, '09G999G999')
    || '-'
    || cli.dvrun AS "RUN CLIENTE",
    initcap(cli.pnombre
            || ' '
            || cli.snombre
			|| ' '
            || cli.appaterno
            || ' '
            || cli.apmaterno) 
				AS "NOMBRE CLIENTE"
	, TO_CHAR(SUM(ttc.monto_transaccion),'L999G999G999')
		AS "MONTO TOTAL C/A/S.A"
	, TO_CHAR(ROUND((SUM(ttc.monto_transaccion) /10000)*250), '999G999G999')
		AS "TOTAL PUNTOS ACUMULADOS"
FROM
    cliente cli
INNER JOIN tarjeta_cliente tc
	ON tc.numrun = cli.numrun
INNER JOIN transaccion_tarjeta_cliente ttc
	ON ttc.nro_tarjeta = tc.nro_tarjeta
WHERE	
	EXTRACT(YEAR FROM add_months(sysdate, -12)) = EXTRACT(YEAR FROM ttc.fecha_transaccion)
GROUP BY
	cli.numrun,
	cli.dvrun,
	cli.pnombre,
	cli.snombre,
	cli.appaterno,
	cli.apmaterno
ORDER BY
	"TOTAL PUNTOS ACUMULADOS" ASC,
	cli.appaterno ASC;

-- Caso 3
SELECT
	TO_CHAR(ttc.fecha_transaccion, 'MMYYYY')
	, ttt.nombre_tptran_tarjeta
	, TO_CHAR(SUM(ttc.monto_total_transaccion), 'L999G999G999') AS "MONTO AVANCE"
	, TO_CHAR(SUM(ttc.monto_total_transaccion * (asb.porc_aporte_sbif /100)), 'L999G999G999')
FROM
	transaccion_tarjeta_cliente ttc
INNER JOIN tipo_transaccion_tarjeta ttt
	ON ttt.cod_tptran_tarjeta = ttc.cod_tptran_tarjeta
JOIN aporte_sbif asb
	ON (ttc.monto_total_transaccion BETWEEN asb.monto_inf_av_sav AND asb.monto_sup_av_sav)
WHERE
	EXTRACT(YEAR FROM sysdate) = EXTRACT(YEAR FROM ttc.fecha_transaccion)
	AND
	ttt.nombre_tptran_tarjeta LIKE '%Avance%'
GROUP BY
	ttt.nombre_tptran_tarjeta,
	TO_CHAR(ttc.fecha_transaccion, 'MMYYYY');
	
-- Caso 4

SELECT
	TO_CHAR(ttc.fecha_transaccion , 'MMYYYY')
		AS "MES TRASACCION",
	ttt.nombre_tptran_tarjeta
		AS "TIPO TRANSACCION",
	SUM(ttc.monto_total_transaccion)
		AS "MONTO AVANCES/S.AVANCES",
	ROUND(SUM(ttc.monto_total_transaccion) * (asb.porc_aporte_sbif /100))
FROM
	transaccion_tarjeta_cliente ttc
INNER JOIN tipo_transaccion_tarjeta ttt
	ON (ttt.cod_tptran_tarjeta = ttc.cod_tptran_tarjeta)
JOIN aporte_sbif asb
	ON ttc.monto_total_transaccion BETWEEN asb.monto_inf_av_sav and asb.monto_sup_av_sav
WHERE 
	EXTRACT(YEAR FROM SYSDATE) = EXTRACT(YEAR FROM ttc.fecha_transaccion)
		AND
	ttt.nombre_tptran_tarjeta LIKE '%Avance%'
GROUP BY 
	ttt.nombre_tptran_tarjeta,
	TO_CHAR(ttc.fecha_transaccion , 'MMYYYY'),
	asb.porc_aporte_sbif 
ORDER BY
	"MES TRASACCION" ASC,
	ttt.nombre_tptran_tarjeta;
	
-- Caso 4

SELECT
	TO_CHAR(cli.numrun, '09G999G999') || 
		'-' ||
		cli.dvrun 	AS "RUN CLIENTE",
	UPPER(
		cli.pnombre || ' ' ||
		cli.snombre || ' ' ||
		cli.appaterno || ' ' ||
		cli.apmaterno
	) AS "NOMBRE CLIENTE",
	SUM(NVL(ttc.monto_total_transaccion, 0))
		AS "MONTO TOTAL",
	CASE
            WHEN SUM(NVL(ttc.monto_total_transaccion,0)) >= 15000000 THEN 'PLATINUM'
            WHEN SUM(NVL(ttc.monto_total_transaccion,0)) >= 8000001 THEN 'GOLD'
            WHEN SUM(NVL(ttc.monto_total_transaccion,0)) >= 4000001 THEN 'SILVER'
            WHEN SUM(NVL(ttc.monto_total_transaccion,0)) >= 1000001 THEN 'PLATA'
            WHEN SUM(NVL(ttc.monto_total_transaccion,0)) >= 100000 THEN 'BRONCE'
            WHEN SUM(NVL(ttc.monto_total_transaccion,0)) >= 0 THEN 'SINCATEGORIZACION'
    END AS "CATEGORIZACIÓN DEL CLIENTE"
FROM
	cliente cli
INNER JOIN tarjeta_cliente tc
	ON cli.numrun = tc.numrun
LEFT JOIN transaccion_tarjeta_cliente ttc
	ON (ttc.nro_tarjeta = tc.nro_tarjeta)
GROUP BY
	cli.numrun,
	cli.dvrun,
	cli.pnombre,
	cli.snombre,
	cli.appaterno,
	cli.apmaterno
ORDER BY
	cli.appaterno ASC,
	"MONTO TOTAL" DESC;
	
-- Caso 5

SELECT
	TO_CHAR(cli.numrun, '09G999G999') || 
		'-' ||
		cli.dvrun 	AS "RUN CLIENTE",
	INITCAP(
		cli.pnombre || ' ' ||
		SUBSTR(cli.snombre, 1,1) || '. ' ||
		cli.appaterno || ' ' ||
		cli.apmaterno
	) AS "NOMBRE CLIENTE",
	COUNT(ttc.nro_transaccion)
		AS "TOTAL SUPER AVANCES",
	TO_CHAR(SUM(ttc.monto_total_transaccion), 'L999G999G999')
		AS "MONTO TOTAL SUPER AVANCE"
FROM
	cliente cli
INNER JOIN tarjeta_cliente tc
	ON cli.numrun = tc.numrun
INNER JOIN transaccion_tarjeta_cliente ttc
	ON (ttc.nro_tarjeta = tc.nro_tarjeta)
INNER JOIN tipo_transaccion_tarjeta ttt
	ON (ttt.cod_tptran_tarjeta = ttc.cod_tptran_tarjeta)
WHERE
	ttt.cod_tptran_tarjeta = 103
GROUP BY
	cli.numrun,
	cli.dvrun,
	cli.pnombre,
	cli.snombre,
	cli.appaterno,
	cli.apmaterno
ORDER BY
	cli.appaterno ASC;