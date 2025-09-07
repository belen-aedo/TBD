-- 1) Tablas raíz
CREATE TABLE COMPANIA (
    compania_id SERIAL PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL
);

CREATE TABLE MODELO (
    id_modelo SERIAL PRIMARY KEY,
    nombre_modelo VARCHAR(100) NOT NULL
);

-- 2) SECCION (requerida por PASAJE)
CREATE TABLE SECCION (
    id_seccion SERIAL PRIMARY KEY,
    tipo_seccion VARCHAR(20) NOT NULL CHECK (tipo_seccion IN ('economy', 'economy_premium', 'business', 'first_class'))
);

-- 3) Tablas que dependen solo de COMPANIA
CREATE TABLE CLIENTE (
    nro_documento VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    nacionalidad VARCHAR(30) NOT NULL,
    compania_id INT NOT NULL,
    FOREIGN KEY (compania_id) REFERENCES COMPANIA(compania_id)
);

CREATE TABLE AVION (
    id_avion SERIAL PRIMARY KEY,
    anio_avion DATE NOT NULL,
    material_avion VARCHAR(20) NOT NULL,
    cantidad_pasajeros INT NOT NULL CHECK (cantidad_pasajeros > 0),
    id_modelo INT NOT NULL,
    compania_id INT NOT NULL,
    FOREIGN KEY (id_modelo) REFERENCES MODELO(id_modelo),
    FOREIGN KEY (compania_id) REFERENCES COMPANIA(compania_id)
);

CREATE TABLE EMPLEADO (
    rut_e VARCHAR(10) PRIMARY KEY,
    celular INT NOT NULL,
    nombre_e VARCHAR(20) NOT NULL,
    apellido_e VARCHAR(20) NOT NULL,
    correo VARCHAR(50) NOT NULL UNIQUE,
    sobrecargo BOOLEAN NOT NULL DEFAULT FALSE,
    piloto BOOLEAN NOT NULL DEFAULT FALSE,
    compania_id INT NOT NULL,
    FOREIGN KEY (compania_id) REFERENCES COMPANIA(compania_id),
    CONSTRAINT chk_cargo_empleado CHECK (
        (sobrecargo = TRUE AND piloto = FALSE) OR 
        (sobrecargo = FALSE AND piloto = TRUE)
    )
);
-- 4) VUELO (requiere AVION y COMPANIA)
CREATE TABLE VUELO (
    id_vuelo SERIAL PRIMARY KEY,
    origen VARCHAR(20) NOT NULL,
    destino VARCHAR(20) NOT NULL,
    fecha_vuelo TIMESTAMPTZ NOT NULL,
    id_avion INT NOT NULL,
    compania_id INT NOT NULL,
    FOREIGN KEY (id_avion) REFERENCES AVION(id_avion),
    FOREIGN KEY (compania_id) REFERENCES COMPANIA(compania_id)
);

-- 5) PASAJE (requiere SECCION, CLIENTE, VUELO)
CREATE TABLE PASAJE (
    id_pasaje INT PRIMARY KEY,
    hora_embarque VARCHAR(20) NOT NULL,
    lugar_destino VARCHAR(20) NOT NULL,
    puerta VARCHAR(20) NOT NULL,
    numero_asiento INT NOT NULL,
    id_seccion INT,
    nro_documento VARCHAR(10),
    vuelo_id INT,
    FOREIGN KEY (id_seccion) REFERENCES SECCION(id_seccion),
    FOREIGN KEY (nro_documento) REFERENCES CLIENTE(nro_documento),
    FOREIGN KEY (vuelo_id) REFERENCES VUELO(id_vuelo)
);

-- 6) CLIENTE_COMP (requiere CLIENTE y VUELO)
CREATE TABLE CLIENTE_COMP (
    compa_id SERIAL PRIMARY KEY,
    nro_documento VARCHAR(10) NOT NULL,
    vuelo_id INT NOT NULL,
    FOREIGN KEY (nro_documento) REFERENCES CLIENTE(nro_documento),
    FOREIGN KEY (vuelo_id) REFERENCES VUELO(id_vuelo)
);

-- 7) COSTO (requiere PASAJE)
CREATE TABLE COSTO (
    id_costo SERIAL PRIMARY KEY,
    nombre_costo VARCHAR(50) NOT NULL,
    monto_costo DECIMAL(10,2) NOT NULL CHECK (monto_costo >= 0),
    id_pasaje INT NOT NULL,
    FOREIGN KEY (id_pasaje) REFERENCES PASAJE(id_pasaje)
);

-- 8) SUELDO (requiere EMPLEADO)
CREATE TABLE SUELDO (
    id_sueldo SERIAL PRIMARY KEY,
    fecha_pago DATE NOT NULL,
    monto_pago DECIMAL(10,2) NOT NULL CHECK (monto_pago >= 0),
    rut_e VARCHAR(10) NOT NULL,
    FOREIGN KEY (rut_e) REFERENCES EMPLEADO(rut_e)
);

-- 9) EMP_VUELO (requiere VUELO y EMPLEADO)
CREATE TABLE EMP_VUELO (
    id_emp_vuelo SERIAL PRIMARY KEY,
    vuelo_id INT NOT NULL,
    rut_e VARCHAR(10) NOT NULL,
    FOREIGN KEY (vuelo_id) REFERENCES VUELO(id_vuelo),
    FOREIGN KEY (rut_e) REFERENCES EMPLEADO(rut_e)
);
