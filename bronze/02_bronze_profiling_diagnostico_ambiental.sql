-- ----------------------------------------------------------------------------
-- ETAPA DIAGNÓSTICO Y PERFILAMIENTO INICIAL EN SQL
-- ----------------------------------------------------------------------------
Use ambiental_raw;

-- 1. ESTRUCTURA DE TABLA, TIPOS DE DATOS Y CLAVES

-- Inspección del esquema del sistema de información
DESCRIBE raw_municipios;
DESCRIBE raw_alertas_ambientales;
DESCRIBE raw_contaminantes;
DESCRIBE raw_estaciones;
DESCRIBE raw_mediciones;

-- Consulta al Metadato del Sistema (Information Schema)
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ambiental_raw'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- Revisión registros de cada tabla 
SELECT * FROM raw_municipios limit 10;
SELECT * FROM raw_alertas_ambientales limit 10;
SELECT * FROM raw_contaminantes limit 10;
SELECT * FROM raw_estaciones limit 10;
SELECT * FROM raw_mediciones limit 10;


-- 2. CANTIDAD DE REGISTROS (VOLUMETRÍA)

SELECT 'raw_municipios' AS tabla, COUNT(*) AS total_registros FROM raw_municipios   -- Cantidad filas
UNION ALL                                                                           
SELECT 'raw_alertas_ambientales', COUNT(*) FROM raw_alertas_ambientales
UNION ALL
SELECT 'raw_contaminantes', COUNT(*) FROM raw_contaminantes
UNION ALL
SELECT 'raw_estaciones', COUNT(*) FROM raw_estaciones
UNION ALL
SELECT 'raw_mediciones', COUNT(*) FROM raw_mediciones;


-- 3. VALORES NULL Y VALORES DISTINTOS (CARDINALIDAD)

-- DIAGNOSTICO NULL Y PSEUDO-NULL EN RAW_MUNICIPIOS 
-- Identificación valores NULL y vacios en raw_municipios
SELECT DISTINCT
       'municipio_id' AS columna,
       municipio_id AS valor
FROM raw_municipios
WHERE municipio_id IS NULL
   OR TRIM(municipio_id) = ''
UNION ALL
SELECT DISTINCT
       'municipio' AS columna,
       municipio AS valor
FROM raw_municipios
WHERE municipio IS NULL
   OR TRIM(municipio) = ''
UNION ALL
SELECT DISTINCT
       'departamento' AS columna,
       departamento  AS valor
FROM raw_municipios
WHERE departamento IS NULL
   OR TRIM(departamento) = ''
UNION ALL
SELECT DISTINCT
       'region' AS columna,
       region  AS valor
FROM raw_municipios
WHERE region IS NULL
   OR TRIM(region) = ''
ORDER BY columna, valor;

-- Identificación valores PSEUDO-NULL en raw_municipios
SELECT DISTINCT 'municipio_id' AS columna, municipio_id AS valor
FROM raw_municipios
WHERE municipio_id IS NULL OR municipio_id NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'municipio', municipio
FROM raw_municipios
WHERE municipio IS NULL OR municipio NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'departamento', departamento 
FROM raw_municipios
WHERE departamento IS NULL OR departamento NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'region', region 
FROM raw_municipios
WHERE region IS NULL OR region NOT REGEXP '[0-9]'
ORDER BY columna, valor;

-- Cálculo SUMA Y PORCENTAJE valores NULL y/o PSEUDO-NULL en raw_municipios
SELECT 'municipio_id' AS columna,
       COUNT(*) AS total,
       SUM(municipio_id IS NULL) AS nulos,
       ROUND(100 * SUM(municipio_id IS NULL) / COUNT(*), 2) AS pct_nulos
FROM raw_municipios
UNION ALL
SELECT 'municipio',
       COUNT(*),
       SUM(municipio IS NULL),
       ROUND(100 * SUM(municipio IS NULL) / COUNT(*), 2)
FROM raw_municipios
UNION ALL
SELECT 'departamento',
       COUNT(*),
       SUM(departamento IS NULL),
       ROUND(100 * SUM(departamento IS NULL) / COUNT(*), 2)
FROM raw_municipios
UNION ALL
SELECT 'region',
       COUNT(*),
       SUM(region IS NULL),
       ROUND(100 * SUM(region IS NULL) / COUNT(*), 2)
FROM raw_municipios;

-- DIAGNOSTICO NULL Y PSEUDO-NULL EN RAW_ALERTAS_AMBIENTALES
-- Identificación valores NULL y vacios en raw_alertas_ambientales
SELECT DISTINCT
       'alerta_id' AS columna,
       alerta_id AS valor
FROM raw_alertas_ambientales
WHERE alerta_id IS NULL
UNION ALL
SELECT DISTINCT
       'nivel_alerta' AS columna,
       nivel_alerta AS valor
FROM raw_alertas_ambientales
WHERE nivel_alerta IS NULL
   OR TRIM(nivel_alerta) = ''
UNION ALL
SELECT DISTINCT
       'contaminante_causante' AS columna,
       contaminante_causante AS valor
FROM raw_alertas_ambientales
WHERE contaminante_causante IS NULL
   OR TRIM(contaminante_causante) = ''
UNION ALL
SELECT DISTINCT
       'descripcion' AS columna,
       descripcion  AS valor
FROM raw_alertas_ambientales
WHERE descripcion IS NULL
   OR TRIM(descripcion) = ''
ORDER BY columna, valor;

-- Identificación valores PSEUDO-NULL en raw_alertas_ambientales
SELECT DISTINCT 'alerta_id' AS columna, alerta_id AS valor
FROM raw_alertas_ambientales
WHERE alerta_id IS NULL OR alerta_id NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'nivel_alerta', nivel_alerta 
FROM raw_alertas_ambientales
WHERE nivel_alerta IS NULL OR nivel_alerta NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'contaminante_causante', contaminante_causante 
FROM raw_alertas_ambientales
WHERE contaminante_causante IS NULL OR contaminante_causante NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'descripcion', descripcion 
FROM raw_alertas_ambientales
WHERE descripcion IS NULL OR descripcion NOT REGEXP '[0-9]'
ORDER BY columna, valor;

