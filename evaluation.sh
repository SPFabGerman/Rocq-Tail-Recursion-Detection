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
# Create raw output
rocq compile -R theories TRchecker examples/Evaluation.v | grep -v "^Module contains" > ./evaluation_out/evaluation_results_algorithm_raw.txt
# Create list of all recursive calls
cat ./evaluation_out/evaluation_results_algorithm_raw.txt | grep -v "^Unsupported" | sort | uniq > ./evaluation_out/evaluation_results_algorithm_reccalls.txt
# Create list of all tail recursive calls
cat ./evaluation_out/evaluation_results_algorithm_reccalls.txt | grep "^Tail-Recursive" > ./evaluation_out/evaluation_results_algorithm_tailreccalls.txt
# Create list of recursive functions
cat ./evaluation_out/evaluation_results_algorithm_reccalls.txt | sed 's/^.*(\(.*\)):.*$/\1/' | sort | uniq > ./evaluation_out/evaluation_results_algorithm_recfuncs.txt
# Create list of non-tail recursive functions
cat ./evaluation_out/evaluation_results_algorithm_reccalls.txt | grep "^Non-Tail-Recursive Call" | sed 's/^.*(\(.*\)):.*$/\1/' | sort | uniq > ./evaluation_out/evaluation_results_algorithm_ntrecfuncs.txt
# Create list of non-tail recursive, non-prop functions
cat ./evaluation_out/evaluation_results_algorithm_ntrecfuncs.txt | sed -f filter_prop.sed | grep -v '^$' | sort | uniq > ./evaluation_out/evaluation_results_algorithm_ntrecfuncs_noprops.txt

echo "================================================="
echo "Algorithm stats"
echo "Recursive Calls            : " `cat ./evaluation_out/evaluation_results_algorithm_reccalls.txt | grep -v '^$' | wc -l`
echo "Tail Recursive Calls       : " `cat ./evaluation_out/evaluation_results_algorithm_tailreccalls.txt | grep -v '^$' | wc -l`
echo "Recursive Functions        : " `cat ./evaluation_out/evaluation_results_algorithm_recfuncs.txt | grep -v '^$' | wc -l`
echo "NTRecursive Functions      : " `cat ./evaluation_out/evaluation_results_algorithm_ntrecfuncs.txt | grep -v '^$' | wc -l`
echo "NTRecursive Type Functions : " `cat ./evaluation_out/evaluation_results_algorithm_ntrecfuncs_noprops.txt | grep -v '^$' | wc -l`
echo "================================================="


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
comm -1 -2 ./evaluation_out/evaluation_results_algorithm_ntrecfuncs_noprops.txt ./evaluation_out/evaluation_results_compilation_mods.txt > ./evaluation_out/evaluation_results_agreement.txt

# Generate the disagreements for detailed analysis
diff -u ./evaluation_out/evaluation_results_algorithm_ntrecfuncs_noprops.txt ./evaluation_out/evaluation_results_compilation_mods.txt > ./evaluation_out/evaluation_results_comparison.txt

