## Clasificación
Requieren protección inmediata los identificadores directos (`nombre`, `correo`, `telefono`, `rfc`) porque permiten ubicar individualmente al titular. Asimismo, los cuasi-identificadores (`edad`, `ciudad`, `codigo_postal`, `fecha_alta`) deben ser protegidos o agrupados, ya que su combinación permite reducir el grupo de búsqueda y reidentificar personas. No todos los datos protegidos son "sensibles" en términos jurídicos estrictos (como religión o salud), pero constituyen datos personales que exigen confidencialidad y control de acceso.

## Enmascaramiento
* **Qué se ocultó:** Las cadenas de caracteres de `correo`, `telefono` y `rfc`, mostrando únicamente caracteres iniciales/finales y reemplazando el resto por asteriscos (`*`).
* **Para quién:** Para el rol `soporte`.
* **Por qué:** Aplicando el principio de mínimo privilegio, el área de soporte necesita verificar la identidad del cliente en consultas operativas sin conocer el valor completo de sus credenciales.
* **Mecanismo utilizado:** Creación de una vista (`v_clientes_soporte`) con funciones de texto (`CONCAT`, `LEFT`, `RIGHT`, `SUBSTRING`, `POSITION`), otorgando permiso de consulta sobre la vista (`GRANT SELECT ON v_clientes_soporte TO soporte`) y revocando el acceso directo a la tabla principal (`REVOKE ALL ON clientes FROM soporte`).

## Seudonimización
* **Generación de tokens:** Se generaron identificadores únicos aleatorios tipo UUID mediante la función `gen_random_uuid()` de la extensión `pgcrypto`.
* **Ubicación del mapa de correspondencia:** En la tabla `pii.mapa_cliente`, que asocia cada `token` con el `cliente_id` original.
* **Acceso al mapa:** Reservado exclusivamente a los administradores de la base de datos o procesos automatizados de nivel superior; prohibido para analistas y soporte.
* **Separación de permisos:** Se aplicó el principio de **separación de funciones** (*separation of duties*). El rol `analista` únicamente posee permisos `SELECT` sobre `analitica.clientes`, impidiendo que pueda consultar `pii.mapa_cliente` o `public.clientes`, imposibilitando la reidentificación directa desde su perfil.

## Anonimización
* **Identificadores eliminados:** `nombre`, `correo`, `telefono`, `rfc` e `id` original.
* **Atributos generalizados:** La `edad` se agrupó en rangos (`18-30`, `31-45`, `46+`) usando `CASE WHEN`, y el `codigo_postal` se redujo a los dos primeros dígitos (`region`) mediante `LEFT`.
* **Grupos suprimidos:** Filtro de agregación con `HAVING COUNT(*) >= 5` (evaluado con umbral de 3 en pruebas locales) para suprimir grupos reducidos.
* **Riesgo de reidentificación remanente:** Si un atacante posee información externa previa sobre una persona (como su rango de edad y región), podría inferir su presencia en grupos con bajo conteo de registros.

## Retención
* **Criterio utilizado:** Regla de retención de 5 años a partir de la fecha de registro (`fecha_alta < CURRENT_DATE - INTERVAL '5 years'`).
* **Información a conservar / eliminar:** Debe conservarse la información activa de clientes con menos de 5 años de antigüedad. La información que exceda los 5 años debe marcarse para depuración si no existe obligación legal o fiscal vigente.
* **Controles antes de la eliminación:** 
  1. Aprobación por escrito del Oficial de Privacidad y el área Legal.
  2. Ejecución de un respaldo completo (*backup*) previo.
  3. Registro y conservación de bitácoras (*logs*) de auditoría del proceso.
  4. Disponibilidad de un procedimiento de restauración en ambiente aislado en caso de borrado accidental.

## Conclusiones
1. **¿Qué técnica utilizarías para un área de soporte?**  
   Enmascaramiento dinámico mediante vistas, para ocultar parcialmente los datos sin alterar los registros reales ni interrumpir la operativa.
2. **¿Qué técnica utilizarías para un área de analítica?**  
   Seudonimización con separación de funciones, permitiendo trabajar con registros a nivel individual mediante `tokens` sin exponer la identidad directa del titular.
3. **¿Qué técnica utilizarías para publicar estadísticas?**  
   Anonimización mediante generalización y agregación (`GROUP BY`, `CASE WHEN`, `HAVING`), asegurando que solo se presenten datos consolidados de grupos amplios.
4. **¿Por qué ninguna de estas técnicas sustituye al control de acceso?**  
   Porque las técnicas de transformación regulan cómo se presentan o modifican los datos, pero es el control de acceso (`GRANT`, `REVOKE`, Roles) el que determina quién puede entrar a la base de datos y ejecutar consultas sobre las estructuras subyacentes.


## Preguntas de reflexión

1. **¿Cuál es la diferencia entre enmascaramiento y seudonimización?**
    El enmascaramiento oculta la forma en que se muestra un dato sin cambiar el valor ni la estructura original, mientras que la seudonimización sustituye la identidad real por un identificador sustituto (token) guardando la relación en una tabla aparte.
2. **¿Por qué la seudonimización no significa anonimización?**
    Porque la seudonimización es reversible si se tiene acceso al mapa de correspondencia, mientras que la anonimización busca impedir de forma irreversible la reidentificación de una persona.
3. **¿Por qué eliminar nombre y RFC no garantiza que un conjunto de datos sea anónimo?**
    Porque los datos restantes (como `edad`, `código postal` o `ciudad`) actúan como cuasi-identificadores que, al combinarse entre sí o con fuentes externas, permiten reidentificar al titular.
4. **¿Qué función tienen los cuasi-identificadores?**
    Son atributos que individualmente no identifican a una persona, pero combinados en conjunto reducen el grupo y permiten distinguir a un individuo.
5. **¿Por qué es importante separar el mapa de seudonimización?**
    Para evitar que un usuario sin privilegios pueda cruzar el token con el id original y recuperar la identidad real del titular.
6. **¿Qué principio de seguridad se aplica al impedir que el analista acceda al mapa?**
    El principio de separación de funciones (separation of duties) y el principio de mínimo privilegio.
7. **¿Por qué una vista puede ser preferible a entregar acceso directo a la tabla?**
    Porque permite exponer únicamente las columnas y los datos transformados/filtrados que el rol necesita, sin otorgar permisos sobre la tabla base original.
8. **¿Qué diferencia existe entre proteger un dato para visualización y protegerlo contra acceso no autorizado?**
    Protegerlo para visualización modifica la interfaz o presentación del dato (enmascaramiento), mientras que protegerlo contra acceso no autorizado restringe los permisos en la base de datos (`REVOKE`) para impedir que el usuario ejecute consultas sobre la información real.
9. **¿Por qué la retención forma parte de la protección de datos?**
    Porque limita el tiempo de conservación de la información al estrictamente necesario, alineándose con la minimización de datos y previniendo acumulaciones innecesarias.   
10. **¿Qué riesgo existe si una organización conserva información indefinidamente?**
    Incrementa innecesariamente el impacto técnico, legal y operativo en caso de sufrir una filtración o exposición no autorizada de datos