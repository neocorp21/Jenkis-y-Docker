# Usar imagen base de OpenJDK
FROM openjdk:17-jdk-slim

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Argumento para el número de build de Jenkins
ARG BUILD_NUMBER

# Copiar el archivo JAR generado desde el directorio target al contenedor
# Usar el número de build para generar el nombre del archivo JAR
COPY target/demo-${BUILD_NUMBER}.jar demo.jar
# Usar un patrón general para asegurar la copia del archivo JAR
COPY target/*.jar demo.jar

# Exponer el puerto en el que se ejecutará la aplicación (usualmente 8080 en Spring Boot)
EXPOSE 8082

# Comando para ejecutar el archivo JAR cuando el contenedor se inicie
ENTRYPOINT ["java", "-jar", "demo.jar"]

