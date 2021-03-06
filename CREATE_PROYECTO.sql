DROP TABLE AUDITORIA_FACTURAS;
DROP TABLE AUDITORIA_PEDIDOS;
DROP TABLE proveedor_provee_producto;
DROP TABLE proveedor;
DROP TABLE envio;
DROP TABLE producto_pedido;
DROP TABLE producto;
DROP TABLE factura;
DROP TABLE pedido;
DROP TABLE descuento;
DROP TABLE cliente;
DROP SEQUENCE pedido_gratis_seq;


CREATE TABLE CLIENTE(
Correo_electronico VARCHAR2(100) CONSTRAINT cli_coele_pk PRIMARY KEY, 
Nombre VARCHAR2(100)CONSTRAINT cli_nom_nn NOT NULL, 
Apellidos VARCHAR2(100)CONSTRAINT cli_ape_nn NOT NULL, 
Direccion VARCHAR2(100)CONSTRAINT cli_dire_nn NOT NULL, 
telefono VARCHAR2(9)CONSTRAINT cli_tel_nn NOT NULL
);

CREATE TABLE DESCUENTO(
Nombre_descuento VARCHAR2(30) CONSTRAINT des_nom_pk PRIMARY KEY,
Importe_descuento NUMBER(6,2) CONSTRAINT des_imp_nn NOT NULL,
Condiciones VARCHAR2(100)
);

CREATE TABLE PEDIDO(
Cod_pedido VARCHAR2(20) CONSTRAINT ped_cod_pk PRIMARY KEY, 
Correo_electronico VARCHAR2(100),
CONSTRAINT ped_coele_fk FOREIGN KEY (Correo_electronico)REFERENCES CLIENTE,
Nombre_descuento VARCHAR2(30),
CONSTRAINT ped_ndes_fk FOREIGN KEY(Nombre_descuento) REFERENCES DESCUENTO,
Direccion VARCHAR2(100) NOT NULL, 
precio_envio NUMBER(6,2),
Importe_total NUMBER(6,2), 
Fecha_pedido DATE
);

CREATE TABLE FACTURA(
numero_factura VARCHAR2(30) CONSTRAINT fac_num_pk PRIMARY KEY,
Cod_pedido VARCHAR2(6),
CONSTRAINT fac_cod_ped_fk FOREIGN KEY (Cod_pedido) REFERENCES PEDIDO,
Importe_total NUMBER(6,2),
nombre_facturacion VARCHAR2(100) CONSTRAINT fac_nom_nn NOT NULL,
direccion_facturacion VARCHAR2(100) CONSTRAINT fac_dir_nn NOT NULL
);

CREATE TABLE PRODUCTO(
nombre_producto VARCHAR2(100) CONSTRAINT pro_nom_pk PRIMARY KEY,
descripcion VARCHAR2(1000), 
stock NUMBER(4) constraint pro_sto_nn NOT NULL,
precio NUMBER(5,2) constraint pro_pre_nn NOT NULL,
activo VARCHAR2(2) NOT NULL
);

CREATE TABLE PRODUCTO_PEDIDO(--ERROR YA QUE NO SE PUEDE PEDIR EL MISMO POSTER REPETIDO EN UN PEDIDO
Cod_pedido VARCHAR2(6),
CONSTRAINT pro_ped_cod_fk FOREIGN KEY(Cod_pedido) REFERENCES pedido, 
nombre_producto VARCHAR2(100),
CONSTRAINT pro_ped_nom_fk FOREIGN KEY(nombre_producto) REFERENCES PRODUCTO,
CONSTRAINT pro_ped_cn_pk PRIMARY KEY (Cod_pedido, nombre_producto),
cantidad NUMBER (3) NOT NULL
);



