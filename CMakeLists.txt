cmake_minimum_required(VERSION 3.15)

project(vdb VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(common-options)
include(conan-integration)

find_package(OpenVDB REQUIRED)

add_executable(vdb
    src/vdb.cpp
)
target_link_libraries(vdb PRIVATE OpenVDB::openvdb_static)
