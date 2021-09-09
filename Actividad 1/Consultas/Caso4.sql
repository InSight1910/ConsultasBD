SELECT
    nro_propiedad "NUMERO PROPIEDAD",
    numrut_prop "RUT PROPIEDAD",
    direccion_propiedad "DIRECCION",
    valor_arriendo "VALOR ARRIENDO",
    valor_arriendo * .054 "VALOR COMPENSACION"
FROM 
    propiedad

ORDER BY
    numrut_prop ASC;
