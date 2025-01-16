cmake_minimum_required(VERSION 3.15)

# Project-level configuration.
set(PROJECT_NAME "komodo_defi_framework")
project(${PROJECT_NAME} LANGUAGES CXX)

find_library(log-lib log)
find_package(ZLIB)

set(IMPORT_DIR ${CMAKE_SOURCE_DIR}/libs)

# Shared library
set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

# Invoke the build for native code shared with the other target platforms.
# This can be changed to accommodate different builds.
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../../../../../src" "${CMAKE_CURRENT_BINARY_DIR}/shared")

set(komodo_defi_framework_bundled_libraries

  # Defined in ../src/CMakeLists.txt.
  # This can be changed to accommodate different builds.
  $<TARGET_FILE:komodo_defi_framework>
  ${IMPORT_DIR}/${ANDROID_ABI}/libmm2.a
  PARENT_SCOPE
)

