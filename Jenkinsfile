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

        stage('Desplegar Aplicación') {
            steps {
                script {
                    try {
                        // Verificar si el puerto 8082 está siendo utilizado por algún contenedor
                        def containerUsingPort = sh(script: "docker ps --filter 'publish=8082' -q", returnStdout: true).trim()

                        if (containerUsingPort) {
                            echo "El puerto 8082 está siendo utilizado por el contenedor: ${containerUsingPort}. Deteniéndolo..."
                            // Detener y eliminar el contenedor que usa el puerto 8082
                            sh "docker stop ${containerUsingPort}"
                            sh "docker rm ${containerUsingPort}"
                        } else {
                            echo "El puerto 8082 no está siendo utilizado por ningún contenedor."
                        }

                        // Iniciar el nuevo contenedor con el nombre único y el puerto 8082
                        echo "Iniciando el contenedor con el nuevo JAR..."
                        sh "docker run -d -p 8082:8082 --name ${DOCKER_CONTAINER_NAME} ${DOCKER_IMAGE}"

                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Error al desplegar la aplicación Docker: ${e.message}"
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
            echo '\033[31m¡Hubo un error durant e la ejecución del pipeline!\033[0m'
        }
    }
}
