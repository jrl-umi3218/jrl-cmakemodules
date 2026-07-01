# Call jrl_target_headers with a relative path, in a subdirectory.
# jrl_export_package() is called from the main CMakeLists.txt.
jrl_target_headers(mylib INTERFACE
    HEADERS
        my_header.hpp
)
