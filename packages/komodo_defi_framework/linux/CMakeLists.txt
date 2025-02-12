# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.15)

# Project-level configuration.
set(PROJECT_NAME "komodo_defi_framework")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

add_library(${PLUGIN_NAME} SHARED
    "mm2_plugin.cc"
)

# Invoke the build for native code shared with the other target platforms.
# This can be changed to accommodate different builds.
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../src" "${CMAKE_CURRENT_BINARY_DIR}/shared")

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
    CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
    "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

# Copy kdf binary to $HOME/.local/bin/kdf to make it accessible
set(FINAL_INSTALL_DIR "$ENV{HOME}/.local/bin")
set(KDF_PATH "${CMAKE_CURRENT_SOURCE_DIR}/bin/kdf")

add_custom_command(
    TARGET ${PLUGIN_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${KDF_PATH} 
        "${FINAL_INSTALL_DIR}/kdf"
)

# List of absolute paths to libraries that should be bundled with the plugin
set(mm2_bundled_libraries
    "${CMAKE_CURRENT_SOURCE_DIR}/libmm2.so"
    PARENT_SCOPE
)

set(KDF_PATH "${CMAKE_CURRENT_SOURCE_DIR}/bin/kdf")

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(komodo_defi_framework_bundled_libraries

  # Defined in ../src/CMakeLists.txt.
  # This can be changed to accommodate different builds.
  $<TARGET_FILE:komodo_defi_framework>
  ${KDF_PATH}
  PARENT_SCOPE
)

# For local development/debugging/testing
# Copies the KDF binary to $HOME/.local/bin to make it accessible
# This simplifies debug environment setup - avoids adding platform-dependent
# paths to vscode debugging configurations or environment variables
set(FINAL_INSTALL_DIR "$ENV{HOME}/.local/bin")
set(KDF_PATH "${CMAKE_CURRENT_SOURCE_DIR}/bin/kdf")
add_custom_command(
    TARGET ${PLUGIN_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${KDF_PATH} 
        "${FINAL_INSTALL_DIR}/kdf"
)