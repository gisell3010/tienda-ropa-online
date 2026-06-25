# Arquitectura general del sistema

## Proyecto

El proyecto consiste en el desarrollo de una tienda de ropa online aplicando metodología ágil Scrum.
El sistema está dividido en tres partes principales: frontend, backend y base de datos.

La arquitectura definida para el proyecto es:

React → Spring Boot → PostgreSQL

Esta arquitectura permite separar la interfaz visual, la lógica del sistema y el almacenamiento de la información.

## Arquitectura cliente-servidor

El sistema trabaja bajo una arquitectura cliente-servidor.

El cliente es la aplicación frontend desarrollada en React. Esta parte se encarga de mostrar la interfaz al usuario y consumir los servicios del backend.

El servidor es el backend desarrollado en Spring Boot. Esta parte recibe las peticiones del frontend, procesa la lógica necesaria y se comunica con la base de datos.

La base de datos es PostgreSQL. Allí se almacena la información relacionada con productos, categorías, estilos, tallas, colores, inventarios, usuarios, ventas, pagos y demás datos del sistema.

## Comunicación general del sistema

La comunicación del sistema funciona de la siguiente manera:

React
↓
API REST
↓
Spring Boot
↓
JPA
↓
PostgreSQL

React no se conecta directamente a PostgreSQL.
El frontend envía peticiones HTTP al backend mediante una API REST.

Spring Boot recibe esas peticiones, aplica la lógica correspondiente y se conecta a PostgreSQL mediante JPA.

PostgreSQL se encarga de almacenar y proteger la información mediante tablas, relaciones, restricciones, funciones, procedimientos y triggers cuando es necesario.

## Frontend

El frontend está desarrollado en React.

Sus responsabilidades principales son:

* Mostrar la interfaz gráfica de la tienda online.
* Mostrar el catálogo de productos.
* Presentar la imagen, nombre, precio, tallas, colores y disponibilidad de cada producto.
* Mostrar visualmente cuando un producto está agotado.
* Consumir los endpoints publicados por el backend.
* Enviar solicitudes al backend mediante HTTP.

La estructura inicial del frontend está organizada en carpetas como:

* components
* pages
* services
* routes
* assets
* styles
* context

## Backend

El backend está desarrollado en Spring Boot.

Su responsabilidad principal es funcionar como intermediario entre el frontend y la base de datos.

El backend se encarga de:

* Exponer endpoints mediante API REST.
* Recibir las peticiones enviadas desde React.
* Procesar la lógica del sistema.
* Aplicar validaciones.
* Consultar la base de datos mediante JPA.
* Retornar respuestas en formato JSON.
* Manejar errores y excepciones.

La estructura interna del backend está organizada en los siguientes paquetes:

* controller
* service
* repository
* model
* dto
* config
* exception

## Responsabilidad de los paquetes del backend

### controller

Contiene los controladores REST.
Estos reciben las peticiones HTTP y retornan respuestas en formato JSON.

Ejemplo:

GET /api/productos

### service

Contiene la lógica del negocio.
Aquí se procesa la información antes de enviarla al controlador o antes de consultar la base de datos.

### repository

Contiene las interfaces encargadas de comunicarse con la base de datos mediante Spring Data JPA.

### model

Contiene las entidades del sistema.
Estas clases representan las tablas de PostgreSQL.

Ejemplo:

* Producto
* Categoria
* Estilo
* Talla
* Color
* Inventario

### dto

Contiene los objetos que se envían como respuesta al frontend.
Los DTO permiten enviar solo la información necesaria y no exponer directamente las entidades completas.

### config

Contiene configuraciones generales del backend, como configuración de CORS, conexión, seguridad u otros ajustes necesarios.

### exception

Contiene el manejo de errores y excepciones del sistema.

## Base de datos

La base de datos está desarrollada en PostgreSQL.

Para el Sprint 1, la base de datos se enfoca principalmente en el catálogo de productos e inventario.

Las tablas principales relacionadas con este módulo son:

* productos
* categorias
* estilos
* tallas
* colores
* inventarios

Además, la base de datos general del sistema incluye otras tablas como:

* roles
* personas
* departamentos
* municipios
* direcciones
* ventas
* detalle_ventas
* pagos
* metodos_pago

PostgreSQL mantiene la integridad de la información mediante llaves primarias, llaves foráneas, restricciones y relaciones entre tablas.

También se usan funciones, procedimientos almacenados y triggers para operaciones importantes, como registrar inventario, registrar ventas, controlar stock o generar auditorías.

## Conexión entre Spring Boot y PostgreSQL

Spring Boot se conecta a PostgreSQL mediante JPA.

JPA permite mapear las tablas de la base de datos como entidades Java.
De esta forma, el backend puede consultar, registrar, actualizar o eliminar información usando repositorios.

La conexión se configura en el archivo de propiedades del backend, evitando exponer datos sensibles como contraseñas directamente en el repositorio.

## Estructura general del repositorio

El repositorio está organizado de la siguiente manera:

tienda-ropa-online/
backend/
frontend/
database/
docs/
evidencias/

La carpeta backend contiene el proyecto desarrollado en Spring Boot.

La carpeta frontend contiene el proyecto desarrollado en React.

La carpeta database contiene los scripts, recursos y documentación relacionada con PostgreSQL.

La carpeta docs contiene la documentación general del proyecto.

La carpeta docs/evidencias contiene soportes del avance del proyecto.

## Flujo básico del catálogo en el Sprint 1

Para el Sprint 1, el flujo principal es la visualización del catálogo de productos.

El proceso es el siguiente:

1. El usuario ingresa a la interfaz de la tienda desde React.
2. React solicita los productos al backend mediante el endpoint GET /api/productos.
3. Spring Boot recibe la solicitud en el controlador de productos.
4. El backend consulta la información usando servicios, repositorios y JPA.
5. PostgreSQL retorna los productos, categorías, estilos, tallas, colores e inventario.
6. Spring Boot organiza la respuesta en formato JSON.
7. React recibe la respuesta y muestra los productos en pantalla.
8. Si un producto no tiene stock disponible, se muestra como agotado.

## Endpoint inicial del Sprint 1

El endpoint principal del Sprint 1 es:

GET /api/productos

Este endpoint permite consultar el catálogo de productos desde el frontend.

La respuesta incluye información como:

* Nombre del producto.
* Precio.
* Imagen.
* Categoría.
* Estilo.
* Tallas disponibles.
* Colores disponibles.
* Estado de disponibilidad.

## Resumen de la arquitectura

La arquitectura definida permite trabajar de forma ordenada y separada.

React se encarga de la interfaz visual.

Spring Boot se encarga de la lógica del sistema y de exponer la API REST.

PostgreSQL se encarga del almacenamiento, relaciones y control de la información.

Esta separación facilita el trabajo en equipo, ya que frontend, backend y base de datos avanzan de manera organizada dentro del repositorio y del Sprint.