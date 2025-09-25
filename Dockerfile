#FROM node:alpine

#WORKDIR /usr/src/app

#COPY package*.json ./ 

#RUN npm install

#COPY . . 

#EXPOSE 3000

#CMD ["npm", "start"]
# Utilizamos Node.js Alpine para una imagen más liviana
FROM node:18-alpine

# Información del mantenedor
LABEL maintainer="tu-usuario@email.com"
LABEL description="Aplicación Node.js con MySQL para TP Docker"

# Instalar dumb-init para manejo adecuado de señales
RUN apk add --no-cache dumb-init

# Crear usuario no-root para mayor seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Establecer directorio de trabajo
WORKDIR /usr/src/app

# Copiar archivos de dependencias primero (para optimizar cache de Docker)
COPY package*.json ./

# Instalar dependencias como root, luego cambiar ownership
RUN npm ci --only=production && npm cache clean --force

# Copiar el resto del código de la aplicación y el healthcheck
COPY . .
COPY healthcheck.js ./

# Cambiar propietario de todos los archivos a nodejs user
RUN chown -R nodejs:nodejs /usr/src/app

# Cambiar a usuario nodejs
USER nodejs

# Exponer el puerto
EXPOSE 3000

# Variables de entorno por defecto
ENV NODE_ENV=production
ENV PORT=3000

# Health check para verificar que la aplicación esté corriendo
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

# Usar dumb-init como PID 1
ENTRYPOINT ["dumb-init", "--"]

# Comando por defecto
CMD ["npm", "start"]