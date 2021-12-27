### conan integration

set(CONAN_INSTALL_FOLDER ${CMAKE_BINARY_DIR}/conan)

list(APPEND CMAKE_MODULE_PATH
    ${CONAN_INSTALL_FOLDER} # allow find_package in config mode (cmake_find_package_multi generator)
)
list(APPEND CMAKE_PREFIX_PATH ${CONAN_INSTALL_FOLDER}) # allow find_package in module mode (cmake_find_package generator)

set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_CLEAN_FILES
    ${CONAN_INSTALL_FOLDER}
    ${CMAKE_BINARY_DIR}/conanfile.txt
)

# don't run install unless necessary to save time
set(CONANFILE ${CMAKE_SOURCE_DIR}/conanfile.txt)
set(LAST_CONANFILE ${CMAKE_BINARY_DIR}/conanfile.txt)

file(MD5 ${CONANFILE} CONANFILE_HASH)

if (NOT EXISTS ${LAST_CONANFILE} OR NOT CONANFILE_HASH STREQUAL LAST_CONANFILE_HASH)
    include(conan)

    get_property(MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

    if (MULTI_CONFIG)
        foreach(TYPE ${CMAKE_CONFIGURATION_TYPES})
            conan_cmake_autodetect(settings BUILD_TYPE "${TYPE}")
            conan_cmake_install(
                PATH_OR_REFERENCE ${CMAKE_SOURCE_DIR}/conanfile.txt
                BUILD missing
                GENERATOR cmake_find_package_multi
                INSTALL_FOLDER ${CONAN_INSTALL_FOLDER}
                SETTINGS ${settings}
            )
        endforeach()

    else() # single-config
        # override dependency build type to Release,
        # conan-center doesn't have RelWithDebInfo binaries
        if (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
            set(CONAN_BUILD_TYPE "build_type=Release")
        endif()

        conan_cmake_autodetect(settings)
        unset(LAST_CONANFILE_HASH CACHE)
        conan_cmake_install(
            PATH_OR_REFERENCE ${CONANFILE}
            BUILD missing
            GENERATOR cmake_find_package
            INSTALL_FOLDER ${CONAN_INSTALL_FOLDER}
            SETTINGS ${settings} ${CONAN_BUILD_TYPE}
        )
        set(
            LAST_CONANFILE_HASH ${CONANFILE_HASH} CACHE STRING
            "conanfile.txt after last successful conan install"
        )
        # cause cmake to reconfigure if we make changes to conanfile.txt
        configure_file(${CONANFILE} ${LAST_CONANFILE} COPYONLY)
    endif()
endif()
# suppress lots of noisy messages from find_package of conan deps
set(CONAN_CMAKE_SILENT_OUTPUT ON)
