macro(GENERATE_INCLUDE_FLAGS)
  get_property(
    dirs
    DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    PROPERTY INCLUDE_DIRECTORIES)
  set(INCLUDE_FLAGS "")
  foreach(dir ${dirs})
    set(INCLUDE_FLAGS "-I${dir}" ${INCLUDE_FLAGS})
  endforeach()
endmacro(GENERATE_INCLUDE_FLAGS)

macro(ADD_SWIG_PYTHON_BINDING FILENAME DIRECTORY)
  find_program(SWIG swig)
  if(${SWIG} STREQUAL SWIG-NOTFOUND)
    message(FATAL_ERROR "Cannot find swig")
  endif()
  generate_include_flags()
  set(outname ${CMAKE_BINARY_DIR}/${DIRECTORY}/${FILENAME}_wrap.cxx)
  add_custom_command(
    OUTPUT ${outname}
    COMMAND ${SWIG} ARGS -c++ -python -outcurrentdir ${INCLUDE_FLAGS}
            ${CMAKE_SOURCE_DIR}/${DIRECTORY}/${FILENAME}.i
    MAIN_DEPENDENCY ${FILENAME}.i)
  set(PYTHON_SWIG_SOURCES ${FILENAME} ${PYTHON_SWIG_SOURCES})
  set(PYTHON_SWIG_STUBS ${CMAKE_BINARY_DIR}/${DIRECTORY}/${FILENAME}_wrap.cxx
                        ${PYTHON_SWIG_STUBS})
endmacro(ADD_SWIG_PYTHON_BINDING FILENAME)

macro(GENERATE_SWIG_BINDINGS)
  add_custom_target(generate_python_bindings DEPENDS ${PYTHON_SWIG_STUBS})
endmacro(GENERATE_SWIG_BINDINGS)

macro(BUILD_SWIG_BINDINGS LIBRARIES)
  foreach(stub ${PYTHON_SWIG_SOURCES})
    set(libname "${stub}_lib")
    set(realname "_${stub}")
    set(stubname "${stub}_wrap.cxx")
    set(stubpath "${CMAKE_BINARY_DIR}/binding/${stubname}")
    set(SWIG_TARGETS ${libname} ${SWIG_TARGETS})
    set_source_files_properties(${stubpath} PROPERTIES GENERATED 1)
    add_library(${libname} SHARED ${stubpath})
    target_link_libraries(${libname} ${LIBRARIES})
    add_dependencies(${libname} generate_python_bindings)
    set_target_properties(${libname} PROPERTIES OUTPUT_NAME ${realname} PREFIX
                                                                        "")
  endforeach()
endmacro()

macro(INSTALL_SWIG_BINDINGS PYTHON_SITELIB PACKAGE)
  foreach(target ${SWIG_TARGETS})
    install(TARGETS ${target} DESTINATION ${PYTHON_SITELIB}/${PACKAGE})
  endforeach()
  foreach(source ${PYTHON_SWIG_SOURCES})
    install(PROGRAMS ${CMAKE_BINARY_DIR}/binding/${source}.py
            DESTINATION ${PYTHON_SITELIB}/${PACKAGE})
  endforeach()
endmacro()
