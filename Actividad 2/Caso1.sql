/* Informe 1 */
SELECT
    fecha_entrega_propiedad
FROM
    propiedad
WHERE 
    fecha_entrega_propiedad like '%&fecha';

/* Informe 2 */
SELECT
    fecini_arriendo
FROM
    propiedad_arrendada
WHERE 
    fecini_arriendo like '%&fecha';