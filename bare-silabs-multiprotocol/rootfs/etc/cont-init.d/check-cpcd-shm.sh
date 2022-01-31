#!/bin/bash
# ==============================================================================
# Check that no other CPC instance is running on this system
# ==============================================================================
if test -d /dev/shm/cpcd; then
    echo "Another CPC daemon running!"
    exit 1
fi
