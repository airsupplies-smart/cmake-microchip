#=============================================================================
# Configure SDCC compiler interface for C files (PIC 8-bit)
#=============================================================================

# Options
option(MICROCHIP_SDCC_USE_NON_FREE "Enable SDCC non-free device libraries" ON)

# Determine SDCC port based on MCU family
set(_SDCC_PORT "")
if(MICROCHIP_MCU_FAMILY MATCHES "^PIC18F")
    set(_SDCC_PORT "pic16")  # SDCC names PIC18 backend 'pic16'
else()
    # PIC12F/PIC16F use 'pic14'
    set(_SDCC_PORT "pic14")
endif()

string(TOLOWER "${MICROCHIP_MCU_MODEL}" _SDCC_DEVICE_LOWER)

# Default file extensions used by SDCC
# For PIC14/PIC16/PIC18 backends, sdcc uses '.o' for objects; using '.rel'
# causes sdcc to reject inputs during the link step.
set(CMAKE_C_OUTPUT_EXTENSION ".o")
set(CMAKE_EXECUTABLE_SUFFIX ".ihx")
set(CMAKE_STATIC_LIBRARY_SUFFIX_C ".lib")

# Common compile flags
set(_SDCC_COMMON_FLAGS "-m${_SDCC_PORT} -p${_SDCC_DEVICE_LOWER} --std-c99")
if(MICROCHIP_SDCC_USE_NON_FREE)
    string(APPEND _SDCC_COMMON_FLAGS " --use-non-free")
endif()

# Initialize C flags for all configurations
string(APPEND CMAKE_C_FLAGS_INIT " ${_SDCC_COMMON_FLAGS}")

# Ensure port/device selection is also applied at link time, otherwise
# sdcc won't know how to handle inputs during CMake try-link.
string(APPEND CMAKE_C_LINK_FLAGS_INIT " ${_SDCC_COMMON_FLAGS}")
string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " ${_SDCC_COMMON_FLAGS}")

# Compile object rule
set(CMAKE_C_COMPILE_OBJECT)
string(APPEND CMAKE_C_COMPILE_OBJECT
    "<CMAKE_C_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -c -o <OBJECT> <SOURCE>"
)

# Link executable rule
# Note: SDCC produces Intel HEX/IHX; CMake target will have .ihx suffix
set(CMAKE_C_LINK_EXECUTABLE)
string(APPEND CMAKE_C_LINK_EXECUTABLE
    "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS>"
    " <OBJECTS> <LINK_LIBRARIES> -o <TARGET>"
)

# Create static library rule (sdar)
if(CMAKE_AR)
    set(CMAKE_C_CREATE_STATIC_LIBRARY)
    string(APPEND CMAKE_C_CREATE_STATIC_LIBRARY
        "<CMAKE_AR> rc <TARGET> <OBJECTS>"
    )
endif()
