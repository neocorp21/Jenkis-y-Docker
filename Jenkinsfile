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

        stage('Construir Imagen Docker') {
            steps {
                script {
                    try {
                        sh "docker build --build-arg BUILD_NUMBER=${env.BUILD_NUMBER} -t ${DOCKER_IMAGE} ."
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
                        // Verificar si el contenedor con el nombre específico está en ejecución
                        def containerExists = sh(script: "docker ps -q -f name=${DOCKER_CONTAINER_NAME}", returnStatus: true) == 0
                        if (containerExists) {
                            echo "El contenedor ${DOCKER_CONTAINER_NAME} ya está en ejecución. Deteniéndolo..."
                            sh "docker stop ${DOCKER_CONTAINER_NAME}"
                            sh "docker rm ${DOCKER_CONTAINER_NAME}"
                        }

                        // Verificar si el puerto 8082 está en uso y detener el contenedor si es necesario
                        def portInUse = sh(script: "docker ps -q -f publish=8082", returnStatus: true) == 0
                        if (portInUse) {
                            echo "El puerto 8082 está en uso. Deteniendo el contenedor en el puerto..."
                            sh 'docker ps -q -f "publish=8082" | xargs -r docker stop'
                        }

                        // Correr el nuevo contenedor con un nombre único
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
            echo '\033[31m¡Hubo un error durante la ejecución del pipeline!\033[0m'
        }
    }
}
