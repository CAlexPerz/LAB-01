-- 12.1 Generalizar la edad
SELECT    CASE     WHEN edad BETWEEN 18 AND 30 THEN '18-30'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45'
        ELSE '46+'   END AS rango_edad,    COUNT(*) AS total FROM clientes GROUP BY 1;

-- 12.2 Generalizar la región
SELECT  LEFT(codigo_postal, 2) AS region, COUNT(*) AS total FROM clientes GROUP BY 1;

-- 12.3 Combinar atributos
SELECT   CASE
        WHEN edad BETWEEN 18 AND 30 THEN '18-30'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45'
        ELSE '46+' END AS rango_edad, LEFT(codigo_postal, 2) AS region,  COUNT(*) AS total
FROM clientes GROUP BY 1, 2;

-- 12.4 Suprimir grupos pequeños
-- Como ejercicio didáctico se utilizará un umbral de cinco registros:
SELECT    CASE
        WHEN edad BETWEEN 18 AND 30 THEN '18-30'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45'
        ELSE '46+'   END AS rango_edad,   LEFT(codigo_postal, 2) AS region, COUNT(*) AS total
FROM clientes GROUP BY 1, 2 HAVING COUNT(*) >= 5;
