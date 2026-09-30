--- ============================================================================
-- CAPA ORO (GOLD): CARGA DESDE PLATA (PROCEDIMIENTO ALMACENADO) Y PRUEBAS QA
-- ============================================================================
USE ambiental_raw;

DROP PROCEDURE IF EXISTS sp_cargar_capa_oro;

DELIMITER //

CREATE PROCEDURE sp_cargar_capa_oro()
BEGIN
    DECLARE codigo  CHAR(5) DEFAULT '00000';
    DECLARE mensaje TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 codigo = RETURNED_SQLSTATE, mensaje = MESSAGE_TEXT;
        ROLLBACK;
        SET SQL_SAFE_UPDATES = 1;
        SELECT CONCAT('ERROR SQL [', codigo, ']: ', mensaje) AS resultado;
    END;

    START TRANSACTION;

    -- Vaciado: primero la tabla de hechos, luego las dimensiones.
    -- SQL_SAFE_UPDATES = 0 permite DELETE sin WHERE (Workbench lo bloquea por defecto).
    SET SQL_SAFE_UPDATES = 0;
    DELETE FROM fact_mediciones;
    DELETE FROM dim_alerta_ambiental;
    DELETE FROM dim_contaminante;
    DELETE FROM dim_estacion;
    SET SQL_SAFE_UPDATES = 1;

    -- 1. Dimensión alerta ambiental
    INSERT INTO dim_alerta_ambiental (alerta_id, nivel_alerta, contaminante_causante, descripcion)
    SELECT alerta_id, nivel_alerta, contaminante_causante, descripcion
    FROM v_silver_alertas_ambientales;

    -- 2. Dimensión contaminante
    INSERT INTO dim_contaminante (contaminante_id, codigo, nombre, categoria, unidad_medida)
    SELECT contaminante_id, codigo, nombre, categoria, unidad_medida
    FROM v_silver_contaminantes;

    -- 3. Dimensión estación
    INSERT INTO dim_estacion (estacion_id, nombre_estacion, tipo_estacion, latitud, longitud,
                              municipio, departamento, region)
    SELECT estacion_id, nombre_estacion, tipo_estacion, latitud, longitud,
           municipio, departamento, region
    FROM v_silver_estaciones;

    -- 4. Tabla de hechos: se reemplaza cada llave natural por la llave sustituta
    INSERT INTO fact_mediciones (medicion_id, fecha, estacion_key, contaminante_key, alerta_key,
                                 concentracion, temperatura, humedad, velocidad_viento)
    SELECT m.medicion_id,
           m.fecha,
           e.estacion_key,
           c.contaminante_key,
           a.alerta_key,
           m.concentracion,
           m.temperatura,
           m.humedad,
           m.velocidad_viento
    FROM v_silver_mediciones m
    INNER JOIN dim_estacion         e ON m.estacion_id     = e.estacion_id
    INNER JOIN dim_contaminante     c ON m.contaminante_id = c.contaminante_id
    INNER JOIN dim_alerta_ambiental a ON m.alerta_id       = a.alerta_id;

    COMMIT;

    SELECT 'ÉXITO: capa Oro cargada correctamente.' AS resultado;
END //

DELIMITER ;

CALL sp_cargar_capa_oro();

-- ============================================================================
-- PRUEBAS DE CALIDAD (QA)
-- ============================================================================

-- QA-01 Volumen por tabla
SELECT 'dim_alerta_ambiental' AS tabla, COUNT(*) AS registros FROM dim_alerta_ambiental
UNION ALL
SELECT 'dim_contaminante', COUNT(*) FROM dim_contaminante
UNION ALL
SELECT 'dim_estacion', COUNT(*) FROM dim_estacion
UNION ALL
SELECT 'fact_mediciones', COUNT(*) FROM fact_mediciones;

-- QA-02 Conciliación Plata vs Oro: la tabla de hechos debe tener las mismas filas que la vista
SELECT (SELECT COUNT(*) FROM v_silver_mediciones) AS filas_plata,
       (SELECT COUNT(*) FROM fact_mediciones)     AS filas_oro;

-- QA-03 Duplicados en la tabla de hechos
SELECT medicion_id, COUNT(*) AS veces
FROM fact_mediciones
GROUP BY medicion_id
HAVING COUNT(*) > 1;

-- QA-04 Huérfanos: mediciones sin estación, contaminante o alerta
SELECT
    SUM(e.estacion_key     IS NULL) AS sin_estacion,
    SUM(c.contaminante_key IS NULL) AS sin_contaminante,
    SUM(a.alerta_key       IS NULL) AS sin_alerta
FROM fact_mediciones f
LEFT JOIN dim_estacion         e ON f.estacion_key     = e.estacion_key
LEFT JOIN dim_contaminante     c ON f.contaminante_key = c.contaminante_key
LEFT JOIN dim_alerta_ambiental a ON f.alerta_key       = a.alerta_key;

-- QA-05 Métricas sin NULL
SELECT
    SUM(concentracion    IS NULL) AS concentracion_nulos,
    SUM(temperatura      IS NULL) AS temperatura_nulos,
    SUM(humedad          IS NULL) AS humedad_nulos,
    SUM(velocidad_viento IS NULL) AS velocidad_viento_nulos,
    SUM(fecha            IS NULL) AS fecha_nulos
FROM fact_mediciones;

-- QA-06 Valores fuera de dominio
SELECT
    SUM(concentracion < 0)                AS concentracion_negativa,
    SUM(temperatura > 50)                 AS temperatura_mayor_50,
    SUM(humedad < 0 OR humedad > 100)     AS humedad_fuera_rango,
    SUM(velocidad_viento < 0)             AS viento_negativo
FROM fact_mediciones;

-- QA-07 Coordenadas válidas en dim_estacion
SELECT estacion_id, latitud, longitud
FROM dim_estacion
WHERE latitud  NOT BETWEEN -90  AND 90
   OR longitud NOT BETWEEN -180 AND 180;