#=============================================================================
# SDCC support for 8‑bit Microchip PIC (PIC12/16/18)
#=============================================================================

# this module is called by `Platform/MicrochipMCU-C`
# to provide information specific to the SDCC compiler

include(MicrochipPathSearch)

# Optional: allow providing a base path to SDCC
MICROCHIP_PATH_SEARCH(MICROCHIP_SDCC_PATH sdcc
    CACHE "the path to an SDCC installation"
)

if(MICROCHIP_SDCC_PATH)
    list(APPEND CMAKE_PROGRAM_PATH "${MICROCHIP_SDCC_PATH}/bin")
endif()

find_program(CMAKE_C_COMPILER "sdcc"
    HINTS "${MICROCHIP_SDCC_PATH}"
    PATH_SUFFIXES bin
)

if(NOT CMAKE_C_COMPILER)
    message(FATAL_ERROR
        "SDCC compiler executable 'sdcc' was not found. Provide SDCC in PATH "
        "or set -DMICROCHIP_SDCC_PATH=/path/to/sdcc.")
endif()

# Bypass CMake's built-in compiler ID test; set SDCC explicitly
set(CMAKE_C_COMPILER_ID_RUN 1)
set(CMAKE_C_COMPILER_ID "SDCC")
set(MICROCHIP_C_COMPILER_ID "SDCC")

# Try to locate 'sdar' for static libraries
find_program(CMAKE_AR "sdar"
    HINTS "${MICROCHIP_SDCC_PATH}"
    PATH_SUFFIXES bin
)

# Detect SDCC version
function(_sdcc_get_version)
    execute_process(
        COMMAND "${CMAKE_C_COMPILER}" --version
        OUTPUT_VARIABLE output
        ERROR_VARIABLE  output
        RESULT_VARIABLE result
    )
    if(result)
        message(FATAL_ERROR "Calling '${CMAKE_C_COMPILER} --version' failed.")
    endif()
    if(output MATCHES "SDCC version ([0-9]+\.[0-9]+(\.[0-9]+)?)")
        set(CMAKE_C_COMPILER_VERSION ${CMAKE_MATCH_1} PARENT_SCOPE)
    endif()
endfunction()
_sdcc_get_version()

# Load the SDCC compile/link rule configuration
include(Compiler/SDCC-C)
