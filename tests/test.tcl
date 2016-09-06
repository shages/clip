#!/usr/bin/env tclsh
package require Tk

lappend auto_path [pwd]
package require ghclip

# setup canvas
grid [canvas .c -width 600 -height 600 -background \#ffffff]

#############################
# Vertex creation
#############################
set v1 [ghclip::vertex::create 40 10]
set v2 [ghclip::vertex::create 20 30]
set v3 [ghclip::vertex::create 50 50]
puts "v1: [$v1 getc]"
puts "v2: [$v2 getc]"
puts "v3: [$v3 getc]"
.c create line {*}[concat {0 0} [$v1 getc]] -width 1 -fill \#0000ff
.c create line {*}[concat {0 0} [$v2 getc]] -width 1 -fill \#0000ff
.c create line {*}[concat {0 0} [$v3 getc]] -width 1 -fill \#0000ff

#############################
# Polygon creation
#############################
set poly [ghclip::polygon create {200 200 250 200 250 250 200 250}]
foreach i {3 4 5 6} {
    puts [ghclip::vertex::V_${i} get_prev]
    puts [ghclip::vertex::V_${i} get_next]
}
puts "INFO: Poly: [$poly get_poly]"
.c create polygon {*}[$poly get_poly] -fill {} -outline \#bb00ff -fill {} -width 4

#############################
# Inserting a vertex
#############################
puts "BEFORE: [$poly get_poly]"
ghclip::vertex::insert_after 301 299 [$poly get_start]
puts "AFTER:  [$poly get_poly]"

#############################
# Intersect two lines
#############################
# Create two lines
set l1 [list [ghclip::vertex::create 200 50] [ghclip::vertex::create 300 160]]
set l2 [list [ghclip::vertex::create 220 130] [ghclip::vertex::create 400 75]]
.c create line {*}[concat [[lindex $l1 0] getc] [[lindex $l1 1] getc]] -width 3 -fill \#00ff00
.c create line {*}[concat [[lindex $l2 0] getc] [[lindex $l2 1] getc]] -width 3 -fill \#0000ff

# Intersect them
set point [lindex [ghclip::intersect \
[list {*}[[lindex $l1 0] getc] {*}[[lindex $l1 1] getc]] \
[list {*}[[lindex $l2 0] getc] {*}[[lindex $l2 1] getc]] \
] 0]
if {$point ne ""} {
    puts "INFO: Intersection at: $point"
    .c create text {*}$point -text "intersection"
} else {
    puts "ERROR: Intersection not found"
}

#############################
# Polygon intersection test
#############################
# Draw poly with points 
proc draw_poly {canv poly {color \#000000} {dir "-"} {marker_size 4}} {
    $canv create polygon {*}$poly -outline $color -fill {} -width 3
    set prev ""
    foreach {x y} $poly {
        # Draw point
        $canv create line $x $y [expr $x + $marker_size] [expr $y $dir $marker_size] -width [expr $marker_size/2.0] -fill \#000000
        set prev [list $x $y]
    }
}

set polycoords1 {200 300 200 400 300 400 300 300}
foreach {x y} $polycoords1 {
    lappend polycoords2 [expr $x + 50]
    lappend polycoords2 [expr $y + 0]
}
set polycoords2 {220 300 220 400 280 400 280 300}

foreach {x y} $polycoords1 {
    lappend polycoords3 [expr $x + 200]
    lappend polycoords3 [expr $y + 0]
}
foreach {x y} $polycoords2 {
    lappend polycoords4 [expr $x + 200]
    lappend polycoords4 [expr $y + 0]
}


set poly1 [ghclip::polygon create $polycoords1]
set poly2 [ghclip::polygon create $polycoords2]
# draw them
draw_poly .c [$poly1 get_poly] \#0000ff
draw_poly .c [$poly2 get_poly] \#ff0000 +

puts "==== poly1 ===="
foreach v [$poly1 get_vertices] {
    puts "INTERSECTION: $poly1: $v: [$v get_is_intersection]"
}

puts "==== poly2 ===="
foreach v [$poly2 get_vertices] {
    puts "INTERSECTION: $poly2: $v: [$v get_is_intersection]"
}

set poly1 [ghclip::polygon create $polycoords3]
set poly2 [ghclip::polygon create $polycoords4]
# ghclip them
ghclip::create_intersections $poly1 $poly2
# draw them
draw_poly .c [$poly1 get_poly] \#0000ff
draw_poly .c [$poly2 get_poly] \#ff0000 +

puts "==== poly1 ===="
foreach v [$poly1 get_vertices] {
    puts "INTERSECTION: $poly1: $v: [$v get_is_intersection]"
}

puts "==== poly2 ===="
foreach v [$poly2 get_vertices] {
    puts "INTERSECTION: $poly2: $v: [$v get_is_intersection]"
}


#############################
# Check if a point is inside a polygon
#############################

set poly [ghclip::polygon create {420 100 480 100 480 200 420 200}]
draw_poly .c [$poly get_poly] \#00ff00 - 0

foreach test {
    {420 100}
    {480 100}
    {480 200}
    {420 200}
    {450 100}
    {450 200}
    {420 150}
    {480 150}
    {450 150}
    {400 150}
    {500 150}
    {450 80}
    {450 220}
} {
    puts "INFO: PinP Test for: $test inside $poly"
    puts "Result: [$poly encloses {*}$test]"
    # draw it
    .c create text {*}$test -text [$poly encloses {*}$test]
}

#.c postscript -file [file join [file dirname [info script]] output.ps]



#############################
# Clip - mark entry/exits
#############################

puts ""
puts "Entries/exits"
set polycoords1 {200 300 200 400 300 400 300 300}
foreach {x y} $polycoords1 {
    lappend polycoords2 [expr $x + 50]
    lappend polycoords2 [expr $y + 0]
}
set polycoords2 {220 280 220 420 280 420 280 280}

foreach {x y} $polycoords1 {
    lappend polycoords3 [expr $x + 200]
    lappend polycoords3 [expr $y + 0]
}
foreach {x y} $polycoords2 {
    lappend polycoords4 [expr $x + 200]
    lappend polycoords4 [expr $y + 0]
}


set poly1 [ghclip::polygon create $polycoords3]
set poly2 [ghclip::polygon create $polycoords4]
    
# Set intersections
ghclip::create_intersections $poly1 $poly2

puts "==== poly1 intersection ===="
foreach v [$poly1 get_vertices] {
    puts "INTERSECTION: $poly1: $v:\t[$v getc]\t[$v get_is_intersection]\t[$v get_entry]"
}
puts "==== poly2 intersection ===="
foreach v [$poly2 get_vertices] {
    puts "INTERSECTION: $poly2: $v:\t[$v getc]\t[$v get_is_intersection]\t[$v get_entry]"
}


# Re-use poly1/2 from above
ghclip::clip $poly1 $poly2

puts "==== poly1 entry/exit  ===="
foreach v [$poly1 get_vertices] {
    puts "INTERSECTION: $poly1: $v:\t[$v getc]\t[$v get_is_intersection]\t[$v get_entry]"
}
puts "==== poly2 entry/exit  ===="
foreach v [$poly2 get_vertices] {
    puts "INTERSECTION: $poly2: $v:\t[$v getc]\t[$v get_is_intersection]\t[$v get_entry]"
}