-- Cálculo SUMA Y PORCENTAJE valores NULL y/o PSEUDO-NULL en raw_alertas_ambientales
SELECT 'alerta_id' AS columna,
       COUNT(*) AS total,
       SUM(alerta_id IS NULL) AS nulos,
       ROUND(100 * SUM(alerta_id IS NULL) / COUNT(*), 2) AS pct_nulos
FROM raw_alertas_ambientales
UNION ALL
SELECT 'nivel_alerta',
       COUNT(*),
       SUM(nivel_alerta IS NULL),
       ROUND(100 * SUM(nivel_alerta IS NULL) / COUNT(*), 2)
FROM raw_alertas_ambientales
UNION ALL
SELECT 'contaminante_causante',
       COUNT(*),
       SUM(contaminante_causante IS NULL),
       ROUND(100 * SUM(contaminante_causante IS NULL) / COUNT(*), 2)
FROM raw_alertas_ambientales
UNION ALL
SELECT 'descripcion',
       COUNT(*),
       SUM(descripcion IS NULL),
       ROUND(100 * SUM(descripcion IS NULL) / COUNT(*), 2)
FROM raw_alertas_ambientales;

-- DIAGNOSTICO NULL Y PSEUDO-NULL EN RAW_CONTAMINANTES
-- Identificación valores NULL y vacios en raw_contaminantes
SELECT DISTINCT
       'contaminante_id' AS columna,
       contaminante_id AS valor
FROM raw_contaminantes
WHERE contaminante_id IS NULL
UNION ALL
SELECT DISTINCT
       'nombre' AS columna,
       nombre  AS valor
FROM raw_contaminantes
WHERE nombre IS NULL
   OR TRIM(nombre) = ''
UNION ALL
SELECT DISTINCT
       'codigo' AS columna,
       codigo  AS valor
FROM raw_contaminantes
WHERE codigo IS NULL
   OR TRIM(codigo) = ''
UNION ALL
SELECT DISTINCT
       'unidad_medida' AS columna,
       unidad_medida  AS valor
FROM raw_contaminantes
WHERE unidad_medida IS NULL
   OR TRIM(unidad_medida) = ''
UNION ALL
SELECT DISTINCT
       'categoria' AS columna,
       categoria  AS valor
FROM raw_contaminantes
WHERE categoria IS NULL
   OR TRIM(categoria) = ''
ORDER BY columna, valor;

-- Identificación valores PSEUDO-NULL en raw_contaminantes
SELECT DISTINCT 'contaminante_id' AS columna, contaminante_id AS valor
FROM raw_contaminantes
WHERE contaminante_id IS NULL OR contaminante_id NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'nombre', nombre 
FROM raw_contaminantes
WHERE nombre IS NULL OR nombre NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'codigo', codigo 
FROM raw_contaminantes
WHERE codigo IS NULL OR codigo NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'unidad_medida', unidad_medida 
FROM raw_contaminantes
WHERE unidad_medida IS NULL OR unidad_medida NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'categoria', categoria 
FROM raw_contaminantes
WHERE categoria IS NULL OR categoria NOT REGEXP '[0-9]'
ORDER BY columna, valor;

-- Cálculo SUMA Y PORCENTAJE valores NULL y/o PSEUDO-NULL en raw_contaminantes
SELECT 'contaminante_id' AS columna,
       COUNT(*) AS total,
       SUM(contaminante_id IS NULL) AS nulos,
       ROUND(100 * SUM(contaminante_id IS NULL) / COUNT(*), 2) AS pct_nulos
FROM raw_contaminantes
UNION ALL
SELECT 'nombre',
       COUNT(*),
       SUM(nombre IS NULL),
       ROUND(100 * SUM(nombre IS NULL) / COUNT(*), 2)
FROM raw_contaminantes
UNION ALL
SELECT 'codigo',
       COUNT(*),
       SUM(codigo IS NULL),
       ROUND(100 * SUM(codigo IS NULL) / COUNT(*), 2)
FROM raw_contaminantes
UNION ALL
SELECT 'unidad_medida',
       COUNT(*),
       SUM(unidad_medida IS NULL),
       ROUND(100 * SUM(unidad_medida IS NULL) / COUNT(*), 2)
FROM raw_contaminantes
UNION ALL
SELECT 'categoria',
       COUNT(*),
       SUM(categoria IS NULL),
       ROUND(100 * SUM(categoria IS NULL) / COUNT(*), 2)
FROM raw_contaminantes;

-- DIAGNOSTICO NULL Y PSEUDO-NULL EN RAW_ESTACIONES
-- Identificación valores NULL y vacios en raw_estaciones
SELECT DISTINCT
       'estacion_id' AS columna,
       estacion_id AS valor
FROM raw_estaciones
WHERE estacion_id IS NULL
   OR TRIM(estacion_id) = ''
UNION ALL
SELECT DISTINCT
       'nombre_estacion' AS columna,
       nombre_estacion  AS valor
FROM raw_estaciones
WHERE nombre_estacion IS NULL
   OR TRIM(nombre_estacion) = ''
UNION ALL
SELECT DISTINCT
       'municipio_id' AS columna,
       municipio_id  AS valor
FROM raw_estaciones
WHERE municipio_id IS NULL
   OR TRIM(municipio_id) = ''
UNION ALL
SELECT DISTINCT
       'tipo_estacion' AS columna,
       tipo_estacion  AS valor
FROM raw_estaciones
WHERE tipo_estacion IS NULL
   OR TRIM(tipo_estacion) = ''
UNION ALL
SELECT DISTINCT
       'latitud' AS columna,
       latitud AS valor
