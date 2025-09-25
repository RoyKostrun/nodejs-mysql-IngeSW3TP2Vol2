# Decisiones Técnicas - TP Docker

## 1. Elección de la aplicación y tecnología

### Aplicación seleccionada
**Node.js Quotes API con MySQL**

### Justificación
- **Fork de proyecto existente**: Partí de una aplicación funcional que maneja citas de programación, lo que me permitió enfocarme en la containerización en lugar de desarrollar desde cero.
- **Stack conocido**: Node.js + Express + MySQL es un stack ampliamente usado en la industria.
- **API REST simple**: La aplicación expone endpoints claros que facilitan las pruebas de funcionamiento.
- **Configuración via variables de entorno**: Ya estaba preparada para usar variables de entorno, ideal para Docker.

### Estructura del proyecto original
```
- app.js (servidor Express)
- config.js (configuración de BD via variables de entorno)
- services/db.js (conexión MySQL)  
- routes/ (endpoints de la API)
- db/init.sql (inicialización de datos)
```

## 2. Elección de imagen base

### Imagen seleccionada
**node:18-alpine**

### Justificación
- **Tamaño reducido**: Alpine Linux es una distribución minimalista (≈5MB base)
- **Seguridad**: Menos superficie de ataque, actualizaciones de seguridad más frecuentes
- **Performance**: Menor tiempo de pull y deploy
- **Node.js LTS**: Versión 18 es la versión LTS actual, estable para producción
- **Compatibilidad**: Alpine incluye las dependencias necesarias para Node.js y npm

### Comparación con alternativas
| Imagen | Tamaño | Pros | Contras |
|--------|--------|------|---------|
| node:18-alpine | ~170MB | Liviana, segura | Menos herramientas debug |
| node:18 | ~900MB | Más herramientas | Muy pesada |
| node:18-slim | ~250MB | Intermedia | Compromise |

## 3. Elección de base de datos

### Base de datos seleccionada
**MySQL 8.0**

### Justificación
- **Compatibilidad**: La aplicación ya estaba configurada para MySQL
- **Madurez**: MySQL 8.0 es estable y ampliamente usado en producción
- **Características**: Soporte completo para transacciones ACID
- **Herramientas**: Excelente ecosistema de herramientas de administración
- **Performance**: Optimizado para workloads web típicos

### Configuración específica
```yaml
mysql:8.0
--default-authentication-plugin=mysql_native_password
```
- **Autenticación nativa**: Para compatibilidad con drivers de Node.js más antiguos
- **Versión específica**: MySQL 8.0 para consistencia entre entornos

## 4. Estructura y justificación del Dockerfile

### Dockerfile multi-stage optimizado

```dockerfile
FROM node:18-alpine

# Instalar dumb-init para manejo correcto de señales
RUN apk add --no-cache dumb-init

# Usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

WORKDIR /usr/src/app

# Optimización de cache: copiar package files primero
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copiar código fuente
COPY . .
RUN chown -R nodejs:nodejs /usr/src/app

USER nodejs

# Health check personalizado
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

# dumb-init como PID 1 para manejo correcto de señales
ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "start"]
```

### Decisiones clave del Dockerfile

1. **dumb-init**: Manejo correcto de señales y procesos zombie
2. **Usuario no-root**: Principio de menor privilegio para seguridad
3. **Cache de layers**: `COPY package*.json` antes que el resto del código
4. **npm ci**: Más rápido y determinístico que `npm install`
5. **Health check**: Monitoreo proactivo del estado de la aplicación
6. **ENTRYPOINT + CMD**: Flexibilidad para override de comandos

## 5. Configuración de QA y PROD (variables de entorno)

### Estrategia de diferenciación

He usado **variables de entorno** para que la **misma imagen** se comporte diferente según el entorno:

### Variables por entorno

| Variable | QA | PROD | Propósito |
|----------|----|----|-----------|
| `NODE_ENV` | development | production | Comportamiento de Express |
| `DB_USER` | qa_user | prod_user | Aislamiento de usuarios |
| `DB_PASSWORD` | qa_password_123 | prod_password_456 | Contraseñas diferentes |
| `DB_NAME` | quotes_qa | quotes_prod | Bases de datos separadas |
| `DB_DEBUG` | true | false | Logs de SQL en desarrollo |
| `LIST_PER_PAGE` | 5 | 10 | Paginación diferente |
| `DB_CONN_LIMIT` | 5 | 10 | Pool de conexiones |

