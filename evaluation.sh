#!/usr/bin/env bash
# Script to evaluate our algorithm, by comparing it against some extracted and compiled OCaml code.
# Modules to check should be specified in ./examples/Evaluation.v
# Run this script with `make evaluation`.
# Output files can be found in ./examples/evaluation*

set -euo pipefail


EVAL_LIBRARY=$1

SRC_DIR=evaluation_out/${EVAL_LIBRARY}

# Run a full OCaml compilation to native binary code
echo "Compiling OCaml code"
make -C ./${SRC_DIR}/ -f ../../Makefile_OCaml Program.out

echo "Compilation successful"

# Get all compilation symbols, that are functions and belong to the extracted ml files
C=( $(objdump -t ./${SRC_DIR}/Program.out | grep F | grep "$(cd ./${SRC_DIR}/; ls *.ml | sed 's/^\(.*\).ml$/caml\1./')" | awk '{print $6}') )

for c in "${C[@]}"; do
    # Removing the caml and coq_ prefixes
    rocq_mod=$(echo "$c" | sed 's/^caml//g' | sed 's/__/./g' | sed 's/.coq_/./')
    # Decompile each symbol and check for recursive calls
    if objdump --disassemble=$c ./${SRC_DIR}/Program.out | grep call | grep -q "$c"; then
        echo "${rocq_mod%_*} ($c)"
    fi
done | sed -f modmapping.sed | sort > ./evaluation_out/Library_${EVAL_LIBRARY}_compilation.txt

exit 0
