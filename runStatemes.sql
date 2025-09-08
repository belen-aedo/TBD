--- 1) Lista de lugares al que más viajan los chilenos por año (durante los últimos 4 años). 

SELECT
  EXTRACT(YEAR FROM v.fecha_vuelo) AS anio,
  v.destino,
  COUNT(*) AS total_viajes
FROM CLIENTE_COMP cc
JOIN CLIENTE c ON c.nro_documento = cc.nro_documento
JOIN VUELO v   ON v.id_vuelo = cc.vuelo_id
WHERE c.nacionalidad = 'Chilena'
  AND v.fecha_vuelo >= (CURRENT_DATE - INTERVAL '4 years')
GROUP BY anio, v.destino
ORDER BY anio, total_viajes DESC;



-- 2) Lista con las secciones de vuelos más compradas por argentinos.

SELECT
  s.tipo_seccion,
  COUNT(*) AS num_compras
FROM CLIENTE c
JOIN PASAJE p ON p.nro_documento = c.nro_documento
JOIN SECCION s ON s.id_seccion   = p.id_seccion
WHERE c.nacionalidad = 'Argentina'
GROUP BY s.tipo_seccion
ORDER BY num_compras DESC;


-- 3) Lista mensual de países que más gastan en volar (durante los últimos 4 años).

WITH country_month_spending AS (
    SELECT 
        EXTRACT(YEAR FROM v.fecha_vuelo) AS anio,
        EXTRACT(MONTH FROM v.fecha_vuelo) AS mes,
        c.nacionalidad AS pais,
        SUM(co.monto_costo) AS total_gastado
    FROM COSTO co
    JOIN PASAJE p ON co.id_pasaje = p.id_pasaje
    JOIN CLIENTE c ON p.nro_documento = c.nro_documento
    JOIN VUELO v ON p.vuelo_id = v.id_vuelo
    WHERE v.fecha_vuelo >= CURRENT_DATE - INTERVAL '4 years'
    GROUP BY anio, mes, pais
),
ranked_country_spending AS (
    SELECT 
        cms.*,
        RANK() OVER (PARTITION BY cms.anio, cms.mes ORDER BY cms.total_gastado DESC) AS rank
    FROM country_month_spending cms
)
SELECT 
    anio,
    mes,
    pais,
    total_gastado
FROM ranked_country_spending
WHERE rank = 1
ORDER BY anio, mes;


-- 4) Lista de pasajeros que viajan en “First Class” más de 4 veces al mes.

SELECT 
    EXTRACT(YEAR FROM s.fecha_pago) AS año,
    EXTRACT(MONTH FROM s.fecha_pago) AS mes,
    e.nombre_e,
    e.apellido_e,
    c.nombre AS compania,
    s.monto_pago
FROM SUELDO s
JOIN EMPLEADO e ON s.rut_e = e.rut_e
JOIN COMPANIA c ON e.compania_id = c.compania_id
WHERE e.piloto = TRUE
  AND s.fecha_pago >= CURRENT_DATE - INTERVAL '4 years'
  AND s.monto_pago = (
      SELECT MAX(s2.monto_pago)
      FROM SUELDO s2
      JOIN EMPLEADO e2 ON s2.rut_e = e2.rut_e
      WHERE e2.piloto = TRUE
        AND EXTRACT(YEAR FROM s2.fecha_pago) = EXTRACT(YEAR FROM s.fecha_pago)
        AND EXTRACT(MONTH FROM s2.fecha_pago) = EXTRACT(MONTH FROM s.fecha_pago)
        AND s2.fecha_pago >= CURRENT_DATE - INTERVAL '4 years'
  )
ORDER BY año DESC, mes DESC;

-- 5) Avión con menos vuelos

SELECT 
    a.id_avion,
    m.nombre_modelo AS modelo,
    c.nombre AS compania,
    COUNT(v.id_vuelo) AS cantidad_vuelos
FROM AVION a
JOIN MODELO m ON a.id_modelo = m.id_modelo
JOIN COMPANIA c ON a.compania_id = c.compania_id
LEFT JOIN VUELO v ON a.id_avion = v.id_avion
GROUP BY a.id_avion, m.nombre_modelo, c.nombre
HAVING COUNT(v.id_vuelo) = (
    SELECT MIN(vuelo_count)
    FROM (
        SELECT COUNT(v2.id_vuelo) as vuelo_count
        FROM AVION a2
        LEFT JOIN VUELO v2 ON a2.id_avion = v2.id_avion
        GROUP BY a2.id_avion
    ) AS subquery
)
ORDER BY a.id_avion;

-- 6) Lista mensual de empleados con mayor sueldo durante los últimos 4 años

-- 6) Lista mensual de empleados con mayor sueldo durante los últimos 4 años
SELECT 
    años.año,
    meses.mes,
    e.nombre_e,
    e.apellido_e,
    c.nombre AS compania,
    s.monto_pago
FROM (
    SELECT EXTRACT(YEAR FROM CURRENT_DATE) - nivel AS año
    FROM (VALUES (0), (1), (2), (3)) AS t(nivel)
) años
CROSS JOIN (
    SELECT mes FROM (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) AS m(mes)
) meses
LEFT JOIN SUELDO s ON EXTRACT(YEAR FROM s.fecha_pago) = años.año 
                   AND EXTRACT(MONTH FROM s.fecha_pago) = meses.mes
                   AND s.fecha_pago >= CURRENT_DATE - INTERVAL '4 years'