CREATE TABLE ENVIO(
numero_seguimiento VARCHAR2(30) CONSTRAINT env_num_pk PRIMARY KEY,
Cod_pedido VARCHAR2(6),
CONSTRAINT env_cod_fk FOREIGN KEY(Cod_pedido) REFERENCES PEDIDO, 
peso NUMBER(4,2) CONSTRAINT env_pes_nn NOT NULL
);

CREATE TABLE PROVEEDOR(
nombre_proveedor VARCHAR2(100) CONSTRAINT provee_nom_pk PRIMARY KEY,
direccion VARCHAR2(100), 
telefono VARCHAR2(15)
);

CREATE TABLE PROVEEDOR_PROVEE_PRODUCTO(
nombre_proveedor VARCHAR2(100),
CONSTRAINT ppp_nprod_fk FOREIGN KEY(nombre_producto)REFERENCES PRODUCTO,
nombre_producto VARCHAR2(100),
CONSTRAINT ppp_nprov_fk FOREIGN KEY(nombre_proveedor) REFERENCES PROVEEDOR,
CONSTRAINT ppp_nono_uq PRIMARY KEY (nombre_producto, nombre_proveedor),
precio NUMBER (4,2)
);

--TABLA DE AUDITORIA PARA LOS PEDIDOS
CREATE TABLE AUDITORIA_PEDIDOS(
usuario_auditoria VARCHAR2(100),
accion_realizada VARCHAR2(50),
datos_antiguos VARCHAR2(200),
datos_nuevos VARCHAR2(200),
fecha_auditoria DATE
);

--TABLA DE AUDITORIA PARA LAS FACTURAS
CREATE TABLE AUDITORIA_FACTURAS(
usuario_auditoria VARCHAR2(100),
accion_realizada VARCHAR2(50),
datos_antiguos VARCHAR2(200),
datos_nuevos VARCHAR2(200),
fecha_auditoria DATE
);

--DATOS

INSERT INTO CLIENTE VALUES ('cliente1@gmail.com','ROBERTO', 'P?REZ', 'Direccion 1', '666666661');
INSERT INTO CLIENTE VALUES ('cliente2@gmail.com','ANTONIO', 'GONZALEZ', 'Direccion 2', '666666662');
INSERT INTO CLIENTE VALUES ('cliente3@gmail.com','JAVI', 'FRANCES', 'Direccion 3', '666666663');
INSERT INTO CLIENTE VALUES ('cliente4@gmail.com','JENNIFER', 'ALISTON', 'Direccion 4', '666666664');
INSERT INTO CLIENTE VALUES ('cliente5@gmail.com','SILVIA', 'NU?EZ', 'Direccion 5', '666666665');


INSERT INTO DESCUENTO VALUES ('ENERO', 1, 'Vigente solo en el mes de enero');
INSERT INTO DESCUENTO VALUES ('FEBRERO', 2,'Vigente solo en el mes de febrero');
INSERT INTO DESCUENTO VALUES ('MARZO', 2,'Vigente solo en el mes de marzo');
INSERT INTO DESCUENTO VALUES ('ABRIL', 4, 'Vigente solo en el mes de abril');
INSERT INTO DESCUENTO VALUES ('MAYO', 3, 'Vigente solo en el mes de mayo');
INSERT INTO DESCUENTO VALUES (' ', 0, 'No hay descuento activo');

INSERT INTO PEDIDO VALUES ('1','cliente5@gmail.com', 'ABRIL', 'C/ CALLE DEL RIO 1',0, 12.99, '10/04/2021');
INSERT INTO PEDIDO VALUES ('2','cliente4@gmail.com', 'MARZO', 'C/ JUAN RAMON 4',0, 23.98, '11/04/2021');
INSERT INTO PEDIDO VALUES ('3','cliente3@gmail.com', 'ENERO', 'C/ SAN TORINO 2',0, 23.98, '12/04/2021');
INSERT INTO PEDIDO VALUES ('4','cliente2@gmail.com', 'ABRIL', 'C/ HENNESY SN',0, 12.99, '12/04/2021');
INSERT INTO PEDIDO VALUES ('5','cliente1@gmail.com', '', 'C/ ASTORGA 3 2C',0, 38.97, '13/04/2021');
INSERT INTO PEDIDO VALUES ('6','cliente1@gmail.com', '', 'C/ ASTORGA 3 2C',0, 38.97, '22/04/2021');

