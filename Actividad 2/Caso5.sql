SELECT
    nro_propiedad
        AS "NUMERO PROPIEDAD",
    TO_CHAR(fecha_entrega_propiedad, 'DD/MM/YYYY')
        AS "FECHA ENTREGA PROPIEDAD",
    direccion_propiedad
        AS "DIRECCION",
    superficie
        AS "SUPERFICIE",
    nro_dormitorios
        AS "CANTIDAD DE DORMITORIOS",
    nro_banos
        AS "CANTIDAD DE BAÑOS",
    valor_arriendo
        AS "VALOR DE ARRIENDO"
FROM
    propiedad
WHERE
    fecha_entrega_propiedad LIKE '%&fecha'
ORDER BY
    fecha_entrega_propiedad ASC;
    
DROP TABLE DET_PROPIEDADES_ARRIENDO_VENTA;
CREATE TABLE DET_PROPIEDADES_ARRIENDO_VENTA
    AS SELECT
    nro_propiedad
        AS "NUMERO PROPIEDAD",
    TO_CHAR(fecha_entrega_propiedad, 'DD/MM/YYYY')
        AS "FECHA ENTREGA PROPIEDAD",
    direccion_propiedad
        AS "DIRECCION",
    superficie
        AS "SUPERFICIE",
    nro_dormitorios
        AS "CANTIDAD DE DORMITORIOS",
    nro_banos
        AS "CANTIDAD DE BAÑOS",
    valor_arriendo
        AS "VALOR DE ARRIENDO"
FROM
    propiedad
WHERE
    fecha_entrega_propiedad LIKE '%&fecha'
ORDER BY
    fecha_entrega_propiedad ASC;
    
SELECT * FROM det_propiedades_arriendo_venta;
