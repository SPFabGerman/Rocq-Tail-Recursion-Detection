#!/usr/bin/env bash
# Script to evaluate our algorithm, by comparing it against some extracted and compiled OCaml code.
# Run this script with `make evaluation`.
# Output files can be found in ./examples/evaluation*

set -euo pipefail

# Remove old files
rm -rf ./examples/evaluation_extracted_code/ ./examples/evaluation_results_algorithm.txt ./examples/evaluation_results_compilation.txt

# Run rocq to extract all OCaml programs and run our algorithm
rocq compile -R theories TRchecker examples/Evaluation.v > ./examples/evaluation_results_algorithm.txt

# Run a full compilation to native binary code with ocamlopt
ocamlopt -o ./examples/evaluation_extracted_code/Nat.out -I ./examples/evaluation_extracted_code/ -g \
    ./examples/evaluation_extracted_code/{Datatypes.mli,Datatypes.ml,Specif.mli,Specif.ml,Decimal.mli,Decimal.ml,Hexadecimal.mli,Hexadecimal.ml,Number.mli,Number.ml,Nat.mli,Nat.ml}

# Get all compilation symbols, that are functions and belong to the Nat group
C=( $(objdump -t ./examples/evaluation_extracted_code/Nat.out | grep F | grep camlNat. | awk '{print $6}') )

for c in "${C[@]}"; do
    # echo "Symbol: $c"
    # Decompile each symbol and check for recursive calls
    # Allow failures in grep, when no calls are found
    objdump --disassemble=$c ./examples/evaluation_extracted_code/Nat.out | grep call | grep "$c" || true
done > ./examples/evaluation_results_compilation.txt
