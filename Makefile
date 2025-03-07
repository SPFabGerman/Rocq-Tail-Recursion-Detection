
.PHONY: build install clean mrproper all

all: build

CoqMakefile: _CoqProject
	@echo "Generating $@ from $<."
	@coq_makefile -o $@ -f $<


build: CoqMakefile
	@echo "Compiling Rocq code."
	@$(MAKE) -f CoqMakefile all

install: build
	@echo "Installing."
	@$(MAKE) -f CoqMakefile install

# The "clean" target (first) cleans up the intermediate files from the
# Rocq formalisation.
clean:
	@echo "Cleaning up intermediate files generated by Rocq."
	@$(MAKE) -f CoqMakefile clean | true


# The "mrproper" target (first) does a "clean" and additionally removes
# the CoqMakefile and all byproducts of "coq_makefile"
mrproper: clean
	@echo "Cleaning up the rest of intermediate files generated by Rocq."
	@$(MAKE) -f CoqMakefile cleanall | true
	@echo "Deleting CoqMakefile."
	@rm -f CoqMakefile*
