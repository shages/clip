#!/usr/bin/env tclsh

package require Tk

lappend auto_path [file normalize [file join [pwd] ..]]
package require ghclip

set poly1 { 50  50  50 150 150 150 150  50}
set poly2 { 30 100 100 180 180 100 100  30}

# Draw original
grid [canvas .c -width 200 -height 200 -background \#ffffff]
.c create text 0 0 -text "Original" -anchor nw
.c create text 0 10 -text "A" -fill \#0000ff -anchor nw
.c create text 0 20 -text "B" -fill \#ff0000 -anchor nw
.c create polygon {*}$poly1 -fill {} -outline \#0000ff -width 3
.c create polygon {*}$poly2 -fill {} -outline \#ff0000 -width 3

# Draw AND
set canvas .r
grid [canvas $canvas -width 200 -height 200 -background \#ffffff]
grid configure $canvas -row 1 -column 0
$canvas create text 0 0 -text "AND" -anchor nw
$canvas create polygon {*}$poly1 -fill {} -outline \#0000ff -width 3
$canvas create polygon {*}$poly2 -fill {} -outline \#ff0000 -width 3

set colors {00ff00 00ee00 00dd00 00cc00}
set i 0
foreach poly [ghclip::clip_exp $poly1 AND $poly2] {
    $canvas create polygon {*}$poly -fill \#[lindex $colors $i] -outline {}
    incr i
}

# OR
set canvas .r2
grid [canvas $canvas -width 200 -height 200 -background \#ffffff]
grid configure $canvas -row 0 -column 1
$canvas create text 0 0 -text "OR" -anchor nw
$canvas create polygon {*}$poly1 -fill {} -outline \#0000ff -width 3
$canvas create polygon {*}$poly2 -fill {} -outline \#ff0000 -width 3

set colors {00ff00 00ee00 00dd00 00cc00}
set i 0
foreach poly [ghclip::clip_exp $poly1 OR $poly2] {
    $canvas create polygon {*}$poly -fill \#[lindex $colors $i] -outline {}
    incr i
}

# XOR
set canvas .r3
grid [canvas $canvas -width 200 -height 200 -background \#ffffff]
grid configure $canvas -row 1 -column 1
$canvas create text 0 0 -text "XOR" -anchor nw
$canvas create polygon {*}$poly1 -fill {} -outline \#0000ff -width 3
$canvas create polygon {*}$poly2 -fill {} -outline \#ff0000 -width 3

set colors {00ff00 00ee00 00dd00 00cc00}
set i 0
foreach poly [ghclip::clip_exp $poly1 XOR $poly2] {
    $canvas create polygon {*}$poly -fill \#[lindex $colors $i] -outline {}
    incr i
}

# ANDNOT (degenerate case)
# currently breaks with 180 instead of 170 in poly2
#set canvas .r4
#grid [canvas $canvas -width 200 -height 200 -background \#ffffff]
#grid configure $canvas -row 0 -column 2
#$canvas create text 0 0 -text "ANDNOT" -anchor nw
#$canvas create polygon {*}$poly1 -fill {} -outline \#0000ff -width 3
#$canvas create polygon {*}$poly2 -fill {} -outline \#ff0000 -width 3
#
#set colors {00ff00 00ee00 00dd00 00cc00}
#set i 0
#foreach poly [ghclip::clip_exp $poly1 ANDNOT $poly2] {
#    $canvas create polygon {*}$poly -fill \#[lindex $colors [expr $i % [llength $colors]]] -outline {}
#    incr i
#}
