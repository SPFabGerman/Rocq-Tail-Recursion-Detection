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
echo "Compiling Evaluation.v"
rocq compile -R theories TRchecker examples/Evaluation.v | sort | grep -E "^Corelib"| uniq | sed -f filter_prop.sed | grep -v '^$' | tee ./evaluation_out/evaluation_results_algorithm.txt

# Run a full OCaml compilation to native binary code
echo "Compiling OCaml code"
make -C ./evaluation_out/ -f ../Makefile_OCaml Program.out

# Get all compilation symbols, that are functions and belong to the extracted ml files
C=( $(objdump -t ./evaluation_out/Program.out | grep F | grep "$(cd ./evaluation_out/; ls *.ml | sed 's/^\(.*\).ml$/caml\1./')" | awk '{print $6}') )

for c in "${C[@]}"; do
    # Removing the caml and coq_ prefixes
    rocq_mod=$(echo "$c" | sed 's/^caml//g' | sed 's/__/./g' | sed 's/.coq_/./')
    # Decompile each symbol and check for recursive calls
    if objdump --disassemble=$c ./evaluation_out/Program.out | grep call | grep -q "$c"; then
        echo "${rocq_mod%_*} ($c)"
    fi
done | sed -f modmapping.sed | sort > ./evaluation_out/evaluation_results_compilation.txt

# Creating a file which shows only the functions with the prospective Rocq modules
cat ./evaluation_out/evaluation_results_compilation.txt | cut -d' ' -f 1 > ./evaluation_out/evaluation_results_compilation_mods.txt

# Generate the agreement list
comm -1 -2 ./evaluation_out/evaluation_results_algorithm.txt ./evaluation_out/evaluation_results_compilation_mods.txt > ./evaluation_out/evaluation_results_agreement.txt

# Generate the disagreements for detailed analysis
diff -u ./evaluation_out/evaluation_results_algorithm.txt ./evaluation_out/evaluation_results_compilation_mods.txt > ./evaluation_out/evaluation_results_comparison.txt

