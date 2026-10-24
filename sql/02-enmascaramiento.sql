-- Carlos Alexis Pérez Lizárraga 4-3
-- 8.1 Crear el rol
CREATE ROLE soporte NOLOGIN;

-- 8.2 Crear una vista de acceso restringido
CREATE VIEW v_clientes_soporte AS SELECT id,  nombre,CONCAT( LEFT(correo, 2),  '*****',
SUBSTRING(correo FROM POSITION('@' IN correo))) AS correo, CONCAT('******',RIGHT(telefono,4)) AS telefono,
CONCAT( '*********',RIGHT(rfc, 4)) AS rfc FROM clientes;

-- Consultar la vista
SELECT * FROM v_clientes_soporte;

-- 8.3 Conceder acceso a la vista
GRANT USAGE ON SCHEMA public TO soporte;
GRANT SELECT ON v_clientes_soporte TO soporte;

-- Revocar el acceso directo a la tabla
REVOKE ALL ON clientes FROM soporte;

--8.4 Verificar el resultado

--La consulta a la vista debe mostrar los datos protegidos:
SELECT * FROM v_clientes_soporte;

--El acceso directo a la tabla debe estar restringido para el rol soporte:
SET ROLE soporte;
SELECT * FROM clientes;

RESET ROLE;