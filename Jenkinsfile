pipeline {
    pipeline {
    agent { label 'cpp-agent' }

    // =============================
    // Parâmetros configuráveis
    // =============================
    parameters {
        string(name: 'PROJECT_NAME', defaultValue: 'cpp-template', description: 'Nome do projeto/executável')
        string(name: 'GITHUB_REPO', defaultValue: '', description: 'URL do repositório GitHub')
        string(name: 'GITHUB_BRANCH', defaultValue: 'main', description: 'Branch a ser usada')
        string(name: 'DOCKER_REGISTRY', defaultValue: '127.0.0.1:5001', description: 'Endereço do Docker/Nexus Registry')
        string(name: 'BUILD_TYPE', defaultValue: 'Release', description: 'Tipo de build (Release/Debug)')
    }

    environment {
        NEXUS_CREDENTIALS = credentials('nexus-cred')
        IMAGE_TAG  = "${env.BUILD_NUMBER}-${env.GIT_COMMIT?.take(7)}"
        BUILD_DIR  = "build/${params.BUILD_TYPE}"
        CONAN_USER_HOME = "${WORKSPACE}/.conan"
    }

    stages {

        stage('Checkout') {
    steps {
        checkout scm
    }
}

        stage('Conan Install') {
            steps {
                echo "Instalando dependências com Conan..."
                sh "conan install . --output-folder=${BUILD_DIR} --build=missing"
            }
        }

        stage('CMake Build') {
            steps {
                echo "Buildando projeto com CMake..."
                sh "cmake -S . -B ${BUILD_DIR} -DPROJECT_NAME=${params.PROJECT_NAME}"
                sh "cmake --build ${BUILD_DIR}"
            }
        }

        stage('Run Tests') {
            steps {
                echo "Executando testes..."
                sh "cd ${BUILD_DIR} && ctest --output-on-failure"
            }
        }

        stage('Lint (Static Analysis)') {
            steps {
                echo "Executando análise estática..."
                sh "cppcheck . || true"
            }
        }

        stage('Package Artifact') {
            steps {
                echo "Empacotando artefato..."
                sh "tar -czf ${params.PROJECT_NAME}.tar.gz ${BUILD_DIR}"
            }
        }

        stage('Publish Artifact to Nexus') {
            steps {
                echo "Enviando artefato para Nexus..."
                sh """
                curl -u ${NEXUS_CREDENTIALS_USR}:${NEXUS_CREDENTIALS_PSW} \
                --upload-file ${params.PROJECT_NAME}.tar.gz \
                http://localhost:8081/repository/cpp-releases/${params.PROJECT_NAME}-${IMAGE_TAG}.tar.gz
                """
            }
        }

        stage('Docker Login') {
            steps {
                echo "Logando no registry Docker..."
                sh "echo ${NEXUS_CREDENTIALS_PSW} | docker login ${params.DOCKER_REGISTRY} -u ${NEXUS_CREDENTIALS_USR} --password-stdin"
            }
        }

        stage('Docker Build & Push') {
            steps {
                echo "Construindo e enviando imagem Docker..."
                sh "docker build --build-arg BUILD_DIR=${BUILD_DIR} -t ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${IMAGE_TAG} ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:latest"
                sh "docker push ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${IMAGE_TAG}"
                sh "docker push ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:latest"
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                echo "Atualizando deployment Kubernetes com a nova imagem..."
                sh """
                kubectl set image deployment/${params.PROJECT_NAME} \
                ${params.PROJECT_NAME}=${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${IMAGE_TAG} --record

                kubectl rollout status deployment/${params.PROJECT_NAME}
                """
            }
        }
    }

    post {
        success {
            echo "Pipeline concluída! 🚀"
            echo "Imagem: ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline falhou! ❌"
            echo "Verifique logs, Docker login, Nexus e Kubernetes."
        }
    }
} 

}