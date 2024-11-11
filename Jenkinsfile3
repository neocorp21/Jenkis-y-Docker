pipeline {
    agent any

    stages {
        stage('Construir JAR') {
            steps {
                script {
                    try {
                        // Ejecutar mvn clean install para limpiar y construir el JAR
                        sh 'mvn clean install'
                    } catch (Exception e) {
                        // Si hay un error, marcar el build como fallido
                        currentBuild.result = 'FAILURE'
                        error "Error al construir el JAR: ${e.message}"  // Detallar el mensaje de error
                    }
                }
            }
        }
    }
}


