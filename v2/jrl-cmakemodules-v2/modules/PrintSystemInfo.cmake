function(jrl_print_full_system_and_compiler_info loglevel)
    set(log_msg "")

    macro(_log msg)
        string(APPEND log_msg "${msg}\n")
    endmacro()

    macro(_log_var VAR)
        if(DEFINED ${VAR})
            _log("${VAR}: ${${VAR}}")
        else()
            _log("${VAR}: <UNDEFINED>")
        endif()
    endmacro()

    _log("==============================================================")
    _log("        FULL SYSTEM / COMPILER INFO (WITH VARIABLE NAMES)")
    _log("==============================================================")

    #
    # System Info
    #
    foreach(
        V
        CMAKE_SYSTEM_NAME
        CMAKE_SYSTEM_VERSION
        CMAKE_SYSTEM_PROCESSOR
        CMAKE_HOST_SYSTEM_NAME
        CMAKE_HOST_SYSTEM_VERSION
        CMAKE_HOST_SYSTEM_PROCESSOR
        CMAKE_BUILD_TYPE
    )
        _log_var(${V})
    endforeach()

    #
    # CMake / Generator Info
    #
    foreach(
        V
        CMAKE_VERSION
        CMAKE_GENERATOR
        CMAKE_GENERATOR_PLATFORM
        CMAKE_GENERATOR_TOOLSET
        CMAKE_SOURCE_DIR
        CMAKE_BINARY_DIR
    )
        _log_var(${V})
    endforeach()

    #
    # Per-language compiler info (greatly extended)
    #
    _log("================== LANGUAGE COMPILERS ==================")
    foreach(
        LANG
        C
        CXX
        CUDA
        OBJC
        OBJCXX
        Fortran
        ASM
    )
        if(CMAKE_${LANG}_COMPILER)
            _log("----------- ${LANG} FULL COMPILER INFO -----------")

            foreach(
                V
                CMAKE_${LANG}_COMPILER
                CMAKE_${LANG}_COMPILER_ID
                CMAKE_${LANG}_COMPILER_VERSION
                CMAKE_${LANG}_COMPILER_ABI
                CMAKE_${LANG}_COMPILER_FRONTEND_VARIANT
                CMAKE_${LANG}_PLATFORM_ID
                CMAKE_${LANG}_SIMULATE_ID
                CMAKE_${LANG}_COMPILER_AR
                ${LANG}_COMPILER_LAUNCHER
                CMAKE_${LANG}_STANDARD_INCLUDE_DIRECTORIES
                CMAKE_${LANG}_FLAGS
                CMAKE_${LANG}_FLAGS_DEBUG
                CMAKE_${LANG}_FLAGS_RELEASE
                CMAKE_${LANG}_FLAGS_RELWITHDEBINFO
                CMAKE_${LANG}_FLAGS_MINSIZEREL
            )
                _log_var(${V})
            endforeach()
        endif()
    endforeach()

    #
    # Compiler Frontend Raw Version Output
    #
    _log("================== COMPILER FRONTENDS ==================")
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        _log("Frontend Detected: Clang")
        execute_process(
            COMMAND ${CMAKE_CXX_COMPILER} --version
            OUTPUT_VARIABLE FRONTEND_OUT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        _log("CLANG_RAW_VERSION (value) :\n${FRONTEND_OUT}")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        _log("Frontend Detected: GCC")
        execute_process(
            COMMAND ${CMAKE_CXX_COMPILER} -v
            OUTPUT_VARIABLE FRONTEND_OUT
            ERROR_VARIABLE FRONTEND_OUT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        _log("GCC_RAW_VERSION (value) :\n${FRONTEND_OUT}")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        _log("Frontend Detected: MSVC")
        _log_var(MSVC_VERSION)
    endif()

    #
    # --- Enhanced Clang vs AppleClang Detection ---
    #
    _log("================== ADVANCED CLANG DETECTION ==================")

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|AppleClang")
        execute_process(
            COMMAND ${CMAKE_CXX_COMPILER} --version
            OUTPUT_VARIABLE CLANG_V_OUT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        execute_process(
            COMMAND ${CMAKE_CXX_COMPILER} -v
            OUTPUT_VARIABLE CLANG_VV_OUT
            ERROR_VARIABLE CLANG_VV_OUT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        _log("CXX_RAW_VERSION (from --version) :\n${CLANG_V_OUT}")
        _log("CXX_RAW_VERBOSE (from -v)        :\n${CLANG_VV_OUT}")

        #
        # Detect AppleClang
        #
        set(DETECTED_APPLECLANG FALSE)

        # Signature 1: version header includes "Apple LLVM version" or "Apple clang version"
        if(CLANG_V_OUT MATCHES "Apple[ ]+(LLVM|clang) version")
            set(DETECTED_APPLECLANG TRUE)
        endif()

        # Signature 2: toolchain path often includes Xcode toolchains
        if(CLANG_VV_OUT MATCHES "Xcode")
            set(DETECTED_APPLECLANG TRUE)
        endif()

        if(CLANG_VV_OUT MATCHES "apple")
            set(DETECTED_APPLECLANG TRUE)
        endif()

        # Signature 3: compiler path inside Xcode or macOS SDK
        if(CMAKE_CXX_COMPILER MATCHES "Xcode|apple|/Applications/Xcode")
            set(DETECTED_APPLECLANG TRUE)
        endif()

        if(DETECTED_APPLECLANG)
            _log("CLANG_FLAVOR (value) : AppleClang (detected with heuristics)")
        else()
            _log("CLANG_FLAVOR (value) : Upstream Clang/LLVM")
        endif()
    endif()

    #
    # --- Dump compiler target triplets ---
    #
    _log("================== COMPILER TARGET TRIPLE DETECTION ==================")

    # Try -dumpmachine
    execute_process(
        COMMAND ${CMAKE_CXX_COMPILER} -dumpmachine
        OUTPUT_VARIABLE TRIP_DUMPMACHINE
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )

    if(TRIP_DUMPMACHINE)
        _log("CXX_TARGET_TRIPLE (-dumpmachine) : ${TRIP_DUMPMACHINE}")
    endif()

    # Try -print-target-triple
    execute_process(
        COMMAND ${CMAKE_CXX_COMPILER} -print-target-triple
        OUTPUT_VARIABLE TRIP_PRINT_TARGET
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )

    if(TRIP_PRINT_TARGET)
        _log("CXX_TARGET_TRIPLE (-print-target-triple) : ${TRIP_PRINT_TARGET}")
    endif()

    # Try -print-multiarch (Debian/Ubuntu)
    execute_process(
        COMMAND ${CMAKE_CXX_COMPILER} -print-multiarch
        OUTPUT_VARIABLE TRIP_MULTIARCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )

    if(TRIP_MULTIARCH)
        _log("CXX_MULTIARCH_TRIPLE (-print-multiarch) : ${TRIP_MULTIARCH}")
    endif()

    # Fallback if none of the above worked:
    if(NOT TRIP_DUMPMACHINE AND NOT TRIP_PRINT_TARGET AND NOT TRIP_MULTIARCH)
        _log("CXX_TARGET_TRIPLE : <not provided by compiler>")
    endif()

    #
    # Target / Cross Compilation Info
    #
    _log("================== TARGET INFO ==================")
    foreach(
        V
        CMAKE_CROSSCOMPILING
        CMAKE_CROSSCOMPILING_EMULATOR
        CMAKE_SYSTEM_PROCESSOR
        CMAKE_HOST_SYSTEM_PROCESSOR
    )
        _log_var(${V})
    endforeach()

    foreach(LANG C CXX)
        if(DEFINED CMAKE_${LANG}_COMPILER_TARGET)
            _log_var(CMAKE_${LANG}_COMPILER_TARGET)
        endif()
    endforeach()

    #
    # Toolchain / Linker Tools
    #
    _log("================== TOOLCHAIN INFO ==================")
    foreach(
        V
        CMAKE_LINKER
        CMAKE_AR
        CMAKE_RANLIB
        CMAKE_NM
        CMAKE_OBJCOPY
        CMAKE_OBJDUMP
        CMAKE_STRIP
    )
        _log_var(${V})
    endforeach()

    #
    # Environment Variables
    #
    _log("================== ENVIRONMENT ==================")
    foreach(
        V
        PATH
        CC
        CXX
        CFLAGS
        CXXFLAGS
    )
        if(DEFINED ENV{${V}})
            set(env_val "$ENV{${V}}")
            string(REPLACE "\\" "/" env_val "${env_val}")
            _log("ENV{${V}} : ${env_val}")
        else()
            _log("ENV{${V}} : <UNDEFINED>")
        endif()
    endforeach()

    _log("==============================================================")
    _log("                   END OF REPORT")
    _log("==============================================================")

    message(${loglevel} "${log_msg}")
endfunction()
