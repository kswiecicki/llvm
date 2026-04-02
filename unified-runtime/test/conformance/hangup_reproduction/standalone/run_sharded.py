#!/usr/bin/env python3

# Simulates lit's gtest sharding: launches multiple processes of a gtest
# binary concurrently, each running a different shard. This reproduces the
# conditions under which the L0 driver hang occurs.
#
# Usage:
#   python3 run_sharded.py <binary> [--shards N] [--timeout T]
#
# If --shards is not specified, the shard count is computed using the same
# algorithm as lit's googletest format (start at shard_size=512, halve until
# nshard >= core_count).

import argparse
import math
import os
import signal
import subprocess
import sys
import time


def get_test_count(binary):
    """Query the binary for total test count."""
    result = subprocess.run(
        [binary, "--gtest_list_tests"],
        capture_output=True,
        text=True,
    )
    count = 0
    for line in result.stdout.splitlines():
        if line.startswith("  "):
            count += 1
    return count


def compute_shard_count(num_tests):
    """Replicate lit's shard count algorithm from googletest.py."""
    core_count = os.cpu_count() or 1
    shard_size = 512
    nshard = math.ceil(num_tests / shard_size)
    while nshard < core_count and shard_size > 1:
        shard_size = shard_size // 2
        nshard = math.ceil(num_tests / shard_size)
    return nshard


def main():
    parser = argparse.ArgumentParser(
        description="Run a gtest binary with lit-style sharding"
    )
    parser.add_argument("binary", help="Path to the gtest binary")
    parser.add_argument(
        "--shards", type=int, default=0, help="Number of shards (0=auto)"
    )
    parser.add_argument(
        "--timeout", type=int, default=20, help="Timeout in seconds (default 20)"
    )
    parser.add_argument(
        "--quiet", "-q", action="store_true",
        help="Suppress stdout/stderr from shards (capture instead)"
    )
    args = parser.parse_args()

    if not os.path.isfile(args.binary):
        print(f"Error: binary not found: {args.binary}", file=sys.stderr)
        return 1

    num_tests = get_test_count(args.binary)
    if num_tests == 0:
        print("Error: no tests found in binary", file=sys.stderr)
        return 1

    nshard = args.shards if args.shards > 0 else compute_shard_count(num_tests)

    print(f"Binary: {args.binary}")
    print(f"Tests: {num_tests}")
    print(f"Shards: {nshard}")
    print(f"Timeout: {args.timeout}s")
    print(f"Core count: {os.cpu_count()}")
    print()

    # Launch all shards concurrently
    processes = []
    for idx in range(nshard):
        env = os.environ.copy()
        env["GTEST_TOTAL_SHARDS"] = str(nshard)
        env["GTEST_SHARD_INDEX"] = str(idx)
        env["GTEST_SHUFFLE"] = "0"
        capture = args.quiet
        proc = subprocess.Popen(
            [args.binary],
            env=env,
            stdout=subprocess.PIPE if capture else None,
            stderr=subprocess.PIPE if capture else None,
        )
        processes.append((idx, proc))

    # Poll until all shards finish or timeout expires
    start = time.monotonic()
    completed = 0
    failed = 0
    timed_out = 0

    while time.monotonic() - start < args.timeout:
        if all(proc.poll() is not None for _, proc in processes):
            break
        time.sleep(0.5)

    completed_shards = []
    failed_shards = []
    timedout_shards = []

    for idx, proc in processes:
        ret = proc.poll()
        if ret is not None:
            completed += 1
            if ret != 0:
                failed += 1
                failed_shards.append(idx)
                print(f"[shard {idx}/{nshard}] FAILED (exit {ret})")
            else:
                completed_shards.append(idx)
                print(f"[shard {idx}/{nshard}] COMPLETED (exit 0)")
        else:
            proc.kill()
            proc.wait()
            timed_out += 1
            timedout_shards.append(idx)
            print(f"[shard {idx}/{nshard}] TIMEOUT (still running after {args.timeout}s)")

    elapsed = time.monotonic() - start
    print()
    print(f"Results: {completed} completed, {failed} failed, "
          f"{timed_out} timed out ({elapsed:.1f}s)")

    if timed_out > 0:
        print("*** HANG DETECTED ***")
        return 2
    return 1 if failed > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
