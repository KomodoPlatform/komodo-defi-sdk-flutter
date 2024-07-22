# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(komodo_defi_framework_library VERSION 0.0.1 LANGUAGES C)

add_library(komodo_defi_framework SHARED
  "komodo_defi_framework.c"
)

set_target_properties(komodo_defi_framework PROPERTIES
  PUBLIC_HEADER komodo_defi_framework.h
  OUTPUT_NAME "komodo_defi_framework"
)

target_compile_definitions(komodo_defi_framework PUBLIC DART_SHARED_LIB)
