cmake_minimum_required(VERSION 3.10)
project(cpp-template LANGUAGES CXX)

# Permite sobrescrever via linha de comando
if(NOT DEFINED APP_NAME)
    set(APP_NAME cpp-app)
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Busca as dependências
find_package(fmt REQUIRED)
find_package(spdlog REQUIRED)

# Cria o executável principal
add_executable(${APP_NAME} src/main.cpp)

# Linka as bibliotecas
target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt spdlog::spdlog)

# --- CONFIGURAÇÃO DE TESTES ---
find_package(GTest REQUIRED)

enable_testing()

add_executable(${APP_NAME}_tests tests/test_main.cpp)

target_link_libraries(${APP_NAME}_tests 
    PRIVATE 
    fmt::fmt 
    spdlog::spdlog 
    GTest::gtest 
    GTest::gtest_main
)

add_test(NAME MathTest.BasicAssertion COMMAND ${APP_NAME}_tests)