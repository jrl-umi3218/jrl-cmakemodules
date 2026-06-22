set(Yummy_FOUND true)

if(NOT TARGET Yummy::A)
    add_library(Yummy::A INTERFACE IMPORTED)
endif()

if(NOT TARGET Yummy::B)
    add_library(Yummy::B INTERFACE IMPORTED)
endif()
