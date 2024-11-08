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
                    // Cambiar versión en el pom.xml (verifica que el cambio se aplique)
                    sh "mvn versions:set -DnewVersion=0.0.${env.BUILD_NUMBER}-SNAPSHOT"
                }
            }
        }

        stage('Construir JAR') {
            steps {
                script {
                    // Construir el JAR con Maven
                    sh 'mvn clean install'
                }
            }
        }

        stage('Construir Imagen Docker') {
            steps {
                script {
                    // Construir imagen Docker con el número de build como argumento
                    sh "docker build --build-arg BUILD_NUMBER=${env.BUILD_NUMBER} -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Desplegar Aplicación') {
            steps {
                script {
                    // Detener y eliminar cualquier contenedor con el nombre "demo-jenkins-app"
                    sh 'docker ps -q -f "name=demo-jenkins-app" | xargs -r docker stop | xargs -r docker rm -f'
                    // Correr el nuevo contenedor
                    sh "docker run -d -p 8082:8082 --name demo-jenkins-app ${DOCKER_IMAGE}"
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
