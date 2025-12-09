#=============================================================================
# Copyright 2016 Sam Hanes
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file COPYING.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake-Microchip,
#  substitute the full License text for the above reference.)

# This module is loaded during the search for a C compiler
# to provide the information necessary to find one.

# Allow selecting the compiler family for 8-bit PICs explicitly.
# Supported values: "XC8", "SDCC" (empty means auto / default to XC8)
set(MICROCHIP_COMPILER ""
    CACHE STRING "Preferred Microchip C compiler for 8-bit PICs (XC8 or SDCC)"
)

if(CMAKE_SYSTEM_PROCESSOR STREQUAL "PIC_8")
    # Prefer explicit user choice; otherwise auto-detect SDCC by compiler name.
    if(MICROCHIP_COMPILER STREQUAL "SDCC" OR (CMAKE_C_COMPILER AND CMAKE_C_COMPILER MATCHES ".*sdcc(\\.exe)?$"))
        include(Platform/MicrochipMCU-C-SDCC)
    else()
        include(Platform/MicrochipMCU-C-XC8)
    endif()
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "PIC_16")
    include(Platform/MicrochipMCU-C-XC16)
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "PIC_32")
    include(Platform/MicrochipMCU-C-XC32)
else()
    message(FATAL_ERROR
        "No C compiler for '${CMAKE_SYSTEM_PROCESSOR}'"
        " is supported yet."
    )
endif()

if(MICROCHIP_C_COMPILER_ID)
    message(STATUS
        "Using Microchip C compiler ${MICROCHIP_C_COMPILER_ID}"
        " ${MICROCHIP_C_COMPILER_VERSION}"
    )
endif()
