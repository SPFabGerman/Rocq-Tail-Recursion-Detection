OCAMLOPT=ocamlopt
OCAMLDEP=ocamldep
OCAMLFLAGS=-g

INPUT=$(wildcard *.ml)
OBJS=$(INPUT:ml=cmx)

# Okay, this is kinda cursed, but here we are.
# The problem is that ocamldeps gives us an order to compile the ml to cmx files,
# but it does not tell us how the cmx files need to be ordered for the linker.
# Our workaround is as follows:
# Files that are dependencies of others need to be compiled first, so their cmx files
# have an earlier creation time.
# So we take all generated cmx files and order them by creation time, to recreate the
# compilation order and pass that onto the linker.
# This is ugly, very much so, but it works.
Program.out: $(OBJS)
	$(OCAMLOPT) -o $@ $(OCAMLFLAGS) $(shell ls -t -r $^)


%.cmo: %.ml
	$(OCAMLOPT) $(OCAMLFLAGS) -c $<

%.cmi: %.mli
	$(OCAMLOPT) $(OCAMLFLAGS) -c $<

%.cmx: %.ml
	$(OCAMLOPT) $(OCAMLFLAGS) -c $<

clean:
	rm -f Program.out
	rm -f *.cm[iox]
	rm -f *.o

cleanall: clean
	rm -f *.ml *.mli
	rm -f .depend

.depend:
	$(OCAMLDEP) *.mli *.ml > .depend

include .depend
