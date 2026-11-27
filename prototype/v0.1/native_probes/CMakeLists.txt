cmake_minimum_required(VERSION 3.20)
project(smartbar_input_mask_probe LANGUAGES CXX)

# SOLO herramienta descartable de diagnóstico. No es el build del panel.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
find_package(Qt6 6.2 REQUIRED COMPONENTS Core Gui Qml Quick)

add_executable(smartbar_input_mask_probe soledad_input_mask_main.cpp)
target_link_libraries(smartbar_input_mask_probe PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick)

# Lector opcional de SNI: excluido de la compilación de las islas.
# Solo se solicita cuando se construye explícitamente el target.
find_package(Qt6 6.2 QUIET COMPONENTS DBus)
if(TARGET Qt6::DBus)
    add_executable(smartbar_sni_readonly_probe EXCLUDE_FROM_ALL
        status_notifier_readonly.cpp)
    target_link_libraries(smartbar_sni_readonly_probe PRIVATE
        Qt6::Core Qt6::DBus)
endif()
