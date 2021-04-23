--SCRIPT EJECUTABLE PARA PROGRAMAR LA BASE DE DATOS
--TRIGGERS

--TRIGGER QUE PROTEGE LA INTEGRIDAD DE LA TABLA AUDITORIA_FACTURAS PARA POSIBLES MODIFICACIONES NO DESEADAS
CREATE OR REPLACE TRIGGER trigger_seguridad_aud_fac
 BEFORE UPDATE OR DELETE ON auditoria_facturas
BEGIN
 IF USER NOT IN ('SYSTEM','SYS', 'SYSDBA') THEN
    RAISE_APPLICATION_ERROR(-20002,'Lo siento no puedes modificar la tabla "AUDITORIA FACTURAS", ya que no tienes permisos para ello');
 END IF;
END trigger_seguridad_aud_fac;
/

--TRIGGER QUE PROTEGE LA INTEGRIDAD DE LA TABLA AUDITORIA_PEDIDOS PARA POSIBLES MODIFICACIONES NO DESEADAS
CREATE OR REPLACE TRIGGER trigger_seguridad_aud_ped
 BEFORE UPDATE OR DELETE ON auditoria_pedidos
BEGIN
 IF USER NOT IN ('SYSTEM','SYS', 'SYSDBA') THEN
    RAISE_APPLICATION_ERROR(-20003,'Lo siento no puedes modificar la tabla "AUDITORIA PEDIDOS", ya que no tienes permisos para ello');
 END IF;
END trigger_seguridad_aud_ped;
/

--TRIGGER AUDITORIA PARA LA TABLA CLIENTE

CREATE OR REPLACE TRIGGER trigger_auditoria_pedido 
  AFTER DELETE OR INSERT OR UPDATE ON PEDIDO
  FOR EACH ROW
DECLARE
    v_usuario varchar2(100);
    v_fecha date;
    v_accion_realizada varchar2(25);
BEGIN
    SELECT sysdate INTO v_fecha from dual;
    SELECT user INTO v_usuario FROM dual;
    
    IF INSERTING THEN 
        v_accion_realizada:='INSERT';
        
    ELSIF DELETING THEN 
        v_accion_realizada:='DELETE';       
        
    ELSE
        v_accion_realizada:='UPDATE';          
        
        INSERT INTO AUDITORIA_PEDIDOS (usuario_auditoria,accion_realizada, datos_antiguos, datos_nuevos,fecha_auditoria)
        values(v_usuario,v_accion_realizada,:old.cod_pedido ||' '|| :old.correo_electronico||' '|| :old.nombre_descuento||' '|| :old.direccion||' '|| :old.precio_envio||' '|| :old.importe_total,
        :new.cod_pedido ||' '|| :new.correo_electronico||' '|| :new.nombre_descuento||' '|| :new.direccion||' '|| :new.precio_envio||' '|| :new.importe_total ,v_fecha);
    
    END IF; 
END;
/

--TRIGGER AUDITORIA PARA LA TABLA FACTURA

CREATE OR REPLACE TRIGGER trigger_auditoria_factura
  AFTER DELETE OR INSERT OR UPDATE ON FACTURA
  FOR EACH ROW
DECLARE
    v_usuario varchar2(100);
    v_fecha date;
    v_accion_realizada varchar2(25);
BEGIN
    SELECT sysdate INTO v_fecha from dual;
    SELECT user INTO v_usuario FROM dual;
    
    IF INSERTING THEN 
        v_accion_realizada:='INSERT';
        
    ELSIF DELETING THEN 
         v_accion_realizada:='DELETE';       
        
    ELSE
        v_accion_realizada:='UPDATE';          
        
    INSERT INTO AUDITORIA_PEDIDOS (usuario_auditoria,accion_realizada, datos_antiguos, datos_nuevos,fecha_auditoria)
        values(v_usuario,v_accion_realizada,:old.numero_factura ||' '|| :old.cod_pedido||' '|| :old.importe_total||' '|| :old.nombre_facturacion||' '|| :old.direccion_facturacion,
        :new.numero_factura ||' '|| :new.cod_pedido||' '|| :new.importe_total||' '|| :new.nombre_facturacion||' '|| :new.direccion_facturacion,v_fecha);
    
    END IF; 
