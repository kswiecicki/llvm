cmake_minimum_required(VERSION 3.14)
project(hangup-reproduction-l0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

include(FetchContent)

# Google Test
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG v1.14.0
)
FetchContent_MakeAvailable(googletest)

# Level Zero Loader
find_package(LevelZero QUIET)
if(NOT LevelZero_FOUND)
    # Try pkg-config
    find_package(PkgConfig QUIET)
    if(PkgConfig_FOUND)
        pkg_check_modules(LevelZero level-zero)
    endif()
endif()

if(NOT LevelZero_FOUND AND NOT LevelZero_INCLUDE_DIRS)
    # Manual fallback - adjust these paths for your system
    find_path(LevelZero_INCLUDE_DIRS level_zero/ze_api.h
        HINTS
            ENV LEVEL_ZERO_DIR
            /usr/include
            /usr/local/include
    )
    find_library(LevelZero_LIBRARIES ze_loader
        HINTS
            ENV LEVEL_ZERO_DIR
            /usr/lib
            /usr/lib/x86_64-linux-gnu
            /usr/local/lib
    )
endif()

add_executable(hangup-reproduction-l0-test hangup_test_l0.cpp)

target_link_libraries(hangup-reproduction-l0-test PRIVATE
    GTest::gtest_main
    ${LevelZero_LIBRARIES}
)

target_include_directories(hangup-reproduction-l0-test PRIVATE
    ${LevelZero_INCLUDE_DIRS}
)
