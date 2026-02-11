cmake_minimum_required(VERSION 3.21)
project(lightweight_sdl_extension LANGUAGES C)

find_package(SDL3 REQUIRED CONFIG)
find_package(SDL3_image REQUIRED CONFIG)
find_package(SDL3_ttf REQUIRED CONFIG)

set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/../libs")

FILE(GLOB SOURCES src/*.c)
add_library(LSE SHARED ${SOURCES})
target_link_libraries(LSE
    PUBLIC 
        SDL3::SDL3-shared
        SDL3_image::SDL3_image
        SDL3_ttf::SDL3_ttf
)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)
set_target_properties(LSE PROPERTIES LINKER_LANGUAGE C)
install(
    TARGETS LSE
    LIBRARY DESTINATION .
)