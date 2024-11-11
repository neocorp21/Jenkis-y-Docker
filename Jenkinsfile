pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "demo:${env.BUILD_NUMBER}"
        DOCKER_CONTAINER_NAME = "demo-jenkins-app-${env.BUILD_NUMBER}"
        PORT = 8082
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

        stage('Ejecutar Pruebas') {
            steps {
                script {
                    try {
                        sh 'mvn test'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Error en la ejecución de pruebas: ${e.message}"
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
                        def jarFile = sh(script: 'ls -1 target/*.jar', returnStdout: true).trim()
                        if (jarFile) {
                            echo "Archivo JAR encontrado: ${jarFile}"
                            env.JAR_FILE = jarFile
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
                        echo "Construyendo la imagen Docker..."
                        sh "docker build -t ${DOCKER_IMAGE} --build-arg JAR_FILE=${env.JAR_FILE} ."
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Error al construir la imagen Docker: ${e.message}"
                    }
                }
            }
        }

        stage('Verificar y Desplegar Aplicación') {
            steps {
                script {
                    try {
                        // Verificar si ya existe un contenedor con el nombre especificado
                        def existingContainer = sh(script: "docker ps -a -q --filter 'name=${DOCKER_CONTAINER_NAME}'", returnStdout: true).trim()
                        if (existingContainer) {
                            echo "El contenedor ${DOCKER_CONTAINER_NAME} ya existe. Deteniéndolo y eliminándolo..."
                            sh "docker stop ${existingContainer} || true"
                            sh "docker rm ${existingContainer} || true"
                        } else {
                            echo "No existe un contenedor con el nombre ${DOCKER_CONTAINER_NAME}. Procediendo a crear uno nuevo."
                        }

                        // Verificar si el puerto está en uso y detener el contenedor que lo está usando
                        def portInUse = sh(script: "docker ps --filter 'publish=${PORT}' -q", returnStdout: true).trim()
                        if (portInUse) {
                            echo "El puerto ${PORT} está en uso. Deteniendo el contenedor que lo está usando..."
                            sh "docker stop ${portInUse}"
                            sh "docker rm ${portInUse}"
                            sleep 2 // Retardo para liberar el puerto antes de lanzar el nuevo contenedor
                        }

                        echo "Iniciando el contenedor con la nueva imagen..."
                        sh "docker run -d -p ${PORT}:${PORT} --name ${DOCKER_CONTAINER_NAME} ${DOCKER_IMAGE}"
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
                    echo "Limpieza de recursos no utilizados..."
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
