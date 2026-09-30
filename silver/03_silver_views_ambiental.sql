-- ============================================================================
-- CAPA PLATA (SILVER) - VISTAS
-- ============================================================================
use ambiental_raw;
-- ============================================================================
-- VISTA SILVER: v_silver_municipios
-- Problemas resueltos:
--   · Espacios sobrantes                  → TRIM
--   · Mayúsculas/minúsculas mezcladas     → UPPER
--   · Tildes faltantes                    → CASE 
--   · Bogota sin "D.C."                   → CASE
--   · Error de digitación 'SANTANDERE'    → CASE
-- ===============================================================================
CREATE OR REPLACE VIEW v_silver_municipios AS      
WITH datos_limpios AS (                            
    SELECT
        TRIM(municipio_id)        AS municipio_id,
        UPPER(TRIM(municipio))    AS municipio,
		UPPER(TRIM(departamento)) AS departamento,
        UPPER(TRIM(region))       AS region
    FROM raw_municipios
)
SELECT                                             
    municipio_id,
    CASE
        WHEN municipio IN ('BOGOTA', 'BOGOTA D.C.', 'BOGOTÁ D.C.') THEN 'BOGOTÁ D.C.'   
        WHEN municipio IN ('MEDELLIN', 'MEDELLÍN')                  THEN 'MEDELLÍN'      
        WHEN municipio IN ('IBAGUE', 'IBAGUÉ')                      THEN 'IBAGUÉ'        
        ELSE municipio                                          
    END AS municipio,
    CASE
        WHEN departamento IN ('ATLANTICO', 'ATLÁNTICO') THEN 'ATLÁNTICO'
        WHEN departamento IN  ('BOLIVAR', 'BOLÍVAR')     THEN 'BOLÍVAR'
        WHEN departamento = 'SANTANDERE'               THEN 'SANTANDER'               
        ELSE departamento
    END AS departamento,
    CASE
	WHEN region IN ('PACIFICA', 'PACÍFICA') THEN 'PACÍFICA'
        ELSE region
    END AS region
FROM datos_limpios;

SELECT * FROM v_silver_municipios ORDER BY municipio, municipio_id;

-- ============================================================================
-- VISTA SILVER: v_silver_alertas_ambientales
-- Problemas resueltos:
--   · nivel_alerta con 9 escrituras (mayúsculas y espacios) → UPPER + TRIM
-- contaminante_causante y descripcion: sin hallazgos; TRIM preventivo
-- ============================================================================
CREATE OR REPLACE VIEW v_silver_alertas_ambientales AS
SELECT
    alerta_id,                  
    UPPER(TRIM(nivel_alerta))          AS nivel_alerta,         
    UPPER(TRIM(contaminante_causante)) AS contaminante_causante,
    TRIM(descripcion)                  AS descripcion
FROM raw_alertas_ambientales;

SELECT * FROM v_silver_alertas_ambientales ORDER BY alerta_id;

-- ============================================================================
-- VISTA SILVER: v_silver_contaminantes
-- Problemas resueltos:
--   · Espacios y mayúsculas mezcladas           → TRIM + UPPER
--   · nombre sin tildes (Dioxido de Nitrogeno)  → CASE
--   · codigo 'PM25' vs 'PM2.5'                  → CASE
--   · unidad 'ug/m3' vs 'µg/m3'                 → CASE
-- Decisión: se conservan los 8 ids originales. Los ids 1-2 (PM2.5) y 4-5 (NO2)
-- representan el mismo contaminante; no se unifican para no dejar mediciones
-- huérfanas.
-- ============================================================================
CREATE OR REPLACE VIEW v_silver_contaminantes AS
WITH datos_limpios AS (
    SELECT
        contaminante_id,
        UPPER(TRIM(nombre))    AS nombre,
        UPPER(TRIM(codigo))    AS codigo,
        TRIM(unidad_medida)    AS unidad_medida,     
        UPPER(TRIM(categoria)) AS categoria
    FROM raw_contaminantes
)
SELECT
    contaminante_id,
    CASE
        WHEN nombre IN ('DIOXIDO DE NITROGENO', 'DIÓXIDO DE NITRÓGENO') THEN 'DIÓXIDO DE NITRÓGENO'
        ELSE nombre
    END AS nombre,
    CASE
        WHEN codigo = 'PM25' THEN 'PM2.5'
        ELSE codigo
    END AS codigo,
    CASE
        WHEN unidad_medida = 'ug/m3' THEN 'µg/m3'     
        ELSE unidad_medida                            
    END AS unidad_medida,
    categoria
