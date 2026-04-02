# Copyright (C) 2026 Intel Corporation
# Part of the Unified-Runtime Project, under the Apache License v2.0 with LLVM Exceptions.
# See LICENSE.TXT
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

# add_conformance_devices_test(hangup-reproduction-ur
#     hangup_test_ur.cpp
# )

add_testing_binary(hangup-reproduction-l0-test hangup_test_l0.cpp)

target_link_libraries(hangup-reproduction-l0-test PRIVATE
    LevelZeroLoader
    LevelZeroLoader-Headers
    ComputeRuntimeLevelZero-Headers
    GTest::gtest_main
)

target_include_directories(hangup-reproduction-l0-test PRIVATE
    LevelZeroLoader-Headers
    ${CMAKE_SOURCE_DIR}/source/adapters/level_zero/external
)

# add_testing_binary(hangup-reproduction-l0-counter-test hangup_test_l0_other.cpp)

# target_link_libraries(hangup-reproduction-l0-counter-test PRIVATE
#     LevelZeroLoader
#     LevelZeroLoader-Headers
#     ComputeRuntimeLevelZero-Headers
#     GTest::gtest_main
# )

# target_include_directories(hangup-reproduction-l0-counter-test PRIVATE
#     LevelZeroLoader-Headers
#     ${CMAKE_SOURCE_DIR}/source/adapters/level_zero/external
# )
