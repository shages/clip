# ghclip
A TCL implementation of the Greiner-Hormann polygon clipping algorithm.

### Install
The package can be used directly once downloaded.

    lappend auto_path /path/to/ghclip
    package require ghclip

### Support
- The following boolean operations are supported
    * AND - intersection
    * OR - union
    * XOR - difference
    * NOT - subtraction
- Degenerate cases are not currently supported. See Tests for details.
- Polygons with holes are not supported.

### Usage
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

#### Polygon Format
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

#### Multiple Polygons
Clipping may result in multiple polygons, in which case a list of polygons is
returned. The return value is always a list of list(s) regardless of the actual
result.

### Tests

    cd tests
    make all

Core functionality is tested with `units.tcl`. Various clipping cases are shown with
`tN-<case>.tcl`, but the results aren't guaranteed to be correct.

The following cases produce incorrect results.

- **t1-self-intersect-1**
    - A XOR B
- **t2-square-diamond**
    - A XOR B
- **t3-three-squares**
    - A NOT B OR C
    - anything with XOR
- **t4-enclosed**
    - all fail
- **t5-identiy**
    - all fail
- **t6-degenerate-1**
    - all fail or can't be trusted
- **t7-degenerate-2**
    - all fail or can't be trusted
