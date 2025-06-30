
.PHONY: clean clean-rocq clean-% cleanall all


EVAL_OUT_DIR ?= evaluation_out

# The libraries to evaluate, i.e. the basenames of the vernacular files in ./evaluation/
EvalLibs = Corelib Stdlib

# The evaluation target summaries to generate.
EvalTargets = $(EvalLibs:%=${EVAL_OUT_DIR}/%_summary.txt)


all: ${EvalTargets}


######
#  The following part covers targets for algorithm based analysis
######


# Creates the raw output of checking a library.
.PRECIOUS: ${EVAL_OUT_DIR}/%_raw.txt
${EVAL_OUT_DIR}/%_raw.txt : evaluation/%Check.v
	@echo "Compiling $< and generating $@"
	@mkdir -p ${EVAL_OUT_DIR}
	@rocq compile -R theories TRchecker $^ | grep -v "^Module contains" > $@


# Extracts the recursive calls from the raw output for a library.
.PRECIOUS: ${EVAL_OUT_DIR}/%_reccalls.txt
${EVAL_OUT_DIR}/%_reccalls.txt : ${EVAL_OUT_DIR}/%_raw.txt
	@echo "Filtering recursive calls into $@"
	@cat $< | grep -v "^Unsupported" | sort | uniq > $@


# Extracts the tail recursive calls from the recursive calls output for a library.
.PRECIOUS: ${EVAL_OUT_DIR}/%_tailreccalls.txt
${EVAL_OUT_DIR}/%_tailreccalls.txt : ${EVAL_OUT_DIR}/%_reccalls.txt
	@echo "Filtering tail recursive calls into $@"
	@cat $< | grep "^Tail-Recursive" > $@


# Extracts the recursive functions from the recursive calls output for a library.
.PRECIOUS: ${EVAL_OUT_DIR}/%_recfuncs.txt
${EVAL_OUT_DIR}/%_recfuncs.txt : ${EVAL_OUT_DIR}/%_reccalls.txt
	@echo "Filtering recursive functions into $@"
	@cat $< | sed 's/^.*(\(.*\)):.*$$/\1/' | sort | uniq > $@


# Extracts the non-tail recursive functions from the recursive calls output for a library.
.PRECIOUS: ${EVAL_OUT_DIR}/%_ntrecfuncs.txt
${EVAL_OUT_DIR}/%_ntrecfuncs.txt : ${EVAL_OUT_DIR}/%_reccalls.txt
	@echo "Filtering non-tail recursive functions into $@"
	@cat $< | grep "^Non-Tail-Recursive Call" | sed 's/^.*(\(.*\)):.*$$/\1/' | sort | uniq > $@


# Extracts the Type/Set non-tail recursive functions from the non-tail recursive function info for a library.
.PRECIOUS: ${EVAL_OUT_DIR}/%_ntrecfuncs_noprops.txt
${EVAL_OUT_DIR}/%_ntrecfuncs_noprops.txt : ${EVAL_OUT_DIR}/%_ntrecfuncs.txt
	@echo "Filtering non-propositional non-tail recursive functions into $@"
	@cat $< | sed -f filter_prop.sed > $@


######
#  The following part covers targets for compilation based analysis
######


# We create .extracted when the extraction is finished
.PRECIOUS: ${EVAL_OUT_DIR}/%/.extracted
${EVAL_OUT_DIR}/%/.extracted : evaluation/%Extraction.v
	@mkdir -p $(subst .extracted,,$@)
	@$(MAKE) -C $(basename $@) -f ../../MakefileOCaml.mk cleanall
	@rocq compile -R theories TRchecker $<
	@touch $@


# To create Program.out, we need the extraction
.PRECIOUS: ${EVAL_OUT_DIR}/%/Program.out
${EVAL_OUT_DIR}/%/Program.out : ${EVAL_OUT_DIR}/%/.extracted
	@$(MAKE) -C $(subst Program.out,,$@) -f ../../MakefileOCaml.mk Program.out


# Runs the compilation based evaluation and generates the non-tail recursive calls found in the binary of the library.
.PRECIOUS: ${EVAL_OUT_DIR}/%_compilation.txt
${EVAL_OUT_DIR}/%_compilation.txt : ${EVAL_OUT_DIR}/%/Program.out
	@echo "Running compiler based tests on $< and pushing found non-tail recursive functions and assembly based name into $@"
	@bash ./dump_rec_calls.sh $< | sed -f modmapping.sed | sort > $@


# Extracts the fully qualified function names from the compilation based evaluation.
.PRECIOUS: ${EVAL_OUT_DIR}/%_compilation_mods.txt
${EVAL_OUT_DIR}/%_compilation_mods.txt : ${EVAL_OUT_DIR}/%_compilation.txt
	@echo "Extracting non-tail recursive function names from compilation output $@"
	@cat $< | cut -d' ' -f 1 > $@


