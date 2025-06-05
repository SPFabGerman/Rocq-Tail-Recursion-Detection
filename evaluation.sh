#!/usr/bin/env bash
# Script to evaluate our algorithm, by comparing it against some extracted and compiled OCaml code.
# Modules to check should be specified in ./examples/Evaluation.v
# Run this script with `make evaluation`.
# Output files can be found in ./examples/evaluation*

set -euo pipefail

# Remove old files
rm -rf ./evaluation_out/
mkdir -p ./evaluation_out/

# Run rocq to extract all OCaml programs and run our algorithm
rocq compile -R theories TRchecker examples/Evaluation.v | sed 's/^.*(\(.*\)):.*$/\1/' | sort | uniq > ./evaluation_out/evaluation_results_algorithm.txt

# Run a full OCaml compilation to native binary code
make -C ./evaluation_out/ -f ../Makefile_OCaml Program.out

# Get all compilation symbols, that are functions and belong to the extracted ml files
C=( $(objdump -t ./evaluation_out/Program.out | grep F | grep "$(cd ./evaluation_out/; ls *.ml | sed 's/^\(.*\).ml$/caml\1./')" | awk '{print $6}') )

for c in "${C[@]}"; do
    # Decompile each symbol and check for recursive calls
    if objdump --disassemble=$c ./evaluation_out/Program.out | grep call | grep -q "$c"; then
        echo "Found recursive call in: $c"
    fi
done | sort > ./evaluation_out/evaluation_results_compilation.txt