FROM raw_estaciones
WHERE latitud IS NULL
UNION ALL
SELECT DISTINCT
       'longitud' AS columna,
       longitud AS valor
FROM raw_estaciones
WHERE longitud IS NULL
UNION ALL
SELECT DISTINCT
       'fecha_instalacion' AS columna,
       fecha_instalacion  AS valor
FROM raw_estaciones
WHERE fecha_instalacion IS NULL
   OR TRIM(fecha_instalacion) = ''
UNION ALL
SELECT DISTINCT
       'estado' AS columna,
       estado AS valor
FROM raw_estaciones
WHERE estado IS NULL
   OR TRIM(estado) = ''
ORDER BY columna, valor;

-- Identificación valores PSEUDO-NULL en raw_estaciones
SELECT DISTINCT 'estacion_id' AS columna, estacion_id  AS valor
FROM raw_estaciones
WHERE estacion_id IS NULL OR estacion_id NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'nombre_estacion', nombre_estacion 
FROM raw_estaciones
WHERE nombre_estacion IS NULL OR nombre_estacion NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'municipio_id', municipio_id 
FROM raw_estaciones
WHERE municipio_id IS NULL OR municipio_id NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'tipo_estacion', tipo_estacion 
FROM raw_estaciones
WHERE tipo_estacion IS NULL OR tipo_estacion NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'latitud', latitud
FROM raw_estaciones
WHERE latitud IS NULL OR latitud NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'longitud', longitud
FROM raw_estaciones
WHERE longitud IS NULL OR longitud NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'fecha_instalacion', fecha_instalacion 
FROM raw_estaciones
WHERE fecha_instalacion IS NULL OR fecha_instalacion NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'estado', estado 
FROM raw_estaciones
WHERE estado IS NULL OR estado NOT REGEXP '[0-9]'
ORDER BY columna, valor;

-- Cálculo SUMA Y PORCENTAJE valores NULL y/o PSEUDO-NULL en raw_estaciones
SELECT 'estacion_id' AS columna,
       COUNT(*) AS total,
       SUM(estacion_id IS NULL) AS nulos,
       ROUND(100 * SUM(estacion_id IS NULL) / COUNT(*), 2) AS pct_nulos
FROM raw_estaciones
UNION ALL
SELECT 'nombre_estacion',
       COUNT(*),
       SUM(nombre_estacion IS NULL),
       ROUND(100 * SUM(nombre_estacion IS NULL) / COUNT(*), 2)
FROM raw_estaciones
UNION ALL
SELECT 'municipio_id',
       COUNT(*),
       SUM(municipio_id IS NULL),
       ROUND(100 * SUM(municipio_id IS NULL) / COUNT(*), 2)
FROM raw_estaciones
UNION ALL
SELECT 'tipo_estacion',
       COUNT(*),
       SUM(tipo_estacion IS NULL),
       ROUND(100 * SUM(tipo_estacion IS NULL) / COUNT(*), 2)
FROM raw_estaciones
UNION ALL
SELECT 'latitud',
       COUNT(*),
       SUM(latitud IS NULL),
       ROUND(100 * SUM(latitud IS NULL) / COUNT(*), 2)
FROM raw_estaciones
UNION ALL
SELECT 'longitud',
       COUNT(*),
       SUM(longitud IS NULL),
       ROUND(100 * SUM(longitud IS NULL) / COUNT(*), 2)
FROM raw_estaciones
UNION ALL
SELECT 'fecha_instalacion',
       COUNT(*),
       SUM(fecha_instalacion IS NULL),
       ROUND(100 * SUM(fecha_instalacion IS NULL) / COUNT(*), 2)
FROM raw_estaciones
UNION ALL
SELECT 'estado',
       COUNT(*),
       SUM(estado IS NULL),
       ROUND(100 * SUM(estado IS NULL) / COUNT(*), 2)
FROM raw_estaciones;

-- DIAGNOSTICO NULL Y PSEUDO-NULL EN RAW_MEDICIONES
-- Identificación valores NULL y vacíos en raw_mediciones
SELECT DISTINCT
       'medicion_id' AS columna,
       medicion_id AS valor
FROM raw_mediciones
WHERE medicion_id IS NULL
UNION ALL
SELECT DISTINCT
       'estacion_id' AS columna,
       estacion_id AS valor
FROM raw_mediciones
WHERE estacion_id IS NULL
   OR TRIM(estacion_id) = ''
UNION ALL
SELECT DISTINCT
       'contaminante_id' AS columna,
       contaminante_id AS valor
FROM raw_mediciones
WHERE contaminante_id IS NULL
UNION ALL
SELECT DISTINCT
       'alerta_id' AS columna,
       alerta_id AS valor
FROM raw_mediciones
WHERE alerta_id IS NULL
UNION ALL
SELECT DISTINCT
       'fecha' AS columna,
       fecha AS valor
FROM raw_mediciones
WHERE fecha IS NULL
   OR TRIM(fecha) = ''
UNION ALL
SELECT DISTINCT
       'hora' AS columna,
       hora AS valor
FROM raw_mediciones
WHERE hora IS NULL
UNION ALL
SELECT DISTINCT
       'concentracion' AS columna,
       concentracion AS valor
FROM raw_mediciones
WHERE concentracion IS NULL
   OR TRIM(concentracion) = ''
UNION ALL
SELECT DISTINCT
       'temperatura' AS columna,
       temperatura AS valor
FROM raw_mediciones
WHERE temperatura IS NULL
   OR TRIM(temperatura) = ''
UNION ALL
SELECT DISTINCT
       'humedad' AS columna,
       humedad AS valor
FROM raw_mediciones
WHERE humedad IS NULL
   OR TRIM(humedad) = ''
UNION ALL
SELECT DISTINCT
       'velocidad_viento' AS columna,
       velocidad_viento AS valor
FROM raw_mediciones
WHERE velocidad_viento IS NULL
   OR TRIM(velocidad_viento) = ''