INSERT INTO FACTURA VALUES ('F0001','1', 12.99, 'PINIFARINA SL', 'Direccion 5');
INSERT INTO FACTURA VALUES ('F0002','1', 23.98, 'DECO SLU', 'Direccion 4');
INSERT INTO FACTURA VALUES ('F0003','1', 23.98, 'GREEN GARDEN', 'Direccion 3');
INSERT INTO FACTURA VALUES ('F0004','1', 54.94, 'ANIME SL', 'Direccion 2');
INSERT INTO FACTURA VALUES ('F0005','1', 21.98, 'DECORAME.COM', 'Direccion 1');

INSERT INTO PRODUCTO VALUES ('GOKU-JIREN', 'Poster de GOKU y JIREN que cambia de imagen', 23, 12.99, 'SI');
INSERT INTO PRODUCTO VALUES ('HULK', 'Poster de HULK que cambia de imagen', 15, 12.99, 'SI');
INSERT INTO PRODUCTO VALUES ('NARUTO', 'Poster de NARUTO que cambia de imagen', 7, 12.99, 'SI');
INSERT INTO PRODUCTO VALUES ('VEGETA', 'Poster de VEGETA que cambia de imagen', 20, 12.99, 'SI');
INSERT INTO PRODUCTO VALUES ('MEREUM', 'Poster de MEREUM que cambia de imagen', 0, 12.99, 'NO');

INSERT INTO PRODUCTO_PEDIDO VALUES ('1', 'GOKU-JIREN', 1);
INSERT INTO PRODUCTO_PEDIDO VALUES ('2', 'HULK', 1);
INSERT INTO PRODUCTO_PEDIDO VALUES ('2', 'NARUTO', 1);
INSERT INTO PRODUCTO_PEDIDO VALUES ('3', 'HULK', 2);
INSERT INTO PRODUCTO_PEDIDO VALUES ('4', 'NARUTO', 1);
INSERT INTO PRODUCTO_PEDIDO VALUES ('5', 'GOKU-JIREN', 1);
INSERT INTO PRODUCTO_PEDIDO VALUES ('5', 'NARUTO', 2);


INSERT INTO ENVIO VALUES ('E00001', '1', 0.2);
INSERT INTO ENVIO VALUES ('E00002', '2', 0.4);
INSERT INTO ENVIO VALUES ('E00003', '3', 0.4);
INSERT INTO ENVIO VALUES ('E00004', '4', 0.2);
INSERT INTO ENVIO VALUES ('E00005', '5', 0.6);

INSERT INTO PROVEEDOR VALUES ('GUANZOU', 'Guanzou, china', '+128728973');
INSERT INTO PROVEEDOR VALUES ('3D TLC', 'Avd DE LAS ROSAS 4', '+3465448111');
INSERT INTO PROVEEDOR VALUES ('PIC PIC', 'CALLE ANZUELO 12', '+34722881889');


INSERT INTO PROVEEDOR_PROVEE_PRODUCTO VALUES ('GUANZOU', 'GOKU-JIREN', 2.5);
INSERT INTO PROVEEDOR_PROVEE_PRODUCTO VALUES ('GUANZOU', 'HULK', 2.5);
INSERT INTO PROVEEDOR_PROVEE_PRODUCTO VALUES ('GUANZOU', 'NARUTO', 2.5);
INSERT INTO PROVEEDOR_PROVEE_PRODUCTO VALUES ('3D TLC', 'VEGETA', 2.5);
INSERT INTO PROVEEDOR_PROVEE_PRODUCTO VALUES ('PIC PIC', 'MEREUM', 2.5);




