pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "demo:${env.BUILD_NUMBER}"
    }

    stages {
        stage('Clonar Código') {
            steps {
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
                    sh 'mvn clean install'
                }
            }
        }

        stage('Construir Imagen Docker') {
            steps {
                script {
                    // Construir la imagen Docker, pasando el número de build como argumento al Dockerfile
                    sh "docker build --build-arg BUILD_NUMBER=${env.BUILD_NUMBER} -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Desplegar Aplicación') {
            steps {
                script {
                    sh 'docker ps -q -f "name=demo-jenkins-app" | xargs -r docker stop | xargs -r docker rm -f'
                    sh "docker run -d -p 8082:8082 --name demo ${DOCKER_IMAGE}"
                }
            }
        }
    }

    post {
        always {
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
