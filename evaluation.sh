#!/usr/bin/env bash
# This script compiles all ML files in the folder SRC_DIR and creates a binary.
# Then, the binary is partially disassembled, i.e. we fetch the ML functions
# and analyze them for call instructions to find the non-tail recursive ones.
# Those functions are mapped to the original module and written to the evaluation
# log for that library.

set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Wrong number of arguments." >&2
  echo "Usage: ./evaluation.sh out_dir library_name"  >&2
  echo "E.g. : ./evaluation.sh evaluation_out Corelib"  >&2
  exit 1
else
  OUT_DIR=$1
  EVAL_LIBRARY=$2
fi

if [ ! -d "$OUT_DIR" ]; then
  echo "Output directory $OUT_DIR does not exist."
  exit 1
fi

SRC_DIR=${OUT_DIR}/${EVAL_LIBRARY}
PROGRAM_PATH=${SRC_DIR}/Program.out

if [ ! -f "$PROGRAM_PATH" ]; then
  echo "$PROGRAM_PATH is no file."
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
done | sed -f modmapping.sed | sort > ./${OUT_DIR}/${EVAL_LIBRARY}_compilation.txt

exit 0
