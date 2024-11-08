# Usa una imagen base con OpenJDK 17
FROM openjdk:17-jdk-slim

# Actualiza los paquetes e instala Maven
RUN apt-get update && apt-get install -y maven

# Define el directorio de trabajo en la imagen
WORKDIR /app

# Copia el archivo JAR desde el contexto de construcción (el nombre se pasa como argumento)
ARG JAR_FILE
COPY ${JAR_FILE} demo.jar

# Expone el puerto 8082
EXPOSE 8082

# Ejecuta la aplicación
ENTRYPOINT ["java", "-jar", "demo.jar"]
