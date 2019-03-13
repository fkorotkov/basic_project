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

# Check that AddressSanitizer doesn't clash with any of:
#     ThreadSanitizer
#     MemorySanitizer
#     SafeStack
#     ShadowCallStack
#
function(flag_incompatible_sanitisers required optional)
   set(joined "${required}")
   list(APPEND joined "${optional}")
   list(FIND joined "address" result)

   if(result GREATER -1)
      list(FIND joined "thread" thread_result)
      if(thread_result GREATER -1)
         message(SEND_ERROR "Cannot enable both AddressSanitizer and ThreadSanitizer.")
      endif()

      list(FIND joined "memory" memory_result)
      if(memory_result GREATER -1)
         message(SEND_ERROR "Cannot enable both AddressSanitizer and MemorySanitizer.")
      endif()

      list(FIND joined "safe-stack" safe_stack_result)
      if(safe_stack_result GREATER -1)
         message(SEND_ERROR "Cannot enable both AddressSanitizer and SafeStack.")
      endif()

      list(FIND joined "shadow-call-stack" shadow_call_stack_result)
      if (shadow_call_stack_result GREATER -1)
         message(SEND_ERROR "Cannot enable both AddressSanitizer and ShadowCallStack.")
      endif()
   endif()
endfunction()

flag_incompatible_sanitisers(
   "${${PROJECT_NAME}_REQUIRED_SANITISERS}"
   "${${PROJECT_NAME}_OPTIONAL_SANITISERS}")

find_package(Sanitizer
   REQUIRED COMPONENTS ${${PROJECT_NAME}_REQUIRED_SANITISERS}
   OPTIONAL_COMPONENTS ${${PROJECT_NAME}_OPTIONAL_SANITISERS})
