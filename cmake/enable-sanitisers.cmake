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

# Control-flow integrity sanitisers can only be enabled when a linker supports LTO (thus some form
# of release mode is necessary).
#
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND "${CMAKE_BUILD_TYPE}" MATCHES "Rel" AND ${PROJECT_NAME}_ENABLE_CFI)
   set(${PROJECT_NAME}_enable_cfi "cfi")
else()
   set(${PROJECT_NAME}_enable_cfi "")
endif()

if(${PROJECT_NAME}_ENABLE_MSAN)
   set(${PROJECT_NAME}_enable_msan "memory")
else()
   set(${PROJECT_NAME}_enable_msan "")
endif()

find_package(Sanitizer
   REQUIRED COMPONENTS               # Sanitisers supported by both GCC and LLVM.
      # address                        # see https://clang.llvm.org/docs/AddressSanitizer.html
      undefined                      # see https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
      # thread                         # see https://clang.llvm.org/docs/ThreadSanitizer.html
      ${${PROJECT_NAME}_enable_cfi}  # see https://clang.llvm.org/docs/ControlFlowIntegrity.html
      ${${PROJECT_NAME}_enable_msan} # see https://clang.llvm.org/docs/MemorySanitizer.html

   OPTIONAL_COMPONENTS   # LLVM supports significantly more sanitisers than GCC.
      dataflow           # see https://clang.llvm.org/docs/DataFlowSanitizer.html
      shadow-call-stack  # see https://clang.llvm.org/docs/ShadowCallStack.html
      # safe-stack         # see https://clang.llvm.org/docs/SafeStack.html
)

unset(${PROJECT_NAME}_enable_cfi)
unset(${PROJECT_NAME}_enable_msan)
