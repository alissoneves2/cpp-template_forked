pipeline {
    agent { label 'cpp-agent' }

    parameters {
        string(name: 'DOCKER_REGISTRY', defaultValue: 'host.docker.internal:5001', description: 'Registry do Nexus')
        string(name: 'BUILD_TYPE', defaultValue: 'Release', description: 'Release/Debug')
    }

    environment {
        PATH = "/home/alissoneves/.local/bin:/usr/local/bin:/usr/bin:/bin:${env.PATH}"
        REAL_PROJECT_NAME = "${env.JOB_NAME.split('/')[0]}"
        BUILD_DIR = "build/Release"
        NEXUS_CRED = credentials('nexus-credentials')
        IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT?.take(7)}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Conan & CMake Build') {
            steps {
                sh "conan install . --output-folder=${env.BUILD_DIR} --build=missing"
                sh """
                    cmake -S . -B ${env.BUILD_DIR} \
                    -DCMAKE_TOOLCHAIN_FILE=${env.BUILD_DIR}/${env.BUILD_DIR}/generators/conan_toolchain.cmake \
                    -DCMAKE_PREFIX_PATH=${env.BUILD_DIR}/${env.BUILD_DIR}/generators \
                    -DCMAKE_BUILD_TYPE=${params.BUILD_TYPE} \
                    -DPROJECT_NAME=${env.REAL_PROJECT_NAME}
                """ 
                sh "cmake --build ${env.BUILD_DIR}"
            }
        }

        stage('Run Tests') {
            steps {
                sh "cd ${env.BUILD_DIR} && ctest --output-on-failure"
            }
        }

        stage('Docker Login') {
            steps {
                echo 'Logando no Nexus...'
                sh "echo ${NEXUS_CRED_PSW} | docker login ${params.DOCKER_REGISTRY} -u ${NEXUS_CRED_USR} --password-stdin"
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    def fullImageName = "${params.DOCKER_REGISTRY}/${env.REAL_PROJECT_NAME}:${env.IMAGE_TAG}"
                    sh "docker build --build-arg PROJECT_NAME=${env.REAL_PROJECT_NAME} -t ${fullImageName} ."
                    sh "docker push ${fullImageName}"
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                echo "Fazendo deploy do projeto: ${env.REAL_PROJECT_NAME}"
                sh """
                    kubectl apply -f deployment.yaml
                    kubectl set image deployment/${env.REAL_PROJECT_NAME} \
                    ${env.REAL_PROJECT_NAME}=${params.DOCKER_REGISTRY}/${env.REAL_PROJECT_NAME}:${env.IMAGE_TAG}
                    kubectl rollout status deployment/${env.REAL_PROJECT_NAME} --timeout=30s || echo "Rollout finalizado"
                """
            }
        }
    }

    post {
        success {
            echo "Pipeline concluída com sucesso! 🚀 Projeto: ${env.REAL_PROJECT_NAME}"
        }
        failure {
            echo "Pipeline falhou no projeto ${env.REAL_PROJECT_NAME}. Verifique os logs. ❌"
        }
    }
}