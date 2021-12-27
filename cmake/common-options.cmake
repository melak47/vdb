### common boilerplate

# set up flat binary output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)

# clean binaries in 'clean' target
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_CLEAN_FILES
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
    ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
)

# detect compilers, enable warnings and standard conformance
set(msvc "$<COMPILE_LANG_AND_ID:CXX,MSVC>")
set(gcc "$<COMPILE_LANG_AND_ID:CXX,GNU>")
set(clang "$<COMPILE_LANG_AND_ID:CXX,Clang,AppleClang,ROCMClang,XLClang,FujitsuClang,ARMClang>")

set(simulate_msvc "$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},MSVC>")
set(clang_cl "$<AND:${clang},${simulate_msvc}>")

set(msvc_like "$<OR:${msvc},${clang_cl}>")
set(gcc_like "$<OR:${gcc},$<AND:${clang},$<NOT:${simulate_msvc}>>>")

add_library(options INTERFACE)
add_library(common::options ALIAS options)
target_compile_options(
    options INTERFACE
    $<${msvc_like}:/permissive- /utf-8 /diagnostics:caret /W4>
    $<${gcc_like}:-Wall -Wextra -pedantic-errors>
)
# automatically link this target to any target declared in the caller's directory
link_libraries(common::options)