END;
/

--TRIGGER NECESARIO QUE ACTUALIZA EL STOCK DISPONIBLE CUANDO SE REALIZA UN PEDIDO NUEVO

CREATE OR REPLACE TRIGGER trigger_actualiza_stock
    AFTER INSERT OR UPDATE ON producto_pedido
FOR EACH ROW

BEGIN

    UPDATE producto set stock = stock - :new.cantidad WHERE nombre_producto=:new.nombre_producto AND stock>:new.cantidad;

EXCEPTION WHEN OTHERS THEN

DBMS_OUTPUT.PUT_LINE ('El stock no es suficiente');

END;
/

--FUNCIONES

--FUNCION QUE RETORNA LA FACTURACION TOTAL DE UN AÑO
CREATE OR REPLACE FUNCTION function_facturacion_total (anio VARCHAR2)
return number
AS
v_total_facturacion_anual NUMBER(10);
v_total_pedidos NUMBER(10);

BEGIN
SELECT SUM(importe_total)INTO v_total_facturacion_anual
FROM PEDIDO
WHERE TO_CHAR(FECHA_PEDIDO, 'YYYY') = anio;

RETURN v_total_facturacion_anual;

END;
/

--FUNCION QUE RETORNA EL NUMERO DE PRODUCTOS VENDIDOS EN UN AÑO SELECCIONADO

CREATE OR REPLACE FUNCTION function_total_prod_vendidos (anio VARCHAR2)
return number
AS
v_total_productos NUMBER(10);

BEGIN
SELECT DISTINCT SUM(PP.CANTIDAD)INTO v_total_productos
FROM PRODUCTO_PEDIDO PP, PEDIDO P
WHERE TO_CHAR(P.FECHA_PEDIDO, 'YYYY') =ANIO
AND P.COD_PEDIDO=PP.COD_PEDIDO;

RETURN v_total_productos;

END;
/

--FUNCION QUE DEVUELVE EL TOTAL GASTADO DE UN CLIENTE EN UN PERIODO DADO

CREATE OR REPLACE FUNCTION FUNCTION_GASTADO_PERIODO(v_cod_cliente cliente.correo_electronico%type, v_fecha_inicio pedido.fecha_pedido%type, v_fecha_fin pedido.fecha_pedido%type)
RETURN NUMBER
AS

v_importe_gastado_periodo NUMBER(10,2);


BEGIN

IF v_fecha_fin-v_fecha_inicio>0 THEN

    SELECT DISTINCT SUM(ped.importe_total) INTO v_importe_gastado_periodo
        FROM cliente cli, pedido ped
        WHERE cli.correo_electronico=v_cod_cliente
        AND ped.fecha_pedido BETWEEN v_fecha_inicio AND v_fecha_fin
        AND cli.correo_electronico=ped.correo_electronico
        GROUP BY ped.correo_electronico;

    IF SQL%NOTFOUND THEN

        DBMS_OUTPUT.PUT_LINE ('El cliente seleccionado no existe');

    END IF;
ELSE

    RAISE_APPLICATION_ERROR (-20003,'La fecha inicio es posterior a la de fin');

END IF;

RETURN v_importe_gastado_periodo;

EXCEPTION 
    WHEN OTHERS THEN

        RAISE_APPLICATION_ERROR (-20004,'DATOS INCORRECTOS, REVISA TU SOLICITUD');

end;
/
--PROCEDIMIENTOS 


--SECUENCIA PARA LA CREACION DE LOS NUEVOS PEDIDOS GRATIS
CREATE SEQUENCE pedido_gratis_seq
START WITH 1
INCREMENT BY 1;

--PROCEDIMIENTO QUE CREA UN PEDIDO GRATIS PARA LOS MÁXIMOS COMPRADORES DE UN PERIODO DETERMINADO

