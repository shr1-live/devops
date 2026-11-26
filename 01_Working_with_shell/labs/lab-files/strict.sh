#!/bin/bash
set -euo pipefail
echo "start"
cat missing-file.txt
echo "never printed"
