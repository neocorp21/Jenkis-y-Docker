pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "demo:${env.BUILD_NUMBER}"
        DOCKER_CONTAINER_NAME = "demo-jenkins-app-${env.BUILD_NUMBER}"  // Nombre único para el contenedor
    }

    stages {
        stage('Clonar Código') {
            steps {
                script {
                    try {
                        git branch: 'main', url: 'https://github.com/neocorp21/pruebaxd.git'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Error al clonar el repositorio: ${e.message}"
                    }
                }
            }
        }

        stage('Actualizar Versión del Artefacto') {
            steps {
                script {
                    try {
                        sh "mvn versions:set -DnewVersion=0.0.${env.BUILD_NUMBER}-SNAPSHOT"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Error al actualizar la versión del artefacto: ${e.message}"
                    }
                }
            }
        }

        stage('Construir JAR') {
            steps {
                script {
                    try {
                        sh 'mvn clean install'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Error al construir el JAR: ${e.message}"
                    }
                }
            }
        }

        stage('Verificar Archivo JAR') {
            steps {
                script {
                    try {
                        // Verificar que el archivo JAR existe en el directorio target
                        def jarFile = sh(script: 'ls -1 target/*.jar', returnStdout: true).trim()
                        if (jarFile) {
                            echo "Archivo JAR encontrado: ${jarFile}"
                            env.JAR_FILE = jarFile // Guardar el nombre del archivo JAR para usarlo en la construcción del Dockerfile
                        } else {
                            error "No se encontró el archivo JAR en el directorio target."
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "El archivo JAR no se ha generado correctamente: ${e.message}"
                    }
                }
            }
        }

        stage('Construir Imagen Docker') {
            steps {
                script {
                    try {
                        // Asegúrate de que el Dockerfile esté en el directorio raíz del proyecto
                        echo "Construyendo la imagen Docker..."
                        // Usar el nombre del archivo JAR generado en el paso anterior
                        sh "docker build -t ${DOCKER_IMAGE} --build-arg JAR_FILE=${env.JAR_FILE} ."
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Error al construir la imagen Docker: ${e.message}"
                    }
                }
            }
        }

        stage('Verificar Contenedor Existente y Desplegar Aplicación') {
            steps {
                script {
                    try {
                        // Verificar si ya existe un contenedor con el nombre especificado
                        def existingContainer = sh(script: "docker ps -q --filter 'name=${DOCKER_CONTAINER_NAME}'", returnStdout: true).trim()

                        if (existingContainer) {
                            echo "El contenedor ${DOCKER_CONTAINER_NAME} ya existe. Deteniéndolo..."
                            // Detener el contenedor existente
                            sh "docker stop ${existingContainer}"
                            sh "docker rm ${existingContainer}"
                        } else {
                            echo "No existe un contenedor con el nombre ${DOCKER_CONTAINER_NAME}. Procediendo a crear uno nuevo."
                        }

                        // Iniciar el nuevo contenedor con el nombre único y el puerto 8082
                        echo "Iniciando el contenedor con el nuevo JAR..."
                        sh "docker run -d -p 8082:8082 --name ${DOCKER_CONTAINER_NAME} ${DOCKER_IMAGE}"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Error al verificar o desplegar el contenedor Docker: ${e.message}"
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                try {
                    // Limpieza de recursos no utilizados
                    sh 'docker system prune -af'
                } catch (Exception e) {
                    echo "Error al ejecutar docker system prune: ${e.message}"
                }
            }
        }

        success {
            echo '¡Pipeline ejecutado con éxito!'
        }

        failure {
            echo '\033[31m¡Hubo un error durante la ejecución del pipeline!\033[0m'
        }
    }
}
