# Sección A — Gestión de alumnos

Aplicación desarrollada con Dart y Flutter para el laboratorio de las semanas 7 y 8.

Permite iniciar sesión como docente, registrar alumnos con sus notas, consultar su condición académica y administrar el perfil.

## Datos académicos

- **Estudiante:** Rony Bellido Chambi
- **Docente:** Hugo Felipe Torrico Marquez
- **Institución:** Tecsup
- **Periodo:** 2026-II

## Pantallas

| Pantalla | Funciones |
|---|---|
| Login | Validación de credenciales y visibilidad de contraseña |
| Menú | Acceso al registro, listado, perfil y cierre de sesión |
| Alumnos | Búsqueda, edición y eliminación con confirmación |
| Registrar alumno | Registro de nombres, apellidos y nota |
| Perfil | Edición de nombre, teléfono y avatar |

## Contenidos del laboratorio

- **ListView:** presentación de alumnos y opciones del menú.
- **ListTile:** organización de información e iconos.
- **Listas y mapas:** almacenamiento y manejo de los datos.
- **Rutas:** navegación entre las cinco pantallas.
- **Tema global:** colores, campos y botones compartidos.
- **Cards:** agrupación visual de los elementos.

## Reglas de funcionamiento

- Nombre, apellido y nota son obligatorios.
- La nota debe estar entre 0 y 20; se admiten decimales.
- Un alumno aprueba desde 11.
- La eliminación solicita confirmación.
- Los alumnos y el perfil se guardan localmente.
- Cerrar sesión limpia el historial de navegación.

## Acceso de demostración

- **Email:** maria.gonzalez@correo.com
- **Contraseña:** 123456

La autenticación es local y de demostración. La recuperación de contraseña no envía correos.

## Tecnologías

- Flutter 3.35.3
- Dart 3.9.2
- shared_preferences 2.5.3
- image_picker 1.1.2

## Ejecución

Desde la carpeta del proyecto:

```bash
flutter pub get
flutter run -d chrome --web-port 7357
```

En web se utiliza un puerto fijo para mantener el mismo origen de almacenamiento. Los datos dependen del navegador y pueden eliminarse al borrar sus datos o utilizar sesiones temporales.

## Código adicional comentado

Los comentarios identificados con `EXTRA` explican:

- Actualización de pantallas con ChangeNotifier y AnimatedBuilder.
- Conversión de listas y mapas a JSON para el guardado local.
- Validación de notas con punto o coma decimal.
- Conversión del avatar a base64 para conservar una imagen pequeña.

## Evidencias de entrega

Capturas requeridas: Login, Menú, Alumnos, Registrar Alumno y Perfil.

## Repositorio

https://github.com/aleyto123/semana_7_y_8_Bellido
