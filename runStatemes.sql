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
