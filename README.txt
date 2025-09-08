-Paso 1: Crear la Base de Datos
1) Abre pgAdmin y conéctate a tu servidor PostgreSQL
2) Haz clic derecho en "Databases" en el panel izquierdo
3) Selecciona "Create" > "Database..."
4) En el campo "Database" escribe: airline_db
5) Haz clic en "Save"


-Paso 2: Ejecutar los Scripts SQL en Orden
    Ejecutar loadData.sql (esquema de tablas):
1) Haz clic derecho en la base de datos airline_db recién creada
2) Selecciona "Query Tool" (o presiona Alt+Shift+Q)
3) En el Query Tool, haz clic en el icono "Open File" (carpeta) 
4) Busca y selecciona el archivo loadData.sql
5) Haz clic en "Execute/Refresh" (icono de play) o presiona F5
6) Verifica que aparezca un mensaje de éxito en la parte inferior


    Ejecutar dbCreate.sql (datos):
1) Limpia el editor (Ctrl+A, Delete)
2) Abre el archivo dbCreate.sql 
3) Ejecuta el script 
4) Verifica los mensajes de éxito


    Ejecutar runStatemes.sql (consultas):
1) Limpia el editor (Ctrl+A, Delete)
2) Abre el archivo runStatemes.sql
3) Ejecuta el script
4) Verás los resultados de todas las consultas


Alternativa: Ejecutar consultas individualmente
Puedes copiar y pegar cada consulta individual del archivo runStatemes.sql y ejecutarlas una por una para ver los resultados por separado.