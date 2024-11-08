pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'demo:0.0.1-SNAPSHOT'
    }

    stages {
        stage('Clonar Código') {
            steps {
             // Clonar el repositorio desde GitHub, especificando la rama 'main'
             git branch: 'main', url: 'https://github.com/neocorp21/pruebaxd.git'

            }
        }

        stage('Construir JAR') {
            steps {
                script {
                    // Ejecutar Maven para construir el JAR
                    sh 'mvn clean install'
                }
            }
        }

        stage('Construir Imagen Docker') {
            steps {
                script {
                    // Construir la imagen Docker usando el Dockerfile
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Desplegar Aplicación') {
            steps {
                script {
                    // Verificar si ya existe un contenedor en ejecución con el mismo nombre
                      // Detener y eliminar el contenedor si ya está en ejecución (forzando la eliminación si es necesario)
                                sh 'docker ps -q -f "name=demo-jenkins-app" | xargs -r docker stop | xargs -r docker rm -f'

                                // Ejecutar el contenedor de la nueva imagen
                                sh 'docker run -d -p 8082:8082 --name demo ${DOCKER_IMAGE}'


                }
            }
        }
    }

    post {
        always {
            // Limpiar imágenes Docker antiguas si es necesario
            sh 'docker system prune -af'
        }

        success {
            echo '¡Pipeline ejecutado con éxito!'
        }

        failure {
            echo '¡Hubo un error durante la ejecución del pipeline!'
        }
    }
}
