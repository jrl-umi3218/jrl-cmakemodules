set(Dummy_FOUND true)

if(NOT TARGET Dummy::A)
    add_library(Dummy::A INTERFACE IMPORTED)
endif()

if(NOT TARGET Dummy::B)
    add_library(Dummy::B INTERFACE IMPORTED)
endif()
