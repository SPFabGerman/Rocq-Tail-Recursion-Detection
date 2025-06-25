#!/usr/bin/env bash
# This script compiles all ML files in the folder SRC_DIR and creates a binary.
# Then, the binary is partially disassembled, i.e. we fetch the ML functions
# and analyze them for call instructions to find the non-tail recursive ones.
# Those functions are mapped to the original module and written to the evaluation
# log for that library.

set -euo pipefail

if [ -z "$1" ]; then
  echo "No library to compile was given."
  echo "Please provide the folder name containing the OCaml files, e.g. Corelib for evaluation_out/Corelib"
  exit 1
else
  EVAL_LIBRARY=$1
fi

SRC_DIR=evaluation_out/${EVAL_LIBRARY}

if [ ! -d "$SRC_DIR" ]; then
  echo "Source directory $SRC_DIR does not exist."
  exit 1
fi


# Run a full OCaml compilation to native binary code
echo "Compiling OCaml code"
make -C ./${SRC_DIR}/ -f ../../Makefile_OCaml Program.out

echo "Compilation successful"

# Get all compilation symbols, that are functions and belong to the extracted ml files
C=( $(objdump -t ./${SRC_DIR}/Program.out | grep F | grep "$(cd ./${SRC_DIR}/; ls *.ml | sed 's/^\(.*\).ml$/caml\1./')" | awk '{print $6}') )

for c in "${C[@]}"; do
    # Removing the caml and coq_ prefixes
    rocq_mod=$(echo "$c" | sed -e 's/^caml//;s/__/./g;s/.coq_/./')
    # Decompile each symbol and check for recursive calls
    if objdump --disassemble=$c ./${SRC_DIR}/Program.out | grep call | grep -q "$c"; then
        echo "${rocq_mod%_*} ($c)"
    fi
done | sed -f modmapping.sed | sort > ./evaluation_out/Library_${EVAL_LIBRARY}_compilation.txt

exit 0