UNION ALL
SELECT DISTINCT
       'calidad_dato' AS columna,
       calidad_dato AS valor
FROM raw_mediciones
WHERE calidad_dato IS NULL
   OR TRIM(calidad_dato) = ''
ORDER BY columna, valor;

-- Identificación valores PSEUDO-NULL en raw_mediciones
SELECT DISTINCT 'medicion_id' AS columna, medicion_id AS valor    
FROM raw_mediciones
WHERE medicion_id IS NULL OR medicion_id NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'estacion_id', estacion_id
FROM raw_mediciones
WHERE estacion_id IS NULL OR estacion_id NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'contaminante_id', contaminante_id
FROM raw_mediciones
WHERE contaminante_id IS NULL OR contaminante_id NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'alerta_id', alerta_id
FROM raw_mediciones
WHERE alerta_id IS NULL OR alerta_id NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'fecha', fecha
FROM raw_mediciones
WHERE fecha IS NULL OR fecha NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'hora', hora
FROM raw_mediciones
WHERE hora IS NULL OR hora NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'concentracion', concentracion
FROM raw_mediciones
WHERE concentracion IS NULL OR concentracion NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'temperatura', temperatura
FROM raw_mediciones
WHERE temperatura IS NULL OR temperatura NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'humedad', humedad
FROM raw_mediciones
WHERE humedad IS NULL OR humedad NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'velocidad_viento', velocidad_viento
FROM raw_mediciones
WHERE velocidad_viento IS NULL OR velocidad_viento NOT REGEXP '[0-9]'
UNION ALL
SELECT DISTINCT 'calidad_dato', calidad_dato     
FROM raw_mediciones
WHERE calidad_dato IS NULL OR calidad_dato NOT REGEXP '[0-9]'
ORDER BY columna, valor;