### Justificación del enfoque

1. **Una sola imagen**: Cumple el requisito de usar la misma imagen para ambos entornos
2. **Configuración externa**: Separación clara entre código y configuración
3. **Seguridad**: Credenciales diferentes por entorno
4. **Aislamiento**: Bases de datos completamente separadas
5. **Testing**: Configuración de debug solo en QA

## 6. Estrategia de persistencia de datos (volúmenes)

### Tipo de volumen seleccionado
**Named Volume** (`mysql_quotes_data`)

### Justificación
- **Gestión automática**: Docker maneja la ubicación y backup
- **Portabilidad**: Funciona igual en Windows, Mac y Linux
- **Performance**: Optimizado por Docker para el sistema operativo
- **Aislamiento**: No interfiere con archivos del host

### Configuración
```yaml
volumes:
  db_data:/var/lib/mysql  # Directorio estándar de MySQL
```

### Alternativas consideradas
| Tipo | Pros | Contras | Decisión |
|------|------|---------|-----------|
| Named Volume | Portable, gestionado | Menos control directo | ✅ Elegido |
| Bind Mount | Control total | Dependiente del SO | ❌ Descartado |
| tmpfs | Muy rápido | No persistente | ❌ No aplica |

## 7. Estrategia de versionado y publicación

### Convención de tags adoptada

```
roykostrun/nodejs-quotes-app:qa-v1.0    # Versión específica QA
roykostrun/nodejs-quotes-app:prod-v1.0  # Versión específica PROD  
roykostrun/nodejs-quotes-app:latest     # Última versión estable
```

### Justificación del versionado

1. **Semantic Versioning**: v1.0 indica primera versión estable
2. **Separación por entorno**: Tags diferentes para QA y PROD aunque sean la misma imagen
3. **Latest tag**: Para facilitar deploys rápidos en desarrollo
4. **Prefijo del usuario**: Namespace claro en Docker Hub

### Estrategia de release

- **v1.0**: Primera versión funcional con todos los requisitos
- **qa-v1.0**: Específico para testing y desarrollo
- **prod-v1.0**: Etiqueta para producción
- **latest**: Apunta a la versión más reciente estable

### Proceso de publicación

```bash
1. Build local → docker-compose up --build
2. Test completo → verificar QA y PROD funcionando
3. Tag → crear tags semánticos
4. Push → subir a Docker Hub
5. Deploy → usar imágenes remotas
```

## 8. Configuración de red y comunicación

### Red personalizada
**Bridge network** (`quotes-network`)

### Justificación
- **Aislamiento**: Los contenedores solo pueden comunicarse entre ellos
- **DNS interno**: Resolución automática de nombres de servicio
- **Seguridad**: Sin acceso directo desde el host excepto puertos expuestos

### Comunicación inter-contenedores
```
app-qa/app-prod → db (por nombre de servicio)
DB_HOST=db (se resuelve automáticamente a la IP del contenedor MySQL)
```

## 9. Health checks y monitoreo

### Health check personalizado
Creé un `healthcheck.js` específico que:
- Hace petición HTTP a localhost:3000
- Timeout de 2 segundos
- Exit code 0 si ok, 1 si falla

### Configuración en docker-compose
```yaml
healthcheck:
  test: ["CMD", "node", "healthcheck.js"]  
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Justificación
- **Proactivo**: Detecta problemas antes que los usuarios
- **Específico**: Verifica que la aplicación realmente responda
- **No invasivo**: No interfiere con el funcionamiento normal
- **Configurable**: Parámetros ajustables según necesidades

## 10. Decisiones de seguridad

### Medidas implementadas

1. **Usuario no-root**: Contenedores corren con usuario `nodejs` (UID 1001)
2. **Contraseñas únicas**: Diferentes por entorno
3. **Usuarios de BD específicos**: qa_user y prod_user con permisos limitados
4. **Red aislada**: Comunicación solo entre contenedores autorizados
5. **Imagen Alpine**: Menor superficie de ataque

### Configuración de MySQL
- Root password complejo
- Usuarios específicos por aplicación  
- Bases de datos separadas
- Sin acceso root para las aplicaciones