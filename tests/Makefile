# Prefix of all clip test cases
CLIP_TESTS=t1 t2 t3 t4 t5 t6 t7

all: units $(CLIP_TESTS)

# Unit tests for core procs
units:
	./units.tcl

# Clipping test for different cases
t%:
	./$@*

