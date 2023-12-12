--Crear la tabla alumnos
    CREATE TABLE
        IF NOT EXISTS
        alumnos(
            id INT AUTO_INCREMENT PRIMARY KEY,
            nombre VARCHAR(50) NOT NULL,
            apellidos VARCHAR(50) NOT NULL,
            correo_electronico VARCHAR(100) NOT NULL);

--Insertar registros de prueba
    INSERT INTO alumnos(nombre, apellidos, correo_electronico)
        VALUES('Juan', 'Pérez', 'juan.perez@example.com'),
    ('María', 'Gómez', 'maria.gomez@example.com'),
    ('Carlos', 'López', 'carlos.lopez@example.com');

--Puedes agregar más registros si lo deseas

    -- Mostrar la tabla
        SELECT *
            FROM alumnos;
