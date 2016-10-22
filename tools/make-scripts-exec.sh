#!/bin/bash
REAL_PATH=$(python -c "import os,sys;print os.path.realpath('$0')")
cd "$(dirname "$REAL_PATH")/.."

find . -type f -name "*.sh" -exec bash -c 'chmod +x "$0"' {} \;
find . -type f -name "*.py" -exec bash -c 'chmod +x "$0"' {} \;