-- Cálculo SUMA Y PORCENTAJE valores NULL y/o PSEUDO-NULL en raw_mediciones
SELECT 'medicion_id' AS columna,
       COUNT(*) AS total,
       SUM(medicion_id IS NULL) AS nulos,
       ROUND(100 * SUM(medicion_id IS NULL) / COUNT(*), 2) AS pct_nulos,
       SUM(TRIM(medicion_id) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')) AS seudo_nulos,
       ROUND(100 * SUM(TRIM(medicion_id) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')) / COUNT(*), 2) AS pct_seudo_nulos
FROM raw_mediciones
UNION ALL
SELECT 'estacion_id', COUNT(*),
       SUM(estacion_id IS NULL),
       ROUND(100 * SUM(estacion_id IS NULL) / COUNT(*), 2),
       SUM(TRIM(estacion_id) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')),
       ROUND(100 * SUM(TRIM(estacion_id) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')) / COUNT(*), 2)
FROM raw_mediciones
UNION ALL
SELECT 'contaminante_id', COUNT(*),
       SUM(contaminante_id IS NULL),
       ROUND(100 * SUM(contaminante_id IS NULL) / COUNT(*), 2),
       SUM(TRIM(contaminante_id) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')),
       ROUND(100 * SUM(TRIM(contaminante_id) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')) / COUNT(*), 2)
FROM raw_mediciones
UNION ALL
SELECT 'alerta_id', COUNT(*),
       SUM(alerta_id IS NULL),
       ROUND(100 * SUM(alerta_id IS NULL) / COUNT(*), 2),
       SUM(TRIM(alerta_id) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')),
       ROUND(100 * SUM(TRIM(alerta_id) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')) / COUNT(*), 2)
FROM raw_mediciones
UNION ALL
SELECT 'fecha', COUNT(*),
       SUM(fecha IS NULL),
       ROUND(100 * SUM(fecha IS NULL) / COUNT(*), 2),
       SUM(TRIM(fecha) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')),
       ROUND(100 * SUM(TRIM(fecha) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')) / COUNT(*), 2)
FROM raw_mediciones
UNION ALL
SELECT 'hora', COUNT(*),
       SUM(hora IS NULL),
       ROUND(100 * SUM(hora IS NULL) / COUNT(*), 2),
       SUM(TRIM(hora) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')),
       ROUND(100 * SUM(TRIM(hora) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')) / COUNT(*), 2)
FROM raw_mediciones
UNION ALL
SELECT 'concentracion', COUNT(*),
       SUM(concentracion IS NULL),
       ROUND(100 * SUM(concentracion IS NULL) / COUNT(*), 2),
       SUM(TRIM(concentracion) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')),
       ROUND(100 * SUM(TRIM(concentracion) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')) / COUNT(*), 2)
FROM raw_mediciones
UNION ALL
SELECT 'temperatura', COUNT(*),
       SUM(temperatura IS NULL),
       ROUND(100 * SUM(temperatura IS NULL) / COUNT(*), 2),
       SUM(TRIM(temperatura) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')),
       ROUND(100 * SUM(TRIM(temperatura) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')) / COUNT(*), 2)
FROM raw_mediciones
UNION ALL
SELECT 'humedad', COUNT(*),
       SUM(humedad IS NULL),
       ROUND(100 * SUM(humedad IS NULL) / COUNT(*), 2),
       SUM(TRIM(humedad) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')),
       ROUND(100 * SUM(TRIM(humedad) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')) / COUNT(*), 2)
FROM raw_mediciones
UNION ALL
SELECT 'velocidad_viento', COUNT(*),
       SUM(velocidad_viento IS NULL),
       ROUND(100 * SUM(velocidad_viento IS NULL) / COUNT(*), 2),
       SUM(TRIM(velocidad_viento) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')),
       ROUND(100 * SUM(TRIM(velocidad_viento) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')) / COUNT(*), 2)
FROM raw_mediciones
UNION ALL
SELECT 'calidad_dato', COUNT(*),
       SUM(calidad_dato IS NULL),
       ROUND(100 * SUM(calidad_dato IS NULL) / COUNT(*), 2),
       SUM(TRIM(calidad_dato) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')),
       ROUND(100 * SUM(TRIM(calidad_dato) IN ('', 'N/A', 'NA', 'Sin dato', 'No disponible')) / COUNT(*), 2)
FROM raw_mediciones;

-- 3.1 CARDINALIDAD contar cuantos valores diferentes existen

-- Cardinalidad raw_municipios
SELECT
    COUNT(*)                                              AS total_filas,
    COUNT(DISTINCT municipio_id COLLATE utf8mb4_0900_bin) AS municipio_id_distintos,
    COUNT(DISTINCT municipio COLLATE utf8mb4_0900_bin)    AS municipio_distintos,
    COUNT(DISTINCT departamento COLLATE utf8mb4_0900_bin) AS departamento_distintos,
    COUNT(DISTINCT region COLLATE utf8mb4_0900_bin)       AS region_distintos
FROM raw_municipios;

-- Cardinalidad raw_alertas_ambientales
SELECT
    COUNT(*)                                                       AS total_filas,
    COUNT(DISTINCT alerta_id)                                      AS alerta_id_distintos,
    COUNT(DISTINCT nivel_alerta COLLATE utf8mb4_0900_bin)          AS nivel_alerta_distintos,
    COUNT(DISTINCT contaminante_causante COLLATE utf8mb4_0900_bin) AS contaminante_causante_distintos,
    COUNT(DISTINCT descripcion COLLATE utf8mb4_0900_bin)           AS descripcion_distintos
FROM raw_alertas_ambientales;

-- Cardinalidad raw_contaminantes
SELECT
    COUNT(*)                                               AS total_filas,
    COUNT(DISTINCT contaminante_id)                        AS contaminante_id_distintos,
    COUNT(DISTINCT nombre COLLATE utf8mb4_0900_bin)        AS nombre_distintos,
    COUNT(DISTINCT codigo COLLATE utf8mb4_0900_bin)        AS codigo_distintos,
    COUNT(DISTINCT unidad_medida COLLATE utf8mb4_0900_bin) AS unidad_medida_distintos,
    COUNT(DISTINCT categoria COLLATE utf8mb4_0900_bin)     AS categoria_distintos
FROM raw_contaminantes;

-- Cardinalidad raw_estaciones
SELECT
    COUNT(*)                                                   AS total_filas,
    COUNT(DISTINCT estacion_id COLLATE utf8mb4_0900_bin)       AS estacion_id_distintos,
    COUNT(DISTINCT nombre_estacion COLLATE utf8mb4_0900_bin)   AS nombre_estacion_distintos,
    COUNT(DISTINCT municipio_id COLLATE utf8mb4_0900_bin)      AS municipio_id_distintos,
    COUNT(DISTINCT tipo_estacion COLLATE utf8mb4_0900_bin)     AS tipo_estacion_distintos,
    COUNT(DISTINCT latitud)                                    AS latitud_distintos,
    COUNT(DISTINCT longitud)                                   AS longitud_distintos,
    COUNT(DISTINCT fecha_instalacion COLLATE utf8mb4_0900_bin) AS fecha_instalacion_distintos,
    COUNT(DISTINCT estado COLLATE utf8mb4_0900_bin)            AS estado_distintos
FROM raw_estaciones;

-- Cardinalidad raw_mediciones
SELECT
    COUNT(*)                                                  AS total_filas,
    COUNT(DISTINCT medicion_id)                               AS medicion_id_distintos,
    COUNT(DISTINCT estacion_id COLLATE utf8mb4_0900_bin)      AS estacion_id_distintos,
    COUNT(DISTINCT contaminante_id)                           AS contaminante_id_distintos,
    COUNT(DISTINCT alerta_id)                                 AS alerta_id_distintos,
    COUNT(DISTINCT fecha COLLATE utf8mb4_0900_bin)            AS fecha_distintos,
    COUNT(DISTINCT hora)                                      AS hora_distintos,
    COUNT(DISTINCT concentracion COLLATE utf8mb4_0900_bin)    AS concentracion_distintos,
    COUNT(DISTINCT temperatura COLLATE utf8mb4_0900_bin)      AS temperatura_distintos,
    COUNT(DISTINCT humedad COLLATE utf8mb4_0900_bin)          AS humedad_distintos,
    COUNT(DISTINCT velocidad_viento COLLATE utf8mb4_0900_bin) AS velocidad_viento_distintos,
    COUNT(DISTINCT calidad_dato COLLATE utf8mb4_0900_bin)     AS calidad_dato_distintos
FROM raw_mediciones;

-- 4. AUDITORÍA CATEGÓRICA 

-- Auditoria categorica raw_municipios
SELECT 'municipio' AS columna,
       municipio COLLATE utf8mb4_0900_bin AS valor,
       CONCAT('[', MIN(municipio COLLATE utf8mb4_0900_bin), ']') AS valor_visible,
       COUNT(*) AS frecuencia,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_frecuencia
FROM raw_municipios
GROUP BY municipio COLLATE utf8mb4_0900_bin
UNION ALL
SELECT 'departamento',
       departamento COLLATE utf8mb4_0900_bin,
       CONCAT('[', MIN(departamento COLLATE utf8mb4_0900_bin), ']'),
       COUNT(*),
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)
FROM raw_municipios
GROUP BY departamento COLLATE utf8mb4_0900_bin
UNION ALL
SELECT 'region',
       region COLLATE utf8mb4_0900_bin,
       CONCAT('[', MIN(region COLLATE utf8mb4_0900_bin), ']'),
       COUNT(*),
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)
FROM raw_municipios
GROUP BY region COLLATE utf8mb4_0900_bin
ORDER BY columna, valor;

-- Auditoria categorica raw_alertas_ambientales
SELECT 'nivel_alerta' AS columna,
       nivel_alerta COLLATE utf8mb4_0900_bin AS valor,
       CONCAT('[', MIN(nivel_alerta COLLATE utf8mb4_0900_bin), ']') AS valor_visible,
       COUNT(*) AS frecuencia,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_frecuencia
FROM raw_alertas_ambientales
GROUP BY nivel_alerta COLLATE utf8mb4_0900_bin
UNION ALL
SELECT 'contaminante_causante',
       contaminante_causante COLLATE utf8mb4_0900_bin,
       CONCAT('[', MIN(contaminante_causante COLLATE utf8mb4_0900_bin), ']'),
       COUNT(*),
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)
FROM raw_alertas_ambientales
GROUP BY contaminante_causante COLLATE utf8mb4_0900_bin
UNION ALL
SELECT 'descripcion',
       descripcion COLLATE utf8mb4_0900_bin,
       CONCAT('[', MIN(descripcion COLLATE utf8mb4_0900_bin), ']'),
       COUNT(*),
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)
FROM raw_alertas_ambientales
GROUP BY descripcion COLLATE utf8mb4_0900_bin
ORDER BY columna, valor;

-- Auditoria categorica raw_contaminantes
SELECT 'nombre' AS columna,
       nombre COLLATE utf8mb4_0900_bin AS valor,
       CONCAT('[', MIN(nombre COLLATE utf8mb4_0900_bin), ']') AS valor_visible,
       COUNT(*) AS frecuencia,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_frecuencia
FROM raw_contaminantes
GROUP BY nombre COLLATE utf8mb4_0900_bin
UNION ALL
SELECT 'codigo',
       codigo COLLATE utf8mb4_0900_bin,
       CONCAT('[', MIN(codigo COLLATE utf8mb4_0900_bin), ']'),
       COUNT(*),
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)
FROM raw_contaminantes
GROUP BY codigo COLLATE utf8mb4_0900_bin
UNION ALL
SELECT 'unidad_medida',
       unidad_medida COLLATE utf8mb4_0900_bin,
       CONCAT('[', MIN(unidad_medida COLLATE utf8mb4_0900_bin), ']'),
       COUNT(*),
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)
FROM raw_contaminantes
GROUP BY unidad_medida COLLATE utf8mb4_0900_bin
UNION ALL
SELECT 'categoria',
       categoria COLLATE utf8mb4_0900_bin,
       CONCAT('[', MIN(categoria COLLATE utf8mb4_0900_bin), ']'),
       COUNT(*),
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)
FROM raw_contaminantes
GROUP BY categoria COLLATE utf8mb4_0900_bin
ORDER BY columna, valor;

-- Auditoria categorica raw_estaciones
SELECT 'tipo_estacion' AS columna,
       tipo_estacion COLLATE utf8mb4_0900_bin AS valor,
       CONCAT('[', MIN(tipo_estacion COLLATE utf8mb4_0900_bin), ']') AS valor_visible,
       COUNT(*) AS frecuencia,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_frecuencia
FROM raw_estaciones
GROUP BY tipo_estacion COLLATE utf8mb4_0900_bin
UNION ALL
SELECT 'estado',
       estado COLLATE utf8mb4_0900_bin,
       CONCAT('[', MIN(estado COLLATE utf8mb4_0900_bin), ']'),
       COUNT(*),
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)
FROM raw_estaciones
GROUP BY estado COLLATE utf8mb4_0900_bin
UNION ALL
SELECT 'municipio_id',
       municipio_id COLLATE utf8mb4_0900_bin,
       CONCAT('[', MIN(municipio_id COLLATE utf8mb4_0900_bin), ']'),
       COUNT(*),
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)
FROM raw_estaciones
GROUP BY municipio_id COLLATE utf8mb4_0900_bin
UNION ALL
SELECT 'nombre_estacion',
       nombre_estacion COLLATE utf8mb4_0900_bin,
       CONCAT('[', MIN(nombre_estacion COLLATE utf8mb4_0900_bin), ']'),
       COUNT(*),
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)
FROM raw_estaciones
GROUP BY nombre_estacion COLLATE utf8mb4_0900_bin
ORDER BY columna, valor;

-- Auditoria categorica raw_mediciones
SELECT 'calidad_dato' AS columna,
       calidad_dato COLLATE utf8mb4_0900_bin AS valor,
       CONCAT('[', MIN(calidad_dato COLLATE utf8mb4_0900_bin), ']') AS valor_visible,
       COUNT(*) AS frecuencia,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_frecuencia
FROM raw_mediciones
GROUP BY calidad_dato COLLATE utf8mb4_0900_bin
ORDER BY columna, frecuencia DESC;

-- 5. FILAS DUPLICADAS
-- DUPLICADOS EXACTOS - raw_municipios
SELECT municipio_id, municipio, departamento, region,
       COUNT(*) AS veces
FROM raw_municipios
GROUP BY municipio_id, municipio, departamento, region
HAVING COUNT(*) > 1;

-- DUPLICADOS POR LLAVE - raw_municipios
SELECT municipio_id, COUNT(*) AS veces
FROM raw_municipios
GROUP BY municipio_id
HAVING COUNT(*) > 1;

-- DUPLICADOS EXACTOS - raw_alertas_ambientales
SELECT alerta_id, nivel_alerta, contaminante_causante, descripcion,
       COUNT(*) AS veces
FROM raw_alertas_ambientales
GROUP BY alerta_id, nivel_alerta, contaminante_causante, descripcion
HAVING COUNT(*) > 1;

-- DUPLICADOS POR LLAVE - raw_alertas_ambientales
SELECT alerta_id, COUNT(*) AS veces
FROM raw_alertas_ambientales
GROUP BY alerta_id
HAVING COUNT(*) > 1;

-- DUPLICADOS EXACTOS - raw_contaminantes
SELECT contaminante_id, nombre, codigo, unidad_medida, categoria,
       COUNT(*) AS veces
FROM raw_contaminantes
GROUP BY contaminante_id, nombre, codigo, unidad_medida, categoria
HAVING COUNT(*) > 1;

-- DUPLICADOS POR LLAVE - raw_contaminantes
SELECT contaminante_id, COUNT(*) AS veces
FROM raw_contaminantes
GROUP BY contaminante_id
HAVING COUNT(*) > 1;

-- DUPLICADOS EXACTOS - raw_estaciones
SELECT estacion_id, nombre_estacion, municipio_id, tipo_estacion,
       latitud, longitud, fecha_instalacion, estado,
       COUNT(*) AS veces
FROM raw_estaciones
GROUP BY estacion_id, nombre_estacion, municipio_id, tipo_estacion,
         latitud, longitud, fecha_instalacion, estado
HAVING COUNT(*) > 1;

-- DUPLICADOS POR LLAVE - raw_estaciones
SELECT estacion_id, COUNT(*) AS veces
FROM raw_estaciones
GROUP BY estacion_id
HAVING COUNT(*) > 1;

-- DUPLICADOS EXACTOS - raw_mediciones
SELECT medicion_id, estacion_id, contaminante_id, alerta_id, fecha, hora,
       concentracion, temperatura, humedad, velocidad_viento, calidad_dato,
       COUNT(*) AS veces
FROM raw_mediciones
GROUP BY medicion_id, estacion_id, contaminante_id, alerta_id, fecha, hora,
         concentracion, temperatura, humedad, velocidad_viento, calidad_dato
HAVING COUNT(*) > 1;

-- DUPLICADOS POR LLAVE - raw_mediciones
SELECT medicion_id, COUNT(*) AS veces
FROM raw_mediciones
GROUP BY medicion_id
HAVING COUNT(*) > 1;


-- 6. IDENTIFICACIÓN DE PROBLEMAS DE CALIDAD (INTEGRIDAD REFERENCIAL)  -- Identificador que no existe en la tabla referenciada 
-- HUÉRFANOS - raw_estaciones → raw_municipios
SELECT e.estacion_id, e.municipio_id
FROM raw_estaciones e  -- tabla hija 
LEFT JOIN raw_municipios mu ON e.municipio_id = mu.municipio_id -- tabla padre
WHERE mu.municipio_id IS NULL
AND e.municipio_id IS NOT NULL;

-- HUÉRFANOS - raw_mediciones → raw_alertas_ambientales
SELECT m.medicion_id, m.alerta_id
FROM raw_mediciones m
LEFT JOIN raw_alertas_ambientales a ON m.alerta_id = a.alerta_id
WHERE a.alerta_id IS NULL
AND m.alerta_id IS NOT NULL;          

-- HUÉRFANOS - raw_mediciones → raw_contaminantes
SELECT m.medicion_id, m.contaminante_id
FROM raw_mediciones m
LEFT JOIN raw_contaminantes c ON m.contaminante_id = c.contaminante_id
WHERE c.contaminante_id IS NULL
AND m.contaminante_id IS NOT NULL;

-- HUÉRFANOS - raw_mediciones → raw_estaciones
SELECT m.medicion_id, m.estacion_id
FROM raw_mediciones m
LEFT JOIN raw_estaciones e ON m.estacion_id = e.estacion_id
WHERE e.estacion_id IS NULL
AND m.estacion_id IS NOT NULL;

-- 7. MUESTREO DE VALORES NO ESTANDARIZADOS - Valores que representan la misma cosa, pero están escritos de forma diferentes
-- MUESTREO - raw_municipios
SELECT DISTINCT municipio    COLLATE utf8mb4_0900_bin AS municipio    FROM raw_municipios ORDER BY 1;
SELECT DISTINCT departamento COLLATE utf8mb4_0900_bin AS departamento FROM raw_municipios ORDER BY 1;
SELECT DISTINCT region       COLLATE utf8mb4_0900_bin AS region       FROM raw_municipios ORDER BY 1;

-- MUESTREO - raw_alertas_ambientales
SELECT DISTINCT nivel_alerta          COLLATE utf8mb4_0900_bin AS nivel_alerta          FROM raw_alertas_ambientales ORDER BY 1;
SELECT DISTINCT contaminante_causante COLLATE utf8mb4_0900_bin AS contaminante_causante FROM raw_alertas_ambientales ORDER BY 1;

-- MUESTREO - raw_contaminantes
SELECT DISTINCT nombre        COLLATE utf8mb4_0900_bin AS nombre        FROM raw_contaminantes ORDER BY 1;
SELECT DISTINCT codigo        COLLATE utf8mb4_0900_bin AS codigo        FROM raw_contaminantes ORDER BY 1;
SELECT DISTINCT unidad_medida COLLATE utf8mb4_0900_bin AS unidad_medida FROM raw_contaminantes ORDER BY 1;
SELECT DISTINCT categoria     COLLATE utf8mb4_0900_bin AS categoria     FROM raw_contaminantes ORDER BY 1;

-- MUESTREO - raw_estaciones
SELECT DISTINCT nombre_estacion   COLLATE utf8mb4_0900_bin AS nombre_estacion   FROM raw_estaciones ORDER BY 1;
SELECT DISTINCT tipo_estacion     COLLATE utf8mb4_0900_bin AS tipo_estacion     FROM raw_estaciones ORDER BY 1;
SELECT DISTINCT estado            COLLATE utf8mb4_0900_bin AS estado            FROM raw_estaciones ORDER BY 1;
SELECT DISTINCT fecha_instalacion COLLATE utf8mb4_0900_bin AS fecha_instalacion FROM raw_estaciones ORDER BY 1;

-- MUESTREO DE VALORES NO ESTANDARIZADOS - raw_mediciones
SELECT DISTINCT calidad_dato COLLATE utf8mb4_0900_bin AS calidad_dato FROM raw_mediciones ORDER BY 1;
SELECT REGEXP_REPLACE(fecha, '[0-9]', '9') AS formato_fecha, -- convierte el formato a 99-99-9999
      min(fecha) AS ejemplo
FROM raw_mediciones
GROUP BY formato_fecha;
SELECT DISTINCT concentracion    FROM raw_mediciones ORDER BY concentracion    ASC  LIMIT 15;
SELECT DISTINCT concentracion    FROM raw_mediciones ORDER BY concentracion    DESC LIMIT 15;
SELECT DISTINCT temperatura      FROM raw_mediciones ORDER BY temperatura      ASC  LIMIT 15;
SELECT DISTINCT temperatura      FROM raw_mediciones ORDER BY temperatura      DESC LIMIT 15;
SELECT DISTINCT humedad          FROM raw_mediciones ORDER BY humedad          ASC  LIMIT 15;
SELECT DISTINCT humedad          FROM raw_mediciones ORDER BY humedad          DESC LIMIT 15;
SELECT DISTINCT velocidad_viento FROM raw_mediciones ORDER BY velocidad_viento ASC  LIMIT 15;
SELECT DISTINCT velocidad_viento FROM raw_mediciones ORDER BY velocidad_viento DESC LIMIT 15;
 

-- 8 OUTLIERS  -- Valor muy alejado del comportamiento normal de los datos
-- No aplica para municipios, alertas y contaminantes (datos categóricos)

-- Outliers - raw_estaciones
SELECT estacion_id, nombre_estacion, latitud, longitud
FROM raw_estaciones
WHERE latitud  NOT BETWEEN -90  AND 90       
   OR longitud NOT BETWEEN -180 AND 180;
   
   -- Outliers - raw_mediciones
WITH valores AS (                                                       -- Método IQR
    SELECT 'concentracion' AS columna,
           CAST(concentracion AS DECIMAL(10,2)) AS valor  -- lo convierte a decimal porque esta en texto, permite 10 digitos en total y 2 después del punto.
    FROM raw_mediciones
    WHERE concentracion REGEXP '^-?[0-9]+([.][0-9]+)?$'  -- solamente nos quedamos con números si hay texto no los incluye 
    UNION ALL
    SELECT 'temperatura', CAST(temperatura AS DECIMAL(10,2))
    FROM raw_mediciones
    WHERE temperatura REGEXP '^-?[0-9]+([.][0-9]+)?$'
    UNION ALL
    SELECT 'humedad', CAST(humedad AS DECIMAL(10,2))
    FROM raw_mediciones
    WHERE humedad REGEXP '^-?[0-9]+([.][0-9]+)?$'
    UNION ALL
    SELECT 'velocidad_viento', CAST(velocidad_viento AS DECIMAL(10,2))
    FROM raw_mediciones
    WHERE velocidad_viento REGEXP '^-?[0-9]+([.][0-9]+)?$'
),
posiciones AS (                                                                 -- ordena los valores de cada variable de menor a mayor y asignales una posición
    SELECT columna,                                                             -- row number asigna un número consecutivo a cada fila
           valor,                                                                   
           ROW_NUMBER() OVER (PARTITION BY columna ORDER BY valor) AS posicion,  -- partition by hace que la numeración empiece por cada variable humedad, temperatura, etc y los ordena
           COUNT(*)     OVER (PARTITION BY columna)                AS total      -- luego hacemos un conteo de cada variable por valor 
    FROM valores
),
cuartiles AS (
    SELECT columna,                                                                -- calculamos los cuartiles Q1 25% Q2 50% y Q3 75%
           MAX(CASE WHEN posicion = ROUND(total * 0.25) THEN valor END) AS q1,     -- IQR=Q3-Q1 RANGO INTERCUARTILICO
           MAX(CASE WHEN posicion = ROUND(total * 0.50) THEN valor END) AS q2,
           MAX(CASE WHEN posicion = ROUND(total * 0.75) THEN valor END) AS q3
    FROM posiciones
    GROUP BY columna
),
limites AS (
    SELECT columna, q1, q2, q3,                                                    -- limite inferior =q1 - 1,5 * IQR 
           q3 - q1              AS iqr,                                            -- limite superior = q3 - 1,5 * IQR
           q1 - 1.5 * (q3 - q1) AS limite_inferior,
           q3 + 1.5 * (q3 - q1) AS limite_superior
    FROM cuartiles
)
SELECT l.columna,
       l.q1, l.q2, l.q3, l.iqr,
       l.limite_inferior,
       l.limite_superior,
       SUM(v.valor < l.limite_inferior OR v.valor > l.limite_superior) AS outliers,
       MIN(v.valor) AS valor_minimo,
       MAX(v.valor) AS valor_maximo
FROM limites l
JOIN valores v ON v.columna = l.columna
GROUP BY l.columna, l.q1, l.q2, l.q3, l.iqr, l.limite_inferior, l.limite_superior
ORDER BY FIELD(l.columna, 'concentracion', 'temperatura', 'humedad', 'velocidad_viento');

SELECT
    SUM(concentracion    REGEXP '^-?[0-9]+([.][0-9]+)?$' AND CAST(concentracion    AS DECIMAL(10,2)) < 0)   AS concentracion_negativa,
    SUM(temperatura      REGEXP '^-?[0-9]+([.][0-9]+)?$' AND CAST(temperatura      AS DECIMAL(10,2)) > 50)  AS temperatura_mayor_50,
    SUM(humedad          REGEXP '^-?[0-9]+([.][0-9]+)?$' AND CAST(humedad          AS DECIMAL(10,2)) < 0)   AS humedad_negativa,
    SUM(humedad          REGEXP '^-?[0-9]+([.][0-9]+)?$' AND CAST(humedad          AS DECIMAL(10,2)) > 100) AS humedad_mayor_100,
    SUM(velocidad_viento REGEXP '^-?[0-9]+([.][0-9]+)?$' AND CAST(velocidad_viento AS DECIMAL(10,2)) < 0)   AS viento_negativo,
    SUM(hora NOT BETWEEN 0 AND 23)                                                                           AS hora_fuera_rango
FROM raw_mediciones;

