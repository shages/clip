# Prefix of all clip test cases
CLIP_TESTS=t1 t2 t3 t4 t5 t6 t7

all: units $(CLIP_TESTS)
png: $(patsubst %.ps,%.png,$(wildcard results/*/*.ps))

# Unit tests for core procs
units:
	./units.tcl

# Clipping test for different cases
t%:
	./$@*
	$(eval PNG:= $(patsubst %.ps,%.png,$(wildcard results/*/*.ps)))

# Convert postscript to png with ghostscript
%.png: %.ps
	gs -dSAFER -sDEVICE=png16m -dGraphicsAlphaBits=4 -dFitPage -g400x400 -o $@ $^

clean:
	$(RM) results/*/*.ps
	$(RM) results/*/*.png
