# nodejs-mysql
A repo for a tutorial blog post nodejs and MySQL

## The blog post

You can read the blog post here: [https://geshan.com.np/blog/2020/11/nodejs-mysql-tutorial/](https://geshan.com.np/blog/2020/11/nodejs-mysql-tutorial/)

## Running on Vercel

At: [https://nodejs-mysql.vercel.app/quotes](https://nodejs-mysql.vercel.app/quotes)

# Trabajo Práctico 02 - Docker
## Aplicación Node.js con MySQL - Entornos QA y PROD

Esta aplicación demuestra el uso de Docker para containerizar una aplicación Node.js con base de datos MySQL, configurada para ejecutarse en dos entornos diferentes (QA y PROD) usando la misma imagen.

## 🏗️ Arquitectura

- **Aplicación**: Node.js + Express
- **Base de datos**: MySQL 8.0
- **Entornos**: QA y PROD con configuraciones diferenciadas
- **Orquestación**: Docker Compose

## 📋 Requisitos

- Docker Desktop
- Docker Compose
- Git

## 🚀 Instalación y Ejecución

### 1. Clonar el repositorio
```bash
git clone [tu-repo-url]
cd nodejs-mysql-IngeSW3TP2Vol2
```

### 2. Construir y ejecutar los contenedores
```bash
docker-compose up --build -d
```

### 3. Verificar el estado de los servicios
```bash
docker-compose ps
```

## 🔍 Acceder a las aplicaciones

### Entorno QA
- **URL**: http://localhost:3001
- **Características**:
  - NODE_ENV=development
  - 5 citas de prueba en la base de datos
  - Debug habilitado
  - 5 elementos por página

### Entorno PROD  
- **URL**: http://localhost:3000
- **Características**:
  - NODE_ENV=production
  - 15 citas completas en la base de datos
  - Debug deshabilitado
  - 10 elementos por página

## 🗄️ Base de datos

### Conectarse a MySQL
```bash
# Como root
docker exec -it mysql_container mysql -uroot -pjamones_root_789

# Usuario QA
docker exec -it mysql_container mysql -uqa_user -pqa_password_123 quotes_qa

# Usuario PROD
docker exec -it mysql_container mysql -uprod_user -pprod_password_456 quotes_prod
```

### Verificar datos
```bash
# Contar citas en QA (debería mostrar 5)
docker exec -it mysql_container mysql -uqa_user -pqa_password_123 quotes_qa -e "SELECT COUNT(*) FROM quote;"

# Contar citas en PROD (debería mostrar 15)
docker exec -it mysql_container mysql -uprod_user -pprod_password_456 quotes_prod -e "SELECT COUNT(*) FROM quote;"
```

## 🐳 Imágenes en Docker Hub

Las imágenes están disponibles públicamente en Docker Hub:

- **QA**: `roykostrun/nodejs-quotes-app:qa-v1.0`
- **PROD**: `roykostrun/nodejs-quotes-app:prod-v1.0`
- **Latest**: `roykostrun/nodejs-quotes-app:latest`


## 📊 Monitoreo y Logs

### Ver logs de todos los servicios
```bash
docker-compose logs -f
```

### Ver logs de un servicio específico
```bash
docker-compose logs -f app-qa
docker-compose logs -f app-prod  
docker-compose logs -f db
```

### Health checks
Todos los contenedores incluyen health checks que se pueden verificar con:
```bash
docker-compose ps
```

## 🔧 Comandos útiles

### Reiniciar servicios
```bash
docker-compose restart
```

### Parar y eliminar todo
```bash
docker-compose down -v
```

### Reconstruir imágenes
```bash
docker-compose up --build
```

### Entrar a un contenedor
```bash
docker exec -it nodejs-mysql-qa sh
docker exec -it nodejs-mysql-prod sh
docker exec -it mysql_container bash
```

## 📈 Persistencia de datos

Los datos de MySQL se persisten usando un volumen nombrado:
- **Volumen**: `mysql_quotes_data`
- **Ubicación**: `/var/lib/mysql`

Para verificar que los datos persisten:
1. Agregar datos a la base
2. Reiniciar contenedores: `docker-compose restart`
3. Verificar que los datos siguen ahí

## ⚙️ Variables de entorno

| Variable | QA | PROD | Descripción |
|----------|----|----|-------------|
| NODE_ENV | development | production | Entorno de Node.js |
| DB_HOST | db | db | Host de base de datos |
| DB_USER | qa_user | prod_user | Usuario de MySQL |
| DB_PASSWORD | qa_password_123 | prod_password_456 | Contraseña de MySQL |
| DB_NAME | quotes_qa | quotes_prod | Nombre de base de datos |
| DB_CONN_LIMIT | 5 | 10 | Límite de conexiones |
| DB_DEBUG | true | false | Debug de consultas SQL |
| LIST_PER_PAGE | 5 | 10 | Items por página |

## 🛠️ Solución de problemas

### Contenedor MySQL unhealthy
```bash
docker-compose logs db
# Verificar que el init.sql no tenga errores de sintaxis
```

### Puerto ocupado
```bash
# Cambiar puertos en docker-compose.yml si 3000 o 3001 están ocupados
netstat -an | findstr 3000
```

### Limpiar todo y empezar de nuevo
```bash
docker-compose down -v
docker system prune -f
docker-compose up --build -d
```

## 👨‍💻 Autor

Desarrollado para el Trabajo Práctico 02 de Introducción a Docker.

