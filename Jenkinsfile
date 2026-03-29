pipeline {
    agent { label 'cpp-agent' }

    environment {
        // Captura o nome da pasta atual (ex: cpp-exer1)
        PROJECT_NAME = "${sh(script: 'basename $(pwd)', returnStdout: true).trim()}"
        // Define a Tag da imagem com o número do build e os 7 primeiros caracteres do commit
        IMAGE_TAG    = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
        // Endereço do seu Registry Nexus
        REGISTRY     = "host.docker.internal:5001"
    }

    stages {
        stage('Conan & CMake Build') {
            steps {
                echo "🔨 Iniciando Build para o projeto: ${PROJECT_NAME}"
                // O Conan instala as dependências
                sh "conan install . --output-folder=build/Release --build=missing"
                
                // O CMake configura o projeto usando o Toolchain do Conan
                sh """
                    cmake -S . -B build/Release \
                    -DCMAKE_TOOLCHAIN_FILE=build/Release/build/Release/generators/conan_toolchain.cmake \
                    -DCMAKE_BUILD_TYPE=Release
                """
                
                // Compila o binário (que terá o nome de ${PROJECT_NAME} graças ao ajuste no CMakeLists.txt)
                sh "cmake --build build/Release"
            }
        }

        stage('Run Tests') {
            steps {
                echo "🧪 Executando Testes Unitários..."
                sh "cd build/Release && ctest --output-on-failure"
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    echo "📦 Criando imagem Docker: ${REGISTRY}/${PROJECT_NAME}:${IMAGE_TAG}"
                    
                    // Passamos o PROJECT_NAME como build-arg para o Dockerfile saber qual arquivo copiar
                    sh """
                        docker build \
                        --build-arg PROJECT_NAME=${PROJECT_NAME} \
                        -t ${REGISTRY}/${PROJECT_NAME}:${IMAGE_TAG} .
                    """
                    
                    sh "docker push ${REGISTRY}/${PROJECT_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                echo "🚀 Fazendo Deploy no Kubernetes: ${PROJECT_NAME}"
                
                // O sed substitui os placeholders no seu deployment.yaml dinamicamente
                sh """
                    sed -i 's/{{APP_NAME}}/${PROJECT_NAME}/g' deployment.yaml
                    sed -i 's/{{IMAGE_TAG}}/${IMAGE_TAG}/g' deployment.yaml
                    kubectl apply -f deployment.yaml
                    kubectl rollout status deployment/${PROJECT_NAME} --timeout=60s
                """
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline concluída com sucesso! Projeto ${PROJECT_NAME} disponível."
        }
        failure {
            echo "❌ Ocorreu um erro na pipeline do projeto ${PROJECT_NAME}."
        }
    }
}