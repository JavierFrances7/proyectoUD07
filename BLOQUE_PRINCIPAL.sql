DECLARE 

v_beneficio_total NUMBER(10,2);

v_importegastado NUMBER(10,2);

BEGIN

--FÓRMULA QUE CALCULA EL BENEFICIO NETO DE UN AÑO SOLICITADO
v_beneficio_total:=function_facturacion_total('2021')-function_total_prod_vendidos('2021')*2.5; 


v_importegastado:= FUNCTION_GASTADO_PERIODO('cliente1@gmail.com', '9/04/21', '13/04/21');


DBMS_OUTPUT.PUT_LINE ('EN EL AÑO ELEGIDO HEMOS VENDIDO UN TOTAL DE ' || function_total_prod_vendidos('2021') || ' POSTERS');
DBMS_OUTPUT.PUT_LINE('+------------------------------------------------------------------------+');
DBMS_OUTPUT.PUT_LINE ('EN EL AÑO SOLICITADO HEMOS GENERADO UN TOTAL DE  ' || function_facturacion_total('2021') || '€');
DBMS_OUTPUT.PUT_LINE('+------------------------------------------------------------------------+');
DBMS_OUTPUT.PUT_LINE ('EL BENEFICIO TOTAL PARA EL AÑO ESTABLECIDO ES DE ' || v_beneficio_total || '€');
DBMS_OUTPUT.PUT_LINE('+------------------------------------------------------------------------+');
DBMS_OUTPUT.PUT_LINE ('EL IMPORTE GASTADO POR EL CLIENTE ES DE ' || v_importegastado || '€');
DBMS_OUTPUT.PUT_LINE('+------------------------------------------------------------------------+');



END;
/

EXECUTE proc_top3_ped_gratis('9/04/21', '13/04/21');

EXECUTE proc_actu_precio_stock('HULK', 20, 500);