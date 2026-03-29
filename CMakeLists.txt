cmake_minimum_required(VERSION 3.15)

# 1. Pega o nome da pasta (ex: cpp-exer1_master)
get_filename_component(DIR_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)

# 2. LIMPEZA: Remove o sufixo do Jenkins (_master) e troca '_' por '-'
string(REPLACE "_master" "" CLEAN_NAME ${DIR_NAME})
string(REPLACE "_" "-" FINAL_NAME ${CLEAN_NAME})

# 3. Define o projeto com o nome limpo (cpp-exer1)
project(${FINAL_NAME} LANGUAGES CXX)

# O restante do seu código agora usará o nome limpo automaticamente
set(APP_NAME ${PROJECT_NAME})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Dependências (Conan cuidará de encontrar estas)
find_package(fmt REQUIRED)
find_package(spdlog REQUIRED)

# Executável principal usando o nome dinâmico
add_executable(${APP_NAME} src/main.cpp)

target_link_libraries(${APP_NAME}
    PRIVATE
    fmt::fmt
    spdlog::spdlog
)

# --- TESTES ---
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