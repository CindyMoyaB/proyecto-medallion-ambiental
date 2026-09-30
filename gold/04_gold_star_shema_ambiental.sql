-- ============================================================================
-- CAPA ORO (GOLD): MODELO DIMENSIONAL EN ESTRELLA
-- ============================================================================
USE ambiental_raw;

-- Borrado en orden inverso a las dependencias: primero la tabla de hechos
-- (tiene las FK) y después las dimensiones.
DROP TABLE IF EXISTS fact_mediciones;
DROP TABLE IF EXISTS dim_alerta_ambiental;
DROP TABLE IF EXISTS dim_contaminante;
DROP TABLE IF EXISTS dim_estacion;

-- ============================================================================
-- 1. DIMENSIÓN ALERTA AMBIENTAL
-- ============================================================================
CREATE TABLE dim_alerta_ambiental (
    alerta_key             INT          AUTO_INCREMENT PRIMARY KEY,   
    alerta_id              INT          NOT NULL UNIQUE,              
    nivel_alerta           VARCHAR(50)  NOT NULL,
    contaminante_causante  VARCHAR(50)  NOT NULL,
    descripcion            VARCHAR(255) NOT NULL
);

-- ============================================================================
-- 2. DIMENSIÓN CONTAMINANTE
-- ============================================================================
CREATE TABLE dim_contaminante (
    contaminante_key  INT          AUTO_INCREMENT PRIMARY KEY,
    contaminante_id   INT          NOT NULL UNIQUE,
    codigo            VARCHAR(20)  NOT NULL,
    nombre            VARCHAR(100) NOT NULL,
    categoria         VARCHAR(50)  NOT NULL,
    unidad_medida     VARCHAR(20)  NOT NULL
);

-- ============================================================================
-- 3. DIMENSIÓN ESTACIÓN (incluye los datos del municipio)
-- ============================================================================
CREATE TABLE dim_estacion (
    estacion_key     INT           AUTO_INCREMENT PRIMARY KEY,
    estacion_id      VARCHAR(10)   NOT NULL UNIQUE,
    nombre_estacion  VARCHAR(150)  NOT NULL,
    tipo_estacion    VARCHAR(50)   NOT NULL,
    latitud          DECIMAL(10,6) NULL,          
    longitud         DECIMAL(10,6) NULL,
    municipio        VARCHAR(100)  NOT NULL,
    departamento     VARCHAR(100)  NOT NULL,
    region           VARCHAR(100)  NOT NULL
);

-- ============================================================================
-- 4. TABLA DE HECHOS: MEDICIONES
-- ============================================================================
CREATE TABLE fact_mediciones (
    medicion_key      BIGINT        AUTO_INCREMENT PRIMARY KEY,
    medicion_id       BIGINT        NOT NULL,
    fecha             DATE,
    estacion_key      INT           NOT NULL,
    contaminante_key  INT           NOT NULL,
    alerta_key        INT           NOT NULL,
    concentracion     DECIMAL(10,2),
    temperatura       DECIMAL(10,2),
    humedad           DECIMAL(10,2),
    velocidad_viento  DECIMAL(10,2),

    CONSTRAINT fk_fact_estacion                                         
        FOREIGN KEY (estacion_key)     REFERENCES dim_estacion (estacion_key),
    CONSTRAINT fk_fact_contaminante
        FOREIGN KEY (contaminante_key) REFERENCES dim_contaminante (contaminante_key),
    CONSTRAINT fk_fact_alerta
        FOREIGN KEY (alerta_key)       REFERENCES dim_alerta_ambiental (alerta_key)
);

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'ambiental_raw'
  AND (TABLE_NAME LIKE 'dim%' OR TABLE_NAME LIKE 'fact%')
ORDER BY TABLE_NAME;