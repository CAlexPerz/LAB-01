-- Carlos Alexis Pérez Lizárraga 4-3

UPDATE clientes 
SET fecha_alta = CURRENT_DATE - INTERVAL '6 years' 
WHERE id IN (1, 2);

SELECT * 
FROM clientes WHERE fecha_alta <   CURRENT_DATE - INTERVAL '5 years';

-- Área de soporte
-- Debe poder consultar:
SET ROLE soporte;
SELECT * FROM v_clientes_soporte;
-- pero no acceder directamente a:
SELECT * FROM clientes;
-- Área de analítica
SET ROLE analista;
-- Debe poder consultar:
SELECT * FROM analitica.clientes;
-- pero no:
SELECT * FROM pii.mapa_cliente;
-- ni:
SELECT * FROM public.clientes;