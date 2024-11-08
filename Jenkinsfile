pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "demo:0.0.1-${BUILD_NUMBER}"
        CONTAINER_NAME = 'demo-jenkins-app'
    }

    stages {
        stage('Clonar Código') {
            steps {
                git branch: 'main', url: 'https://github.com/neocorp21/pruebaxd.git'
            }
        }

        stage('Construir JAR') {
            steps {
                script {
                    sh 'mvn clean install'
                }
            }
        }

        stage('Construir Imagen Docker') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Desplegar Aplicación') {
            steps {
                script {
                    // Detener y eliminar contenedor si ya existe
                    sh """
                        if [ \$(docker ps -q -f name=${CONTAINER_NAME}) ]; then
                            echo "Deteniendo contenedor existente..."
                            docker stop ${CONTAINER_NAME}
                            docker rm ${CONTAINER_NAME}
                        fi
                    """

                    // Verificar si el puerto 8082 está siendo usado
                    sh """
                        if lsof -i :8082; then
                            echo "Puerto 8082 está en uso, liberando el puerto..."
                            # Liberar el puerto si está en uso, detener el contenedor si es necesario
                            docker ps -q -f "ancestor=${DOCKER_IMAGE}" | xargs -r docker stop
                            docker ps -a -q -f "ancestor=${DOCKER_IMAGE}" | xargs -r docker rm -f
                        fi
                    """

                    // Iniciar el contenedor con el puerto 8082
                    sh "docker run -d -p 8082:8082 --name ${CONTAINER_NAME} ${DOCKER_IMAGE}"
                }
            }
        }
    }

    post {
        success {
            echo '¡Pipeline ejecutado con éxito!'
        }

        failure {
            echo '¡Hubo un error durante la ejecución del pipeline!'
        }
    }
}
