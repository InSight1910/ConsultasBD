--CASO 1
SELECT
    INITCAP(
        hus.appat_huesped || ' ' ||
        SUBSTR(hus.apmat_huesped, 1, 1) || '. ' ||
        hus.nom_huesped
    )
        AS "HUESPED",
    INITCAP(agen.nom_agencia)
        AS "AGENCIA",
    INITCAP(proc.nom_procedencia)
        AS "PROCEDENCIA",
    COUNT(res.id_reserva)
        AS "RESERVAS",
    TO_CHAR(SUM(con.monto), 'L999')
        AS "MONTO CONSUMOS EN DOLARES",
    TO_CHAR(SUM(con.monto * &&DOLAR), 'L999G999G999G999')
        AS "MONTO CONSUMOS EN PESOS",
    TO_CHAR(SUM(con.monto * &&DOLAR) * ((20+ COUNT(res.id_reserva))/100), 'L999G999G999G999')
        AS "MONTO CUPON DE DESCUENTO"
FROM
    huesped hus
INNER JOIN agencia agen
    ON (agen.id_agencia = hus.id_agencia)
INNER JOIN procedencia proc
    ON (proc.id_procedencia = hus.id_procedencia)
inner JOIN reserva res
    ON (res.id_huesped = hus.id_huesped)
INNER JOIN consumo con
    ON (con.id_reserva = res.id_reserva)
HAVING
    count(res.id_reserva) > 4
GROUP BY
    INITCAP(
        hus.appat_huesped || ' ' ||
        SUBSTR(hus.apmat_huesped, 1, 1) || '. ' ||
        hus.nom_huesped
    ),
    INITCAP(agen.nom_agencia),
    INITCAP(proc.nom_procedencia)
ORDER BY
    "AGENCIA",
    "RESERVAS";

-- CASO 2
SELECT
    UPPER(
        hus.appat_huesped || ' ' ||
        hus.apmat_huesped || ' ' ||
        hus.nom_huesped
    )
        AS "NOMBRE",
    res.ingreso
        AS "INGRESO",
    res.estadia,
    res.ingreso + res.estadia
        AS "SALIDA",
    TO_CHAR(SUM((hab.valor_habitacion * res.estadia) * 820), 'L999G999G999G999')
        AS "MONTO ALOJAMIENTO",
    TO_CHAR(SUM(hab.valor_minibar * 820) * res.estadia, 'L999G999G999G999')
        AS "MONTO MINIBAR",
    TO_CHAR(NVL(tour.valor_tour, 0), 'L999G999G999G999')
        AS "MONTO  TOURS",
    TO_CHAR(
    SUM((hab.valor_habitacion * res.estadia) * 820)
        +
    SUM((hab.valor_minibar * 820) * res.estadia)
        +
    NVL(SUM(tour.valor_tour), 0)
    ,
    'L999G999G999')
        AS "TOTAL A PAGAR"
FROM 
    huesped hus
INNER JOIN reserva res
    ON (res.id_huesped = hus.id_huesped)
INNER JOIN detalle_reserva detres
    ON (detres.id_reserva = res.id_reserva)
INNER JOIN habitacion hab
    ON (hab.id_habitacion = detres.id_habitacion)
LEFT JOIN huesped_tour huestour
    ON (hus.id_huesped = huestour.id_huesped)
LEFT JOIN tour tour
    ON (tour.id_tour = huestour.id_tour)
WHERE
    res.ingreso BETWEEN TO_DATE(&&FECHA_INICIO) AND TO_DATE(&&FECHA_FIN)
        AND
    res.ingreso + res.estadia BETWEEN TO_DATE(&&FECHA_INICIO) AND TO_DATE(&&FECHA_FIN)
HAVING
    (
        SUM((hab.valor_habitacion * res.estadia) * 820)
            +
        SUM((hab.valor_minibar * 820) * res.estadia)
            +
        NVL(SUM(tour.valor_tour), 0)
    ) < (
    SELECT
        ROUND(AVG(
        SUM((hab.valor_habitacion * res.estadia) * 820)
            +
        SUM((hab.valor_minibar * 820) * res.estadia)
            +
        NVL(SUM(tour.valor_tour), 0)
        ))
    FROM 
        huesped hus
    INNER JOIN reserva res
        ON (res.id_huesped = hus.id_huesped)
    INNER JOIN detalle_reserva detres
        ON (detres.id_reserva = res.id_reserva)
    INNER JOIN habitacion hab
        ON (hab.id_habitacion = detres.id_habitacion)
    LEFT JOIN huesped_tour huestour
        ON (hus.id_huesped = huestour.id_huesped)
    LEFT JOIN tour tour
        ON (tour.id_tour = huestour.id_tour)
    WHERE
        EXTRACT(YEAR FROM SYSDATE) = EXTRACT(YEAR FROM res.ingreso)
    GROUP BY
        hus.id_huesped
    )
GROUP BY
    UPPER(
        hus.appat_huesped || ' ' ||
        hus.apmat_huesped || ' ' ||
        hus.nom_huesped
    ),
    res.ingreso,
    res.estadia,
    res.ingreso + res.estadia,
    tour.valor_tour
