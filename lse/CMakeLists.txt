cmake_minimum_required(VERSION 3.21)
project(lightweight_sdl_extension LANGUAGES C)

find_package(SDL3 REQUIRED CONFIG)
find_package(SDL3_image REQUIRED CONFIG)
find_package(SDL3_ttf REQUIRED CONFIG)

set(OUTDIR "${CMAKE_CURRENT_SOURCE_DIR}/../libs")
set(CMAKE_INSTALL_PREFIX "${OUTDIR}")

FILE(GLOB SOURCES src/*.c)
add_library(LSE SHARED src/events.c
    src/gpu.c
    src/pipeline.c
    src/utils.c)


IF (WIN32)
    set_target_properties(LSE PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
ENDIF()

target_link_libraries(LSE
    PRIVATE
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

foreach(sdl_target SDL3::SDL3-shared SDL3_image::SDL3_image SDL3_ttf::SDL3_ttf)
    get_target_property(sdl_path ${sdl_target} IMPORTED_LOCATION)
    if(NOT sdl_path)
        get_target_property(sdl_path ${sdl_target} IMPORTED_LOCATION_RELEASE)
    endif()
    if(NOT sdl_path)
        get_target_property(sdl_path ${sdl_target} LOCATION)
    endif()

    if(sdl_path)
    ADD_CUSTOM_COMMAND(TARGET LSE POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy
                    ${sdl_path}
                    ${OUTDIR}
                    COMMENT "Copying ${sdl_target} to '${OUTDIR}'")
    endif()
endforeach()