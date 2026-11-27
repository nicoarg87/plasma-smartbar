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
# El observador es parte del puente de prueba, pero solo usa D-Bus
# cuando la instalación Qt6 provee ese módulo. Sin D-Bus sigue la demo.
target_sources(smartbar_input_mask_probe PRIVATE
    status_notifier_bridge.cpp
    status_notifier_bridge.h)
if(TARGET Qt6::DBus)
    target_compile_definitions(smartbar_input_mask_probe PRIVATE SMARTBAR_HAS_DBUS=1)
    target_link_libraries(smartbar_input_mask_probe PRIVATE Qt6::DBus)
    add_executable(smartbar_sni_readonly_probe EXCLUDE_FROM_ALL
        status_notifier_readonly.cpp)
    target_link_libraries(smartbar_sni_readonly_probe PRIVATE
        Qt6::Core Qt6::DBus)
endif()
