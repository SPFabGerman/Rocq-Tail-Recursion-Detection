#!/usr/bin/env bash
# This script compiles all ML files in the folder SRC_DIR and creates a binary.
# Then, the binary is partially disassembled, i.e. we fetch the ML functions
# and analyze them for call instructions to find the non-tail recursive ones.
# Those functions are mapped to the original module and written to the evaluation
# log for that library.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Wrong number of arguments." >&2
  echo "Usage: ./$(basename "$0") program_path" >&2
  echo "E.g. : ./$(basename "$0") evaluation_out/Corelib/Program.out" >&2
  exit 1
else
  PROGRAM_PATH=$1
  SRC_DIR=$(dirname "${PROGRAM_PATH}")
fi

if [ ! -f "$PROGRAM_PATH" ]; then
  echo "$PROGRAM_PATH is no file." >&2
  exit 1
fi


# Get all compilation symbols, that are functions and belong to the extracted ml files
C=( $(objdump -t ${PROGRAM_PATH} | grep F | grep "$(cd ${SRC_DIR}; ls *.ml | sed 's/^\(.*\).ml$/caml\1./')" | awk '{print $6}') )

for c in "${C[@]}"; do
    # Removing the caml and coq_ prefixes
    rocq_mod=$(echo "$c" | sed -e 's/^caml//;s/__/./g;s/.coq_/./')
    # Decompile each symbol and check for recursive calls
    if objdump --disassemble=$c ${PROGRAM_PATH} | grep call | grep -q "$c"; then
        echo "${rocq_mod%_*} ($c)"
    fi
done

exit 0
