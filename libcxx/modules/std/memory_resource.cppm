// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

module;
#include <memory_resource>

export module std:memory_resource;
export namespace std::pmr {
  // [mem.res.class], class memory_resource
  using std::pmr::memory_resource;

  using std::pmr::operator==;
#if 1 // P1614
  using std::operator!=;
#endif

  // [mem.poly.allocator.class], class template polymorphic_allocator
  using std::pmr::polymorphic_allocator;

  // [mem.res.global], global memory resources
  using std::pmr::get_default_resource;
  using std::pmr::new_delete_resource;
  using std::pmr::null_memory_resource;
  using std::pmr::set_default_resource;

  // [mem.res.pool], pool resource classes
  using std::pmr::monotonic_buffer_resource;
  using std::pmr::pool_options;
  using std::pmr::synchronized_pool_resource;
  using std::pmr::unsynchronized_pool_resource;
} // namespace std::pmr
