pipeline {
    agent any

    environment {
        // La versión se actualizará con el número de build de Jenkins
        DOCKER_IMAGE = 'demo:${env.BUILD_NUMBER}'
    }

    stages {
        stage('Clonar Código') {
            steps {
                // Clonar el repositorio desde GitHub, especificando la rama 'main'
                git branch: 'main', url: 'https://github.com/neocorp21/pruebaxd.git'
            }
        }

        stage('Actualizar Versión del Artefacto') {
            steps {
                script {
                    // Cambiar la versión del artefacto en el pom.xml usando el número de construcción de Jenkins
                    sh "mvn versions:set -DnewVersion=0.0.${env.BUILD_NUMBER}-SNAPSHOT"
                }
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
                    // Detener y eliminar el contenedor si ya está en ejecución
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