FROM datos_limpios;

SELECT * FROM v_silver_contaminantes ORDER BY contaminante_id;

-- ============================================================================
-- VISTA SILVER: v_silver_estaciones
-- Problemas resueltos:
--   · nombre_estacion: espacios, mayúsculas, "Estacion" sin tilde → TRIM + UPPER + REPLACE
--   · tipo_estacion: 7 variantes, abreviatura 'U'                  → UPPER + CASE
--   · estado: 6 variantes ('A', 'Activo'...)                       → UPPER + CASE
--   · latitud/longitud fuera de rango (EST008: 250, -500)          → NULL
--   · fecha_instalacion en 4 formatos                              → REGEXP + STR_TO_DATE
--   · Trae municipio, departamento y region desde v_silver_municipios (LEFT JOIN)
-- ============================================================================
CREATE OR REPLACE VIEW v_silver_estaciones AS
WITH datos_limpios AS (                                       
    SELECT
        TRIM(estacion_id)                                                AS estacion_id,
        REPLACE(UPPER(TRIM(nombre_estacion)), 'ESTACION ', 'ESTACIÓN ')  AS nombre_estacion,  
        TRIM(municipio_id)                                               AS municipio_id,
        UPPER(TRIM(tipo_estacion))                                       AS tipo_estacion,
        latitud,
        longitud,
        TRIM(fecha_instalacion)                                          AS fecha_instalacion,
        UPPER(TRIM(estado))                                              AS estado
    FROM raw_estaciones
),
datos_estandarizados AS (                                     
    SELECT
        estacion_id,
        nombre_estacion,
        municipio_id,
        CASE
            WHEN tipo_estacion = 'U' THEN 'URBANA'            -- abreviatura
            ELSE tipo_estacion
        END AS tipo_estacion,
        CASE
            WHEN latitud BETWEEN -90 AND 90 THEN latitud      
            ELSE NULL                                         
        END AS latitud,
        CASE
            WHEN longitud BETWEEN -180 AND 180 THEN longitud
            ELSE NULL
        END AS longitud,
        CASE                                                 
            WHEN fecha_instalacion REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(fecha_instalacion, '%Y-%m-%d')
            WHEN fecha_instalacion REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(fecha_instalacion, '%Y/%m/%d')
            WHEN fecha_instalacion REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(fecha_instalacion, '%d/%m/%Y')
            WHEN fecha_instalacion REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(fecha_instalacion, '%d-%m-%Y')
            ELSE NULL
        END AS fecha_instalacion,
        CASE
            WHEN estado IN ('A', 'ACTIVA', 'ACTIVO') THEN 'ACTIVA'   
            ELSE estado
        END AS estado
    FROM datos_limpios
)
SELECT                                                       
    e.estacion_id,
    e.nombre_estacion,
    e.municipio_id,
    m.municipio,
    m.departamento,
    m.region,
    e.tipo_estacion,
    e.latitud,
    e.longitud,
    e.fecha_instalacion,
    e.estado
FROM datos_estandarizados e
LEFT JOIN v_silver_municipios m ON e.municipio_id = m.municipio_id;

SELECT * FROM v_silver_estaciones ORDER BY estacion_id;

