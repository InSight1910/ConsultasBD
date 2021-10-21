SELECT
    tps.descripcion||','||s.descripcion AS "SISTEMA SALUD",
    COUNT(at.ate_id) AS "TOTAL ATENCIONES"
FROM
     atencion at
     INNER JOIN paciente pcte ON (at.pac_run=pcte.pac_run)
     INNER JOIN salud s ON (pcte.sal_id=s.sal_id)
     INNER JOIN tipo_salud tps on (s.tipo_sal_id=tps.tipo_sal_id)
WHERE
    EXTRACT(MONTH FROM fecha_atencion) = EXTRACT(MONTH FROM SYSDATE) - 1
    AND EXTRACT(YEAR FROM fecha_atencion) = EXTRACT(YEAR FROM SYSDATE)
    AND tps.descripcion in ('Fonasa', 'Isapre')
GROUP BY
    tps.descripcion,
    s.descripcion
HAVING
    COUNT(at.ate_id) > (SELECT
							 ROUND(AVG(CANT_ATE)) AS "PROMEDIO"
						FROM
							(SELECT
								ate.fecha_atencion AS "FECHA_ATENCION",
								COUNT(ate.ate_id) AS "CANT_ATE"
						FROM
								atencion ate
						 WHERE
							EXTRACT(MONTH FROM fecha_atencion) = EXTRACT(MONTH FROM SYSDATE) - 1
							AND EXTRACT(YEAR FROM fecha_atencion) = EXTRACT(YEAR FROM SYSDATE)
						GROUP BY
								ate.fecha_atencion))
ORDER BY
    "SISTEMA SALUD" ASC;
-- INFORME 2
SELECT
	TO_CHAR(pac.pac_run, '09G999G999') || '-' || pac.dv_run
		AS "RUN PACIENTE",
	INITCAP(
		pac.pnombre || ' ' ||
		pac.snombre || ' ' ||
		pac.apaterno || ' ' ||
		pac.amaterno
		) 
			AS "NOMBRE PACIENTE",
	ROUND((MONTHS_BETWEEN(SYSDATE, fecha_nacimiento) / 12))
		AS "EDAD",
	'Le corresponde  un ' || porc.porcentaje_descto || '% de descuento en la primera consulata medica del año ' || (EXTRACT(YEAR FROM SYSDATE) + 1)
FROM
	paciente pac
JOIN porc_descto_3ra_edad porc
	ON ROUND((MONTHS_BETWEEN(SYSDATE, fecha_nacimiento) / 12)) BETWEEN porc.anno_ini AND porc.anno_ter
WHERE
	TRUNC((MONTHS_BETWEEN(SYSDATE, fecha_nacimiento) / 12),1) >= 64.5
		AND
	pac.pac_run IN (
		SELECT
			pac_run AS "PAC_RUN"
		FROM
			atencion ate
		WHERE
			EXTRACT(YEAR FROM SYSDATE) = EXTRACT(YEAR FROM ate.fecha_atencion)
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
		md.pnombre || ' ' ||
		md.snombre || ' ' ||
		md.apaterno || ' ' ||
		md.amaterno
		)
			AS "MEDICO"
FROM
	medico md
INNER JOIN especialidad_medico em
	ON (em.med_run = md.med_run)
INNER JOIN especialidad es
	ON (es.esp_id = em.esp_id)
WHERE
	md.med_run IN (
				SELECT
					ate.med_run AS "PAC_RUN"
				FROM
					atencion ate
				WHERE
					EXTRACT(YEAR FROM SYSDATE)-1 = EXTRACT(YEAR FROM ate.fecha_atencion)
				HAVING
					COUNT(ate.ate_id) < 10
				GROUP BY
					ate.med_run)
ORDER BY
	"ESPECIALIDAD",
	"RUT";
	
	
	
	
SELECT
	ate.med_run AS "PAC_RUN"
FROM
	atencion ate
WHERE
	EXTRACT(YEAR FROM SYSDATE)-1 = EXTRACT(YEAR FROM ate.fecha_atencion)
HAVING
	COUNT(ate.ate_id) < 10
GROUP BY
	ate.med_run