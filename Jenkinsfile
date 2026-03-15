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
        // Usar credenciais do Jenkins (mais seguro que hardcode)
        NEXUS_CREDENTIALS = credentials('nexus-cred') // Criar credencial no Jenkins com user/pass
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
        BUILD_DIR  = "build/${params.BUILD_TYPE}"
    }

    stages {
        stage('Clone') {
            steps {
                echo "Clonando repositório ${params.GITHUB_REPO} (branch ${params.GITHUB_BRANCH})"
                git branch: "${params.GITHUB_BRANCH}", url: "${params.GITHUB_REPO}"
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

        stage('Docker Login') {
            steps {
                echo "Logando no registry Docker..."
                sh "echo ${NEXUS_CREDENTIALS_PSW} | docker login ${params.DOCKER_REGISTRY} -u ${NEXUS_CREDENTIALS_USR} --password-stdin"
            }
        }

        stage('Docker Build & Push') {
            steps {
                echo "Construindo e enviando imagem Docker..."
                sh "docker build -t ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${IMAGE_TAG} ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:latest"
                sh "docker push ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${IMAGE_TAG}"
                sh "docker push ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:latest"
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                echo "Atualizando deployment Kubernetes com a nova imagem..."
                sh "kubectl set image deployment/${params.PROJECT_NAME} ${params.PROJECT_NAME}=${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${IMAGE_TAG}"
            }
        }
    }

    post {
        success {
            echo "Pipeline concluída! Imagem ${params.PROJECT_NAME}:${IMAGE_TAG} disponível no registry e deploy aplicado."
        }
        failure {
            echo "Pipeline falhou! Verifique logs, Docker login e Nexus/Kubernetes online."
        }
    }
}