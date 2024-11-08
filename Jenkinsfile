pipeline {
    agent any

    environment {
        // Usar el BUILD_NUMBER de Jenkins para tener una etiqueta única en cada ejecución del pipeline
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
                    // Usar el BUILD_NUMBER en la etiqueta para asegurar una imagen única
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Desplegar Aplicación') {
            steps {
                script {
                    // Detener el contenedor si ya está en ejecución
                    sh """
                        if [ \$(docker ps -q -f name=${CONTAINER_NAME}) ]; then
                            echo "Deteniendo contenedor existente..."
                            docker stop ${CONTAINER_NAME}
                        fi
                    """

                    // Remover el contenedor antiguo si existe (usando `docker rm` solo si es necesario)
                    sh """
                        if [ \$(docker ps -a -q -f name=${CONTAINER_NAME}) ]; then
                            echo "Eliminando contenedor existente..."
                            docker rm ${CONTAINER_NAME}
                        fi
                    """

                    // Iniciar el nuevo contenedor con la imagen actualizada
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