CREATE OR REPLACE PROCEDURE proc_top3_ped_gratis (v_fecha_inicio DATE, v_fecha_fin DATE) AS
CURSOR c_top_clientes  IS
    
    (SELECT CORREO_ELECTRONICO, direccion FROM (SELECT C.CORREO_ELECTRONICO , SUM(P.IMPORTE_TOTAL), c.direccion
        FROM CLIENTE C, PEDIDO P 
        WHERE C.CORREO_ELECTRONICO=P.CORREO_ELECTRONICO
        AND P.FECHA_PEDIDO BETWEEN v_fecha_inicio AND v_fecha_fin
        GROUP BY C.CORREO_ELECTRONICO, c.direccion
        ORDER BY SUM(P.IMPORTE_TOTAL))
    WHERE ROWNUM <4);
    
v_correo_top cliente%rowtype;
    
BEGIN
        FOR registro in c_top_clientes loop
        
        INSERT INTO PEDIDO VALUES('GRATIS-'||pedido_gratis_seq.NEXTVAL, registro.correo_electronico, ' ' , registro.direccion, 0, 0, sysdate);
        
        END LOOP;       
END;
/

--PROCEDIMIENTO QUE ACTUALICE EL STOCK Y EL PRECIO DE UN PRODUCTO PASANDOLE POR PARAMETROS

CREATE OR REPLACE PROCEDURE proc_actu_precio_stock (v_nombre_producto producto.nombre_producto%type, v_precio_nuevo producto.precio%type, v_stock_nuevo producto.stock%type) AS
CURSOR cursor_nombre_productos  IS
SELECT p.nombre_producto, p.precio, p.stock FROM producto p
WHERE p.nombre_producto=v_nombre_producto;

BEGIN
    FOR registro in cursor_nombre_productos loop
        
        UPDATE producto p set p.precio = v_precio_nuevo, p.stock = v_stock_nuevo WHERE p.nombre_producto=registro.nombre_producto;
        
        DBMS_OUTPUT.PUT_LINE('El producto ' || registro.nombre_producto||' tiene un nuevo precio de '|| v_precio_nuevo ||'€ y un stock de ' ||v_stock_nuevo|| ' unidades');

        end loop;
        
        
        IF SQL%NOTFOUND THEN
        
        RAISE_APPLICATION_ERROR (-20005,'No tenemos ningún producto almacenado con ese nombre');
        
        END IF;       
END;
/

--CURSORES

--CURSOR QUE MUESTRA LOS PEDIDOS DE LA ULTIMA SEMANA

DECLARE
v_fecha_limite DATE:=SYSDATE-7;

CURSOR pedidos_semana IS
SELECT DISTINCT P.COD_PEDIDO, P.FECHA_PEDIDO, P.DIRECCION, PP.CANTIDAD , PP.NOMBRE_PRODUCTO  
FROM PEDIDO P, PRODUCTO_PEDIDO PP
WHERE P.COD_PEDIDO=PP.COD_PEDIDO
AND SYSDATE-7>P.FECHA_PEDIDO;

registro pedidos_semana%rowtype;

begin
DBMS_OUTPUT.PUT_LINE('+------------------------------------------------------------------------+');

    DBMS_OUTPUT.PUT_LINE('PEDIDOS PARA PREPARAR: ');
    
    FOR registro IN pedidos_semana LOOP 

        DBMS_OUTPUT.PUT_LINE('PEDIDO: '||registro.cod_pedido|| ' FECHA: ' || registro.fecha_pedido || ' DIRECCION: '|| REGISTRO.DIRECCION);
        DBMS_OUTPUT.PUT_LINE('CONTIENE: ');
        DBMS_OUTPUT.PUT_LINE(REGISTRO.CANTIDAD ||' POSTERS DE '||REGISTRO.NOMBRE_PRODUCTO);


    END LOOP;
    
DBMS_OUTPUT.PUT_LINE('+------------------------------------------------------------------------+');

end;
/
