# ghclip
A TCL implementation of the Greiner-Hormann polygon clipping algorithm.

## Install
The package can be used directly once downloaded.

    lappend auto_path /path/to/ghclip
    package require ghclip

## Support
- The following boolean operations are supported
    * **AND** - intersection
    * **OR** - union
    * **NOT** - difference
    * **XOR** - (A NOT B) OR (B NOT A)
- Degenerate cases are not currently supported in any way. See Tests for more
details.
- Polygons with holes are not supported as inputs, although the algorithm
can return polygons with holes.

## Usage
Clipping is done by forming expressions with `ghclip::clip`.

```tcl
set poly1 {0 0 0 10 10 10 10 0}
set poly2 {5 5 5 15 15 15 15 5}
ghclip::clip $poly1 AND $poly2
```

Expressions can be strung together

```tcl
ghclip::clip $poly1 OR $poly2 AND $poly3
```

and embedded
```tcl
ghlip::clip [ghclip::clip $poly1 OR $poly2] AND $poly3
```

Polygons are clipped strictly left to right. Use command substitution to
achieve the desired clipping.

### Polygon Format
Polygons must be specified as a flat list of coordinates.

    set poly {0 0 10 0 10 10 0 10 0 0}

They can be specified in either form:
- **closed**: The first and last coordinate are the same.
- **unclosed**: The first and last coordinate are automatically connected.

```tcl
set closed   {0 0 10 0 10 10 0 10 0 0}
set unclosed {0 0 10 0 10 10 0 10}
```

`ghclip::clip` will always return unclosed polygon(s).

### Multiple Polygons
Clipping may result in multiple polygons, in which case a list of polygons is
returned. The return value is always a list of list(s) regardless of the actual
result.

## Tests

    cd tests
    make all
    make png

Core functionality is tested with `units.tcl`. Various clipping cases are shown
with `tN-<case>.tcl`, but not all results are correct.

Tests t1-t4 are expected to be correct. t5-t7 are degenerate cases and
are not expected to be correct.

Results in postscript and png are dumped into /tests/results/

Specific notes:
- **t1-self-intersect-1**
    - A OR B - *This is actually correct* but drawn incorrectly. The result
    contains holes which aren't drawn.
- **t2-square-diamond**
    - All correct
- **t3-three-squares**
    - All correct
- **t4-enclosed**
    - XOR and NOT cases are again correct, but drawn incorrectly due to holes.
- **t5-identiy** (*degenerate*)
    - all fail or can't be trusted
- **t6-triangle-square-1** (*degenerate*)
    - all fail or can't be trusted
- **t7-triangle-square-2** (*degenerate*)
    - all fail or can't be trusted

## Examples
![Alt text](/tests/results/t3-three-squares/r2_0.png?raw=true "A XOR B")

![Alt text](/tests/results/t3-three-squares/r2_1.png?raw=true "A XOR B OR C")

![Alt text](/tests/results/t3-three-squares/r2_2.png?raw=true "A XOR B AND C")

![Alt text](/tests/results/t3-three-squares/r2_3.png?raw=true "A XOR B XOR C")

![Alt text](/tests/results/t3-three-squares/r2_4.png?raw=true "A XOR B NOT C")