ORDER BY
    "SALIDA",
    "TOTAL A PAGAR" DESC;
-- CASO 3
INSERT INTO  historico_clientes (
(
SELECT
    EXTRACT(YEAR FROM SYSDATE)
        AS "AGNO_PROCESO",
    hues.id_huesped,
    UPPER(
        hues.appat_huesped || ' ' ||
        hues.apmat_huesped || ' ' ||
        hues.nom_huesped
        )
        AS "NOMBRE_HUESPED",
    COUNT(res.id_reserva)
        AS "RESERVAS"
FROM
    huesped hues
INNER JOIN reserva res
    ON (res.id_huesped = hues.id_huesped)
WHERE
    EXTRACT(YEAR FROM SYSDATE) = EXTRACT(YEAR FROM res.ingreso)
GROUP BY
    EXTRACT(YEAR FROM SYSDATE),
    hues.id_huesped,
    UPPER(
        hues.appat_huesped || ' ' ||
        hues.apmat_huesped || ' ' ||
        hues.nom_huesped
        )
)
UNION
(
(
SELECT
    EXTRACT(YEAR FROM SYSDATE)-1
        AS "AGNO_PROCESO",
    hues.id_huesped,
    UPPER(
        hues.appat_huesped || ' ' ||
        hues.apmat_huesped || ' ' ||
        hues.nom_huesped
        )
        AS "NOMBRE_HUESPED",
    COUNT(res.id_reserva)
        AS "RESERVAS"
FROM
    huesped hues
INNER JOIN reserva res
    ON (res.id_huesped = hues.id_huesped)
WHERE
    EXTRACT(YEAR FROM SYSDATE)-1 = EXTRACT(YEAR FROM res.ingreso)
GROUP BY
    EXTRACT(YEAR FROM SYSDATE)-1,
    hues.id_huesped,
    UPPER(
        hues.appat_huesped || ' ' ||
        hues.apmat_huesped || ' ' ||
        hues.nom_huesped
        )
)
)
UNION
(
(
SELECT
    EXTRACT(YEAR FROM SYSDATE)-2
        AS "AGNO_PROCESO",
    hues.id_huesped,
    UPPER(
        hues.appat_huesped || ' ' ||
        hues.apmat_huesped || ' ' ||
        hues.nom_huesped
        )
        AS "NOMBRE_HUESPED",
    COUNT(res.id_reserva)
        AS "RESERVAS"
FROM
    huesped hues
INNER JOIN reserva res
    ON (res.id_huesped = hues.id_huesped)
WHERE
    EXTRACT(YEAR FROM SYSDATE)-2 = EXTRACT(YEAR FROM res.ingreso)
GROUP BY
    EXTRACT(YEAR FROM SYSDATE)-2,
    hues.id_huesped,
    UPPER(
        hues.appat_huesped || ' ' ||
        hues.apmat_huesped || ' ' ||
        hues.nom_huesped
        )
)
)
)
ORDER BY
    "ID_HUESPED";
-- B
SELECT
    egdias.id_huesped,
    egdias.nombre,
    egdias.ingreso,
    egdias.estadia,
    egdias.salida,
    CASE
        WHEN egdias.consumos = 0 THEN
            egdias.consumos
        ELSE
            egdias.consumos - (count_huesp."CONT" * 20000)
    END AS "CONSUMOS"
FROM
    egresos_dia egdias
LEFT JOIN (
    SELECT
        egdia.id_huesped,
        COUNT(res.id_reserva)
            AS "CONT"
    FROM
        huesped hues
    INNER JOIN egresos_dia egdia
        ON (egdia.id_huesped = hues.id_huesped)
    INNER JOIN reserva res
        ON (res.id_huesped = egdia.id_huesped)
    WHERE
        EXTRACT(YEAR FROM SYSDATE)-1 = EXTRACT(YEAR FROM res.ingreso)
    GROUP BY
        egdia.id_huesped
) count_huesp
    ON (egdias.id_huesped = count_huesp.id_huesped);
    
UPDATE egresos_dia eg SET 
    eg.consumos = (
SELECT
    CASE
        WHEN egdias.consumos = 0 THEN
            egdias.consumos
        ELSE
            egdias.consumos - (count_huesp."CONT" * 20000)
    END AS "CONSUMOS"
FROM
    egresos_dia egdias
LEFT JOIN (
    SELECT
        egdia.id_huesped,
        COUNT(res.id_reserva)
            AS "CONT"
    FROM
        huesped hues
    INNER JOIN egresos_dia egdia
        ON (egdia.id_huesped = hues.id_huesped)
    INNER JOIN reserva res
        ON (res.id_huesped = egdia.id_huesped)
    WHERE
        EXTRACT(YEAR FROM SYSDATE)-1 = EXTRACT(YEAR FROM res.ingreso)
    GROUP BY
        egdia.id_huesped
) count_huesp
    ON (egdias.id_huesped = count_huesp.id_huesped)
WHERE
    eg.id_huesped = egdias.id_huesped);
rollback;
select * from egresos_dia;