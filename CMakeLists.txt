cmake_minimum_required(VERSION 3.10)
project(cpp-prog1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Busca as dependências
find_package(fmt REQUIRED)
find_package(spdlog REQUIRED)

# Cria o executável principal
add_executable(${PROJECT_NAME} src/main.cpp)

# Linka as bibliotecas
target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt spdlog::spdlog)

# --- CONFIGURAÇÃO DE TESTES ---
find_package(GTest REQUIRED)

enable_testing()

add_executable(${PROJECT_NAME}_tests tests/test_main.cpp)

# Linkamos as libs do projeto + GTest e GTest_Main (que fornece o main())
target_link_libraries(${PROJECT_NAME}_tests 
    PRIVATE 
    fmt::fmt 
    spdlog::spdlog 
    GTest::gtest 
    GTest::gtest_main
)

add_test(NAME MathTest.BasicAssertion COMMAND ${PROJECT_NAME}_tests)