-- ============================================================================
-- VISTA SILVER: v_silver_mediciones
-- Problemas resueltos:
--   · Medidas guardadas como texto                           → REGEXP + CAST a DECIMAL(10,2)
--   · Seudo-nulos ('', 'N/A', 'NA', 'Sin dato', 'No disponible') → NULL (todo lo que no es número)
--   · fecha en 3 formatos                                    → REGEXP + STR_TO_DATE
--   · alerta_id NULL (98 %) = sin alerta                     → COALESCE(alerta_id, 0)
--   · calidad_dato: 7 variantes (VALIDO, Válido, OK...)      → UPPER + TRIM + CASE; 'N/A' → NULL
--   · Valores imposibles (concentración < 0, temperatura > 50,
--     humedad < 0 o > 100, viento < 0)                       → NULL
--   · Faltantes en las 4 medidas                             → imputación con la mediana
--   · Atípicos fuera de los límites IQR (350.5 µg/m3)        → capping al límite
--   · 5 duplicados exactos por medicion_id                   → ROW_NUMBER, se conserva fila = 1
-- Limitación: 100001 y 100002 (duplicado parcial con ids distintos) se conservan.
-- ============================================================================
CREATE OR REPLACE VIEW v_silver_mediciones AS
WITH datos_convertidos AS (
    SELECT
        medicion_id,
        TRIM(estacion_id)       AS estacion_id,
        contaminante_id,
        COALESCE(alerta_id, 0)  AS alerta_id,
        CASE
            WHEN TRIM(fecha) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(TRIM(fecha), '%Y-%m-%d')
            WHEN TRIM(fecha) REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(TRIM(fecha), '%Y/%m/%d')
            WHEN TRIM(fecha) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(TRIM(fecha), '%d/%m/%Y')
            ELSE NULL
        END AS fecha,
        hora,
        CASE WHEN TRIM(concentracion)    REGEXP '^-?[0-9]+([.][0-9]+)?$' THEN CAST(TRIM(concentracion)    AS DECIMAL(10,2)) ELSE NULL END AS concentracion,
        CASE WHEN TRIM(temperatura)      REGEXP '^-?[0-9]+([.][0-9]+)?$' THEN CAST(TRIM(temperatura)      AS DECIMAL(10,2)) ELSE NULL END AS temperatura,
        CASE WHEN TRIM(humedad)          REGEXP '^-?[0-9]+([.][0-9]+)?$' THEN CAST(TRIM(humedad)          AS DECIMAL(10,2)) ELSE NULL END AS humedad,
        CASE WHEN TRIM(velocidad_viento) REGEXP '^-?[0-9]+([.][0-9]+)?$' THEN CAST(TRIM(velocidad_viento) AS DECIMAL(10,2)) ELSE NULL END AS velocidad_viento,
        CASE
            WHEN UPPER(TRIM(calidad_dato)) IN ('VALIDO', 'VÁLIDO', 'OK', 'CORRECTO') THEN 'VÁLIDO'
            WHEN UPPER(TRIM(calidad_dato)) = 'DUDOSO'                              THEN 'DUDOSO'
            ELSE 'SIN CLASIFICAR'
        END AS calidad_dato
    FROM raw_mediciones
),
datos_validados AS (
    SELECT
        medicion_id, estacion_id, contaminante_id, alerta_id, fecha, hora,
        CASE WHEN concentracion < 0                    THEN NULL ELSE concentracion    END AS concentracion,
        CASE WHEN temperatura > 50                     THEN NULL ELSE temperatura      END AS temperatura,
        CASE WHEN humedad < 0 OR humedad > 100         THEN NULL ELSE humedad          END AS humedad,
        CASE WHEN velocidad_viento < 0                 THEN NULL ELSE velocidad_viento END AS velocidad_viento,
        calidad_dato
    FROM datos_convertidos
),
valores AS (
    SELECT 'concentracion' AS columna, concentracion AS valor FROM datos_validados WHERE concentracion IS NOT NULL
    UNION ALL
    SELECT 'temperatura', temperatura FROM datos_validados WHERE temperatura IS NOT NULL
    UNION ALL
    SELECT 'humedad', humedad FROM datos_validados WHERE humedad IS NOT NULL
    UNION ALL
    SELECT 'velocidad_viento', velocidad_viento FROM datos_validados WHERE velocidad_viento IS NOT NULL
),
posiciones AS (
    SELECT columna, valor,
           ROW_NUMBER() OVER (PARTITION BY columna ORDER BY valor) AS posicion,
           COUNT(*)     OVER (PARTITION BY columna)                AS total
    FROM valores
),
cuartiles AS (
    SELECT columna,
           MAX(CASE WHEN posicion = ROUND(total * 0.25) THEN valor END) AS q1,
           MAX(CASE WHEN posicion = ROUND(total * 0.50) THEN valor END) AS mediana,
           MAX(CASE WHEN posicion = ROUND(total * 0.75) THEN valor END) AS q3
    FROM posiciones
    GROUP BY columna
),
estadisticas AS (
    SELECT
        MAX(CASE WHEN columna = 'concentracion'    THEN mediana END)                   AS med_conc,
        MAX(CASE WHEN columna = 'concentracion'    THEN ROUND(q1 - 1.5 * (q3 - q1), 2) END)      AS inf_conc,
        MAX(CASE WHEN columna = 'concentracion'    THEN ROUND(q3 + 1.5 * (q3 - q1), 2) END)      AS sup_conc,
        MAX(CASE WHEN columna = 'temperatura'      THEN mediana END)                   AS med_temp,
        MAX(CASE WHEN columna = 'temperatura'      THEN ROUND(q1 - 1.5 * (q3 - q1), 2) END)      AS inf_temp,
        MAX(CASE WHEN columna = 'temperatura'      THEN ROUND(q3 + 1.5 * (q3 - q1), 2) END)      AS sup_temp,
        MAX(CASE WHEN columna = 'humedad'          THEN mediana END)                   AS med_hum,
        MAX(CASE WHEN columna = 'humedad'          THEN ROUND(q1 - 1.5 * (q3 - q1), 2) END)      AS inf_hum,
        MAX(CASE WHEN columna = 'humedad'          THEN ROUND(q3 + 1.5 * (q3 - q1), 2) END)      AS sup_hum,
        MAX(CASE WHEN columna = 'velocidad_viento' THEN mediana END)                   AS med_vien,
        MAX(CASE WHEN columna = 'velocidad_viento' THEN ROUND(q1 - 1.5 * (q3 - q1), 2) END)      AS inf_vien,
        MAX(CASE WHEN columna = 'velocidad_viento' THEN ROUND(q3 + 1.5 * (q3 - q1), 2) END)      AS sup_vien
    FROM cuartiles
),
datos_imputados AS (
    SELECT
        d.medicion_id, d.estacion_id, d.contaminante_id, d.alerta_id, d.fecha, d.hora,
        CASE
            WHEN d.concentracion IS NULL       THEN e.med_conc
            WHEN d.concentracion < e.inf_conc  THEN e.inf_conc
            WHEN d.concentracion > e.sup_conc  THEN e.sup_conc
            ELSE d.concentracion
        END AS concentracion,
        CASE
            WHEN d.temperatura IS NULL         THEN e.med_temp
            WHEN d.temperatura < e.inf_temp    THEN e.inf_temp
            WHEN d.temperatura > e.sup_temp    THEN e.sup_temp
            ELSE d.temperatura
        END AS temperatura,
        CASE
            WHEN d.humedad IS NULL             THEN e.med_hum
            WHEN d.humedad < e.inf_hum         THEN e.inf_hum
            WHEN d.humedad > e.sup_hum         THEN e.sup_hum
            ELSE d.humedad
        END AS humedad,
        CASE
            WHEN d.velocidad_viento IS NULL        THEN e.med_vien
            WHEN d.velocidad_viento < e.inf_vien   THEN e.inf_vien
            WHEN d.velocidad_viento > e.sup_vien   THEN e.sup_vien
            ELSE d.velocidad_viento
        END AS velocidad_viento,
        d.calidad_dato
    FROM datos_validados d
    CROSS JOIN estadisticas e
),
datos_deduplicados AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY medicion_id ORDER BY medicion_id) AS fila
    FROM datos_imputados
)
SELECT
    medicion_id, estacion_id, contaminante_id, alerta_id, fecha, hora,
    concentracion, temperatura, humedad, velocidad_viento, calidad_dato
FROM datos_deduplicados
WHERE fila = 1;

SELECT * FROM v_silver_mediciones LIMIT 20;
