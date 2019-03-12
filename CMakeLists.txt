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

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/macros.cmake")
include(CMakeDependentOption)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# LLVM options
basic_project_enumerated_option(
   OPTION_NAME ${PROJECT_NAME}_LLVM_VERSION
   DESCRIPTION "Determines the version of LLVM tools to build with"
   TYPE STRING
   VALID_VALUES "" 4 5 6 7 8)

# clang-tidy options
option(${PROJECT_NAME}_ENABLE_CLANG_TIDY "Builds with clang-tidy, if available. Defaults to ON." ON)
set(${PROJECT_NAME}_CLANG_TIDY_PATH "/usr/bin/clang-tidy" CACHE
   STRING "Sets the path for clang-tidy. Defaults to \"/usr/bin/clang-tidy\".")

# IWYU options
option(${PROJECT_NAME}_ENABLE_IWYU "Builds with IWYU, if available. Defaults to ON." ON)
set(${PROJECT_NAME}_IWYU_PATH "/usr/bin/iwyu" CACHE
   STRING "Sets the path for IWYU. Defaults to \"/usr/bin/iwyu\".")

# Options for libc++
option(${PROJECT_NAME}_ENABLE_LIBCXX "Builds with libc++, if available. Defaults to OFF." OFF)
BASIC_PROJECT_MULTILINE_STRING(option_description
   "The path to the root directory for libc++."
   " Defaults to \"/opt/llvm-${${PROJECT_NAME}_${LLVM_VERSION}}\"."
)
set(${PROJECT_NAME}_LIBCXX_ROOT_DIR
   "/opt/llvm-${${PROJECT_NAME}_${LLVM_VERSION}}/include/c++/v1" CACHE
   STRING ${option_description})

# Options for libc++abi
CMAKE_DEPENDENT_OPTION(${PROJECT_NAME}_ENABLE_LIBCXXABI
   "Links against libc++abi, if available. Defaults to ON if, and only if, ${PROJECT_NAME}_ENABLE_LIBCXX is ON."
   ON "${PROJECT_NAME}_ENABLE_LIBCXX"
   OFF)
set(${PROJECT_NAME}_LIBCXXABI_ROOT_DIR
   "${${PROJECT_NAME}_LIBCXX_ROOT_DIR}" CACHE
   STRING "The path to the root directory for libc++. Defaults to ${PROJECT_NAME}_LIBCXX_ROOT_DIR.")

# Options for sanitisers
BASIC_PROJECT_MULTILINE_STRING(option_description
   "Builds ${PROJECT_NAME} binaries and tests with -fsanitize=memory."
   "This requires a C++ Standard library built with MemorySanitizer."
   "Defaults to OFF.")
option(${PROJECT_NAME}_ENABLE_MSAN ${option_description} OFF)

BASIC_PROJECT_MULTILINE_STRING(option_description
   "Builds ${PROJECT_NAME} binaries and tests with"
      "`-fsanitize-memory-track-origins -fno-omit-frame-pointer`."
   "Requires ${PROJECT_NAME}_ENABLE_MSAN to be turned ON."
   "Defaults to ON if, and only if, ${PROJECT_NAME}_ENABLE_MSAN is turned ON."
)
CMAKE_DEPENDENT_OPTION(${PROJECT_NAME}_ENABLE_ORIGIN_CHECKING ${option_description}
   ON "${PROJECT_NAME}_ENABLE_MSAN"
   OFF)

option(${PROJECT_NAME}_ENABLE_RELEASE_SANITISATION
   "Builds ${PROJECT_NAME} binaries and tests with sanitisers in Release mode. Defaults to OFF."
   OFF)

BASIC_PROJECT_MULTILINE_STRING(option_description
   "Builds ${PROJECT_NAME} binaries and tests with `-fsanitize=cfi`."
   "This is not disabled by ${PROJECT_NAME}_ENABLE_RELEASE_SANITISERS=OFF."
   "Requires the compiler to be Clang and the build type to match Rel."
   "Defaults to ON if, and only if, the compiler is Clang and the build type matches Rel."
)
CMAKE_DEPENDENT_OPTION(${PROJECT_NAME}_ENABLE_CFI ${option_description}
   ON "${CMAKE_CXX_COMPILER_ID} MATCHES Clang;${CMAKE_BUILD_TYPE} MATCHES Rel"
   OFF)

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
find_package(LibCXX REQUIRED)

enable_testing()
include(CTest)

set(PROJECT_DIRECTORY_PREFIX "${PROJECT_NAME}")
add_subdirectory(source)
add_subdirectory(test)
