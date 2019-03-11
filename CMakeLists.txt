#
#  Copyright 2019 Christopher Di Bella
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
cmake_minimum_required(VERSION 3.13)

project("basic_project" CXX)
add_library(${PROJECT_NAME} INTERFACE)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# clang-tidy options
option(${PROJECT_NAME}_ENABLE_CLANG_TIDY
   "Determines if clang-tidy is enabled or disabled. Enabled by default."
   ON)
set(${PROJECT_NAME}_CLANG_TIDY_PATH
   "/usr/bin/clang-tidy"
   CACHE STRING
      "Sets the path for clang-tidy. Set to \"/usr/bin/clang-tidy\" by default.")

# IWYU options
option(${PROJECT_NAME}_ENABLE_IWYU
   "Switch determines if include-what-you-use is enabled or disabled. Enabled by default."
   ON)
set(${PROJECT_NAME}_IWYU_PATH
   "/usr/bin/iwyu"
   CACHE STRING
      "Sets the path for IWYU. Set to \"/usr/bin/iwyu\" by default.")

# Coverage options
set(CJDB_CODE_COVERAGE_options Off gcov LLVMSourceCoverage)
set(CJDB_CODE_COVERAGE "gcov"
   CACHE STRING "Enables/disables code coverage. Options are Off, GCov, and LLVMSourceCoverage.")
set_property(CACHE CJDB_CODE_COVERAGE PROPERTY STRINGS ${CJDB_CODE_COVERAGE_options})

if(NOT CJDB_CODE_COVERAGE IN_LIST CJDB_CODE_COVERAGE_options)
   message(FATAL_ERROR "CJDB_CODE_COVERAGE must be one of ${CJDB_CODE_COVERAGE_options}.")
endif()

include("${CMAKE_BINARY_DIR}/conan_paths.cmake" REQUIRED)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Project configuration
include(enable-sanitisers)
include(enable-clang-tidy)
include(enable-iwyu)
include(add_build_targets)

find_package(CodeCoverage REQUIRED)

enable_testing()
include(CTest)

set(PROJECT_DIRECTORY_PREFIX "${PROJECT_NAME}")
add_subdirectory(source)
add_subdirectory(test)
