cmake_minimum_required(VERSION 3.28)

# Definir nome do projeto dinamicamente
if(NOT DEFINED PROJECT_NAME)
    set(PROJECT_NAME cpp-template)
endif()

project(${PROJECT_NAME} VERSION 1.0 LANGUAGES CXX)

# -----------------------------
# Configurações do compilador
# -----------------------------
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# -----------------------------
# Dependências (Conan)
# -----------------------------
find_package(fmt REQUIRED)
find_package(GTest REQUIRED)

# -----------------------------
# Executável principal
# -----------------------------
add_executable(${PROJECT_NAME}
    src/main.cpp
)
target_link_libraries(${PROJECT_NAME}
    PRIVATE fmt::fmt
)

# -----------------------------
# Testes
# -----------------------------
enable_testing()
add_executable(${PROJECT_NAME}_tests
    tests/test_main.cpp
)
target_link_libraries(${PROJECT_NAME}_tests
    PRIVATE GTest::gtest_main
)
include(GoogleTest)
gtest_discover_tests(${PROJECT_NAME}_tests)