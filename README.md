# 🚀 C++ Dynamic CI/CD Pipeline Template

Este repositório é um **template de referência** para automação completa de projetos C++. Ele foi projetado para ser 100% dinâmico: ao clonar este template para um novo repositório, o pipeline detecta automaticamente o nome da pasta e configura o Build, a Imagem Docker e o Deploy no Kubernetes sem necessidade de alterações manuais nos scripts.



## 🛠️ Tecnologias Utilizadas

* **Linguagem:** C++17
* **Gestão de Dependências:** [Conan](https://conan.io/)
* **Sistema de Build:** [CMake](https://cmake.org/)
* **Orquestração CI/CD:** [Jenkins](https://www.jenkins.io/) (Declarative Pipeline)
* **Containerização:** [Docker](https://www.docker.com/)
* **Orquestração de Containers:** [Kubernetes](https://kubernetes.io/)
* **Repositório de Artefatos:** [Nexus](https://www.sonatype.com/products/sonatype-nexus-repository) (Docker Registry)

## ✨ Diferenciais deste Template

1.  **Nomeação Dinâmica:** O `Jenkinsfile` e o `CMakeLists.txt` trabalham em conjunto para extrair o nome do projeto do diretório de trabalho, limpando sufixos de branch (ex: `_master`) e convertendo caracteres para o padrão RFC 1123 exigido pelo Kubernetes.
2.  **Build Otimizado:** Uso de `.dockerignore` estratégico para garantir que apenas o binário de Release seja enviado para a imagem final, reduzindo drasticamente o tempo de build e o tamanho da imagem.
3.  **Gestão de Dependências Moderna:** Integração total entre Conan e CMake via `CMakeToolchain`, garantindo que bibliotecas como `fmt` e `spdlog` sejam vinculadas corretamente.
4.  **Deploy Automatizado:** Atualização dinâmica de imagens no Kubernetes através de substituição de tags via `sed` em tempo de execução.

## 🚀 Como Utilizar

### 1. Preparação do Repositório
Clique em **"Use this template"** no GitHub para criar seu novo projeto baseado nesta estrutura.

### 2. Configuração no Jenkins
Crie um novo job do tipo **Pipeline** (ou Multibranch Pipeline) apontando para o seu novo repositório. Certifique-se de que seu Agent Jenkins possui:
* GCC/G++ (suporte a C++17)
* Conan instalado e configurado
* Docker e Kubectl configurados

### 3. Variáveis de Ambiente
No `Jenkinsfile`, ajuste as variáveis no bloco `environment` se o seu ambiente for diferente:
* `REGISTRY`: Endereço do seu Docker Registry.
* `PATH`: Caminho para os binários do Conan/CMake no seu Agent.

## 🏗️ Estrutura do Projeto

```text
.
├── src/                # Código fonte (.cpp)
├── tests/              # Testes unitários (GTest)
├── cmake/              # Módulos auxiliares do CMake
├── CMakeLists.txt      # Configuração de Build dinâmica
├── conanfile.txt       # Dependências do projeto
├── Dockerfile          # Receita da imagem Docker
├── Jenkinsfile         # Definição do Pipeline CI/CD
└── deployment.yaml     # Manifesto Kubernetes (Template)

```


## 📈 Fluxo de Trabalho
O pipeline executa automaticamente as seguintes etapas a cada git push:

Checkout: Download do código.

Conan Install: Resolução de dependências.

CMake Build: Compilação do binário e dos testes.

Unit Tests: Execução do CTest.

Docker Build: Criação da imagem com o nome dinâmico do projeto.





## 📈 O que você precisa customizar?
Para que este template funcione no seu ambiente específico, você deve ajustar os seguintes pontos:

No Jenkinsfile (Variáveis de Ambiente)
Localize o bloco environment e altere os valores de acordo com o seu servidor:

PATH: Certifique-se de que o caminho aponta para onde o conan e o cmake estão instalados no seu Agent Jenkins.

REGISTRY: Altere host.docker.internal:5001 para o endereço do seu Nexus, Docker Hub ou Harbor.

agent { label 'seu-node' }: Altere 'cpp-agent' para a etiqueta (label) que você configurou no seu nó do Jenkins.

No deployment.yaml (Recursos de Rede)
containerPort: Se o seu projeto C++ rodar em uma porta diferente da 8080, ajuste este valor.

Service (Opcional): Se você quiser acessar o app de fora do cluster, lembre-se de adicionar um manifesto de Service do tipo NodePort ou LoadBalancer apontando para o seu Deployment.

No conanfile.txt (Bibliotecas)
Se o seu projeto precisar de outras bibliotecas (como OpenSSL, Boost ou nlohmann_json), basta adicioná-las na seção [requires]. O CMake e o Docker já estão preparados para incluí-las automaticamente no próximo build.

No CMakeLists.txt (Padrão C++)
Se você precisar de funcionalidades do C++20 ou C++23, altere a linha set(CMAKE_CXX_STANDARD 17) para a versão desejada.

📂 Estrutura Visual de Dependências do Projeto
Para facilitar o entendimento de como esses arquivos se conversam, veja o mapa de dependências:

🚨 Solução de Problemas Comuns (Troubleshooting)
Erro conan: not found: Verifique se o binário do Conan está no PATH definido no Jenkinsfile. No Linux, geralmente fica em ~/.local/bin.

Erro 403 Forbidden no Git: Isso ocorre se o seu Jenkins tentar atualizar o status do commit no GitHub sem um Token com permissão de escrita. Você pode ignorar esse erro ou fornecer um Personal Access Token (PAT) com permissões de repo:status.

Erro Invalid RFC 1123 subdomain no K8s: Certifique-se de que o nome da sua pasta no GitHub não contém caracteres especiais além de hífens e números. Nosso script já trata underscores, mas evite pontos ou espaços.

Push: Envio para o Registry local.

K8s Deploy: Deploy/Atualização no cluster.
