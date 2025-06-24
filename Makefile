
.PHONY: build test_suite install evaluation clean mrproper all dirs

all: build

EvalLibs = EvalCorelib EvalStdlib

EvalDirs    = $(addprefix  evaluation_out/,${EvalLibs})
EvalTargets = $(addprefix  evaluation_out/Library_,$(addsuffix _summary.txt,${EvalLibs}))

CoqMakefile: _CoqProject
	@echo "Generating $@ from $<."
	@coq_makefile -o $@ -f $<


CoqMakefileTests: _CoqProjectTests
	@echo "Generating $@ from $<."
	@coq_makefile -o $@ -f $<


build: CoqMakefile
	@echo "Compiling Rocq code."
	@$(MAKE) -f CoqMakefile all

test_suite: build CoqMakefileTests
	@echo "Starting test suite."
	@$(MAKE) -f CoqMakefileTests all

install: build
	@echo "Installing."
	@$(MAKE) -f CoqMakefile install

evaluation: build dirs ${EvalTargets}
	@echo "Starting evaluation"

dirs:
	@mkdir -p ${EvalDirs}


.PRECIOUS: evaluation_out/Library_%_raw.txt
evaluation_out/Library_%_raw.txt : evaluation/%.v
	@echo "Compiling $< and generating $@"
	@rocq compile -R theories TRchecker $^ | grep -v "^Module contains" > $@

.PRECIOUS: evaluation_out/Library_%_reccalls.txt
evaluation_out/Library_%_reccalls.txt : evaluation_out/Library_%_raw.txt
	@echo "Filtering recursive calls into $@"
	@cat $< | grep -v "^Unsupported" | sort | uniq > $@

.PRECIOUS: evaluation_out/Library_%_tailreccalls.txt
evaluation_out/Library_%_tailreccalls.txt : evaluation_out/Library_%_reccalls.txt
	@echo "Filtering tail recursive calls into $@"
	@cat $< | grep "^Tail-Recursive" > $@

.PRECIOUS: evaluation_out/Library_%_recfuncs.txt
evaluation_out/Library_%_recfuncs.txt : evaluation_out/Library_%_reccalls.txt
	@echo "Filtering recursive functions into $@"
	@cat $< | sed 's/^.*(\(.*\)):.*$$/\1/' | sort | uniq > $@

.PRECIOUS: evaluation_out/Library_%_ntrecfuncs.txt
evaluation_out/Library_%_ntrecfuncs.txt : evaluation_out/Library_%_reccalls.txt
	@echo "Filtering non-tail recursive functions into $@"
	@cat $< | grep "^Non-Tail-Recursive Call" | sed 's/^.*(\(.*\)):.*$$/\1/' | sort | uniq > $@

.PRECIOUS: evaluation_out/Library_%_ntrecfuncs_noprops.txt
evaluation_out/Library_%_ntrecfuncs_noprops.txt : evaluation_out/Library_%_ntrecfuncs.txt
	@echo "Filtering non-propositional non-tail recursive functions into $@"
	@cat $< | sed -f filter_prop.sed | grep -v '^$$' | sort | uniq > $@


.PRECIOUS: evaluation_out/Library_%_compilation.txt
evaluation_out/Library_%_compilation.txt : evaluation_out/Library_%_ntrecfuncs_noprops.txt
	@echo "Running compiler based tests and pushing agreement into $@"
	@bash ./evaluation.sh $(subst _compilation.txt,,$(subst evaluation_out/Library_,,$@))

.PRECIOUS: evaluation_out/Library_%_compilation_mods.txt
evaluation_out/Library_%_compilation_mods.txt : evaluation_out/Library_%_compilation.txt
	@cat $< | cut -d' ' -f 1 > $@

.PRECIOUS: evaluation_out/Library_%_agreement.txt
evaluation_out/Library_%_agreement.txt : evaluation_out/Library_%_compilation_mods.txt
	@comm -2 -3 $(subst _agreement,_ntrecfuncs_noprops,$@) $< > $(subst _agreement,_removed,$@)
	@comm -1 -3 $(subst _agreement,_ntrecfuncs_noprops,$@) $< > $(subst _agreement,_added,$@)
	@comm -1 -2 $(subst _agreement,_ntrecfuncs_noprops,$@) $< > $@

evaluation_out/Library_%_summary.txt : evaluation_out/Library_%_ntrecfuncs_noprops.txt evaluation_out/Library_%_tailreccalls.txt evaluation_out/Library_%_recfuncs.txt evaluation_out/Library_%_agreement.txt
	@echo "=================================================" | tee -a $@
	@echo "Algorithm stats for Rocq library $(subst _summary.txt,,$(subst evaluation_out/Library_Eval,,$@)) and its dependencies" | tee -a $@
	@echo "Recursive Calls            : " `cat $(subst _summary,_reccalls,$@)           | grep -v '^$$' | wc -l` | tee -a $@
	@echo "Tail Recursive Calls       : " `cat $(subst _summary,_tailreccalls,$@)       | grep -v '^$$' | wc -l` | tee -a $@
	@echo "Recursive Functions        : " `cat $(subst _summary,_recfuncs,$@)           | grep -v '^$$' | wc -l` | tee -a $@
	@echo "NTRecursive Functions      : " `cat $(subst _summary,_ntrecfuncs,$@)         | grep -v '^$$' | wc -l` | tee -a $@
	@echo "NTRecursive Type Functions : " `cat $(subst _summary,_ntrecfuncs_noprops,$@) | grep -v '^$$' | wc -l` | tee -a $@
	@echo "=================================================" | tee -a $@
	@echo "Comparison with ocamlopt compiled functions "      | tee -a $@
	@echo "Agreement                  : " `cat $(subst _summary,_agreement,$@)          | grep -v '^$$' | wc -l` | tee -a $@
	@echo "In Rocq only               : " `cat $(subst _summary,_removed,$@)            | grep -v '^$$' | wc -l` | tee -a $@
	@echo "In compiled only           : " `cat $(subst _summary,_added,$@)              | grep -v '^$$' | wc -l` | tee -a $@
	@echo "=================================================" | tee -a $@
	@echo ""
	@echo "This summary can be found in $@"
	@echo "For a list of functions, being only present in Rocq, see $(subst _summary,_removed,$@)"
	@echo "For a list of functions, being only present in ocamlopt compilation output, see $(subst _summary,_added,$@)"
	@echo "Generally, all output files can be found in evaluation_out."
	@echo ""

# The "clean" target (first) cleans up the intermediate files from the
# Rocq formalisation.
clean:
	@echo "Cleaning up intermediate files generated by Rocq."
	@rm -f evaluation/*.{vo,vok,vos,glob,aux}
	@$(MAKE) -f CoqMakefile clean
	@rm -rf **/*.{vo,vok,vos,glob} **/.*.aux
	@rm -rf ./evaluation_out/


# The "mrproper" target (first) does a "clean" and additionally removes
# the CoqMakefile and all byproducts of "coq_makefile"
mrproper: clean
	@echo "Cleaning up the rest of intermediate files generated by Rocq."
	@$(MAKE) -f CoqMakefile cleanall
	@$(MAKE) -f CoqMakefileTests cleanall
	@echo "Deleting CoqMakefile."
	@rm -f CoqMakefile*
