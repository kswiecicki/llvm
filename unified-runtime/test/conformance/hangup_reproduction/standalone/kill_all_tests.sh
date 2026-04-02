#!/bin/bash
# Kill by executable path (works on zombies too, unlike lsof)
pgrep -f "./build/hangup-reproduction-l0-test" | xargs -r kill -9
