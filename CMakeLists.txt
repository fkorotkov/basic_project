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
   EXPECTS "" 4 5 6 7 8)

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
   "/opt/llvm-${${PROJECT_NAME}_LLVM_VERSION}.0/include/c++/v1" CACHE
   STRING ${option_description}
   FORCE)

# Options for libc++abi
CMAKE_DEPENDENT_OPTION(${PROJECT_NAME}_ENABLE_LIBCXXABI
   "Links against libc++abi, if available. Defaults to ON if, and only if, ${PROJECT_NAME}_ENABLE_LIBCXX is ON."
   ON "${PROJECT_NAME}_ENABLE_LIBCXX"
   OFF)
set(${PROJECT_NAME}_LIBCXXABI_ROOT_DIR
   "${${PROJECT_NAME}_LIBCXX_ROOT_DIR}" CACHE
   STRING "The path to the root directory for libc++. Defaults to ${PROJECT_NAME}_LIBCXX_ROOT_DIR."
   FORCE)

# Options for sanitisers
set(valid_sanitiser_options
   ""
   address               # see https://clang.llvm.org/docs/AddressSanitizer.html
   undefined             # see https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
   thread                # see https://clang.llvm.org/docs/ThreadSanitizer.html
   memory                # see https://clang.llvm.org/docs/MemorySanitizer.html
   cfi                   # see https://clang.llvm.org/docs/ControlFlowIntegrity.html
   dataflow              # see https://clang.llvm.org/docs/DataFlowSanitizer.html
   shadow-call-stack     # see https://clang.llvm.org/docs/ShadowCallStack.html
   safe-stack            # see https://clang.llvm.org/docs/SafeStack.html
)
basic_project_enumerated_option(
   OPTION_NAME ${PROJECT_NAME}_REQUIRED_SANITISERS
   DESCRIPTION
      "Enables a list of sanitisers in Debug mode."
      "The list of sanitisers must be available to the compiler."
      "ControlFlowIntegrity (cfi) is not enabled in Debug mode: it is only enabled in Release modes."
   TYPE STRING LIST
   EXPECTS ${valid_sanitiser_options}
   DEFAULT_VALUE undefined)

basic_project_enumerated_option(
   OPTION_NAME ${PROJECT_NAME}_OPTIONAL_SANITISERS
   DESCRIPTION
      "Enables a list of sanitisers in Debug mode."
      "Sanitisers not available to the compiler are ignored."
      "ControlFlowIntegrity (cfi) is not enabled in Debug mode: it is only enabled in Release modes."
   TYPE STRING LIST
   EXPECTS ${valid_sanitiser_options}
   DEFAULT_VALUE address cfi)

option(${PROJECT_NAME}_ENABLE_ORIGIN_TRACKING
   "Turns on MemorySanitizer's origin tracking when MemorySanitizer is enabled. Defaults to ON, but is only useful if MemorySanitizer is enabled."
   ON)
option(${PROJECT_NAME}_SANITISE_RELEASE
   "Turns on sanitisers in Release modes. Defaults to OFF."
   OFF)

# Coverage options
basic_project_enumerated_option(
   OPTION_NAME ${PROJECT_NAME}_CODE_COVERAGE
   DESCRIPTION "Enables/disables code coverage. Options are Off, GCov, and LLVMSourceCoverage."
   TYPE STRING LIST
   EXPECTS Off gcov LLVMSourceCoverage
   DEFAULT_VALUE gcov)

include("${CMAKE_BINARY_DIR}/conan_paths.cmake" REQUIRED)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Project configuration
include(enable-sanitisers)
include(enable-clang-tidy)
include(enable-iwyu)
include(add_build_targets)

find_package(CodeCoverage REQUIRED)
# find_package(LibCXX REQUIRED)

enable_testing()
include(CTest)

set(PROJECT_DIRECTORY_PREFIX "${PROJECT_NAME}")
add_subdirectory(source)
add_subdirectory(test)