######
#  The following part covers targets for comparing results
######


# Generates a list of functions that occur in the algorithm output but not in the compilation based output
.PRECIOUS: ${EVAL_OUT_DIR}/%_removed.txt
${EVAL_OUT_DIR}/%_removed.txt : ${EVAL_OUT_DIR}/%_ntrecfuncs_noprops.txt ${EVAL_OUT_DIR}/%_compilation_mods.txt
	@echo "Extracting functions found by the algorithm but not in object code into $@"
	@comm -2 -3 $^ > $@


# Generates a list of functions that occur in the compilation based output but not in the algorithm output
.PRECIOUS: ${EVAL_OUT_DIR}/%_added.txt
${EVAL_OUT_DIR}/%_added.txt : ${EVAL_OUT_DIR}/%_ntrecfuncs_noprops.txt ${EVAL_OUT_DIR}/%_compilation_mods.txt
	@echo "Extracting functions found in object code but not by the algorithm into $@"
	@comm -1 -3 $^ > $@


# Generates a list of functions for which our algorithm agrees with the compilation based output.
.PRECIOUS: ${EVAL_OUT_DIR}/%_agreement.txt
${EVAL_OUT_DIR}/%_agreement.txt : ${EVAL_OUT_DIR}/%_ntrecfuncs_noprops.txt ${EVAL_OUT_DIR}/%_compilation_mods.txt
	@echo "Extracting functions on which both the algorithm and the object based analysis agree into $@"
	@comm -1 -2 $^ > $@


# Generates a summary for the library being analyzed.
${EVAL_OUT_DIR}/%_summary.txt : ${EVAL_OUT_DIR}/%_ntrecfuncs_noprops.txt ${EVAL_OUT_DIR}/%_tailreccalls.txt ${EVAL_OUT_DIR}/%_recfuncs.txt ${EVAL_OUT_DIR}/%_agreement.txt ${EVAL_OUT_DIR}/%_added.txt ${EVAL_OUT_DIR}/%_removed.txt
	@echo "=================================================" | tee -a $@
	@echo "Algorithm stats for Rocq library $(subst _summary.txt,,$(subst ${EVAL_OUT_DIR}/,,$@)) and its dependencies" | tee -a $@
	@echo "Recursive Calls            : " `cat $(subst _summary,_reccalls,$@)           | grep -c -v '^$$' ` | tee -a $@
	@echo "Tail Recursive Calls       : " `cat $(subst _summary,_tailreccalls,$@)       | grep -c -v '^$$' ` | tee -a $@
	@echo "Recursive Functions        : " `cat $(subst _summary,_recfuncs,$@)           | grep -c -v '^$$' ` | tee -a $@
	@echo "NTRecursive Functions      : " `cat $(subst _summary,_ntrecfuncs,$@)         | grep -c -v '^$$' ` | tee -a $@
	@echo "NTRecursive Type Functions : " `cat $(subst _summary,_ntrecfuncs_noprops,$@) | grep -c -v '^$$' ` | tee -a $@
	@echo "=================================================" | tee -a $@
	@echo "Comparison with ocamlopt compiled functions "      | tee -a $@
	@echo "Agreement                  : " `cat $(subst _summary,_agreement,$@)          | grep -c -v '^$$' ` | tee -a $@
	@echo "In Rocq only               : " `cat $(subst _summary,_removed,$@)            | grep -c -v '^$$' ` | tee -a $@
	@echo "In compiled only           : " `cat $(subst _summary,_added,$@)              | grep -c -v '^$$' ` | tee -a $@
	@echo "=================================================" | tee -a $@
	@echo ""
	@echo "This summary can be found in $@"
	@echo "For a list of functions, being only present in Rocq, see $(subst _summary,_removed,$@)"
	@echo "For a list of functions, being only present in ocamlopt compilation output, see $(subst _summary,_added,$@)"
	@echo "Generally, all output files can be found in ${EVAL_OUT_DIR}."
	@echo ""



######
#  The following part is for cleanup
######


clean-%: ${EVAL_OUT_DIR}/%
	@echo "Cleaning up intermediate files generated by OCaml in ${EVAL_OUT_DIR}/$<."
	@$(MAKE) -C $< -f ../../MakefileOCaml.mk cleanall
	@rm -f $</.extracted

clean-rocq:
	@echo "Cleaning up intermediate files generated by Roqc"
	@rm -rf evaluation/*.{vo,vok,vos,glob}
	@rm -rf evaluation/\..*.aux


clean: clean-rocq $(addprefix clean-,${EvalLibs})


cleanall: clean-rocq
	@echo "Deleting evaluation output folder."
	@rm -rf ./${EVAL_OUT_DIR}
