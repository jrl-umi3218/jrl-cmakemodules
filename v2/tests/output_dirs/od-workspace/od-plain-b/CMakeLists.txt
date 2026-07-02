cmake_minimum_required(VERSION 3.22)
project(od-plain-b VERSION 1.0.0 LANGUAGES CXX)

# Plain CMake, added after od-jrl on purpose.
add_library(od_fakelib_plain_b STATIC src/fake.cpp)