LEFT JOIN EMPLEADO e ON s.rut_e = e.rut_e AND e.piloto = TRUE
LEFT JOIN COMPANIA c ON e.compania_id = c.compania_id
WHERE (s.monto_pago IS NULL OR s.monto_pago = (
    SELECT MAX(s2.monto_pago)
    FROM SUELDO s2
    JOIN EMPLEADO e2 ON s2.rut_e = e2.rut_e
    WHERE e2.piloto = TRUE
      AND EXTRACT(YEAR FROM s2.fecha_pago) = años.año
      AND EXTRACT(MONTH FROM s2.fecha_pago) = meses.mes
      AND s2.fecha_pago >= CURRENT_DATE - INTERVAL '4 years'
))
ORDER BY años.año DESC, meses.mes DESC;

-- 7) Lista de compañías indicando cuál es el avión que más ha recaudado en los últimos 
4 años y cuál es el monto recaudado.

SELECT 
    c.nombre AS "Compañía",
    a.id_avion AS "ID Avión", 
    m.nombre_modelo AS "Modelo",
    SUM(co.monto_costo) AS "Monto Recaudado"
FROM COMPANIA c
JOIN AVION a ON c.compania_id = a.compania_id
JOIN MODELO m ON a.id_modelo = m.id_modelo
JOIN VUELO v ON a.id_avion = v.id_avion
JOIN PASAJE p ON v.id_vuelo = p.vuelo_id
JOIN COSTO co ON p.id_pasaje = co.id_pasaje
WHERE v.fecha_vuelo >= CURRENT_DATE - INTERVAL '4 years'
GROUP BY c.compania_id, c.nombre, a.id_avion, m.nombre_modelo
HAVING SUM(co.monto_costo) = (
    SELECT MAX(recaudacion)
    FROM (
        SELECT SUM(co2.monto_costo) as recaudacion
        FROM AVION a2
        JOIN VUELO v2 ON a2.id_avion = v2.id_avion
        JOIN PASAJE p2 ON v2.id_vuelo = p2.vuelo_id
        JOIN COSTO co2 ON p2.id_pasaje = co2.id_pasaje
        WHERE a2.compania_id = c.compania_id
          AND v2.fecha_vuelo >= CURRENT_DATE - INTERVAL '4 years'
        GROUP BY a2.id_avion
    ) 
)
ORDER BY "Monto Recaudado" DESC;

-- 8) Lista de compañías y total de aviones por año (en los últimos 10 años).

SELECT 
    c.nombre AS compania,
    EXTRACT(YEAR FROM a.anio_avion) AS año,
    COUNT(a.id_avion) AS total_aviones
FROM COMPANIA c
JOIN AVION a ON c.compania_id = a.compania_id
WHERE a.anio_avion >= CURRENT_DATE - INTERVAL '10 years'
GROUP BY c.nombre, EXTRACT(YEAR FROM a.anio_avion)
ORDER BY c.nombre, año DESC;


-- 9) Lista anual de compañias que en promedio han pagado más a sus empleados (últimos 10 años)

-- Primero se calcula el promedio salarial por compañia y año
WITH promedio_anual_por_compania AS (
    SELECT 
        c.nombre AS compania,
        EXTRACT(YEAR FROM s.fecha_pago) AS anio,
        AVG(s.monto_pago) AS promedio_sueldo_anual
    FROM SUELDO s
    JOIN EMPLEADO e ON s.rut_e = e.rut_e
    JOIN COMPANIA c ON e.compania_id = c.compania_id
    WHERE s.fecha_pago >= CURRENT_DATE - INTERVAL '10 years'
    GROUP BY c.nombre, EXTRACT(YEAR FROM s.fecha_pago)
),
-- Aqui se asigna un ranking a cada compañia por año *y se crea también la columna ranking
ranking_anual AS (
    SELECT 
        anio,
        compania,
        promedio_sueldo_anual,
        -- ROW_NUMBER() genera números secuenciales (1,2,3...) para cada año
        -- PARTITION BY anio: reinicia la numeración para cada año
        -- ORDER BY promedio_sueldo_anual DESC: ordena de mayor a menor promedio
        ROW_NUMBER() OVER (PARTITION BY anio ORDER BY promedio_sueldo_anual DESC) AS ranking
    FROM promedio_anual_por_compania
)
-- Se muestran solo las compañias con ranking = 1 que es la que mas paga en el año
SELECT 
    anio,
    compania,
    promedio_sueldo_anual,
    ranking  -- Esta columna YA EXISTE porque se creó en el CTE anterior
FROM ranking_anual
WHERE ranking = 1
ORDER BY anio DESC;


-- 10) Modelo de avión más usado por compañía durante el 2021

WITH vuelos_2021_por_modelo AS (
    SELECT 
        c.nombre AS compania,
        m.nombre_modelo,
        COUNT(v.id_vuelo) AS cantidad_vuelos
    FROM VUELO v
    JOIN AVION a ON v.id_avion = a.id_avion
    JOIN MODELO m ON a.id_modelo = m.id_modelo
    JOIN COMPANIA c ON v.compania_id = c.compania_id
    WHERE EXTRACT(YEAR FROM v.fecha_vuelo) = 2021
    GROUP BY c.nombre, m.nombre_modelo
),
ranking_modelos_por_compania AS (
    SELECT 
        compania,
        nombre_modelo,
        cantidad_vuelos,
        ROW_NUMBER() OVER (PARTITION BY compania ORDER BY cantidad_vuelos DESC) AS ranking
    FROM vuelos_2021_por_modelo
)
SELECT 
    compania,
    nombre_modelo AS modelo_mas_usado,
    cantidad_vuelos
FROM ranking_modelos_por_compania
WHERE ranking = 1
ORDER BY compania;
