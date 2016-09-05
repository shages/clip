#!/usr/bin/env tclsh
package require Tk

lappend auto_path [file join [pwd] lib]
package require clip

set v1 [clip::vertex::create 100 100]
set v2 [clip::vertex::create 200 300]
set v3 [clip::vertex::create 500 50]
puts "v1: [$v1 getc]"
puts "v2: [$v2 getc]"
puts "v3: [$v3 getc]"

grid [canvas .c -width 600 -height 600 -background \#ffffff]
.c create line {*}[concat [$v1 getc] [$v2 getc] [$v3 getc]] -width 4 -fill \#ff00ff
.c create line {*}[concat {0 0} [$v1 getc]] -width 1 -fill \#0000ff
.c create line {*}[concat {0 0} [$v2 getc]] -width 1 -fill \#0000ff
.c create line {*}[concat {0 0} [$v3 getc]] -width 1 -fill \#0000ff
.c create polygon {*}[concat [$v1 getc] [$v2 getc] [$v3 getc]] -fill \#eeff00 -outline {}

set poly [clip::polygon create {200 200 250 200 250 250 200 250}]
foreach i {3 4 5 6} {
    puts [clip::vertex::V_${i} get_prev]
    puts [clip::vertex::V_${i} get_next]
}
#puts "INFO: start_vertex: $clip::polygon::${poly}::start_vertex"
puts "INFO: Poly: [$poly get_poly]"
.c create polygon {*}[$poly get_poly] -fill {} -outline \#bb00ff -fill {} -width 4

#.c create polygon {*}$cpoly -outline \#ff0000 -fill {} -width 5 
#.c create polygon {*}$spoly -outline \#0000cc -fill {}
#.c lower [.c create polygon {*}[clippoly $cpoly $spoly] -fill \#ffff99 -outline {}]

# Inserting a vertex
puts "BEFORE: [$poly get_poly]"
clip::vertex::insert_after 301 299 [$poly get_start]
puts "AFTER:  [$poly get_poly]"

# Create two lines
set l1 [list [clip::vertex::create 200 0] [clip::vertex::create 300 160]]
set l2 [list [clip::vertex::create 0 100] [clip::vertex::create 500 0]]
.c create line {*}[concat [[lindex $l1 0] getc] [[lindex $l1 1] getc]] -width 3 -fill \#00ff00
.c create line {*}[concat [[lindex $l2 0] getc] [[lindex $l2 1] getc]] -width 3 -fill \#0000ff

# Intersect two lines
set point [clip::intersect \
[list {*}[[lindex $l1 0] getc] {*}[[lindex $l1 1] getc]] \
[list {*}[[lindex $l2 0] getc] {*}[[lindex $l2 1] getc]] \
]
if {$point ne ""} {
    puts "Intersection at: $point"
    .c create text {*}$point -text "intersection"
} else {
    puts "Intersection not found"
}

# Draw poly with points 
proc draw_poly {canv poly {color \#000000} {dir "-"}} {
    set prev ""
    foreach {x y} $poly {
        puts "XY: $x $y"
        if {$prev == ""} {
        } else {
            $canv create line {*}$prev $x $y -width 3  -fill $color
        }
        # Draw point
        set size 4
        $canv create line $x $y [expr $x + $size] [expr $y $dir $size] -width $size -fill \#000000
        set prev [list $x $y]
    }
}

set polycoords1 {200 300 200 400 300 400 300 300}
set polycoords2 {}
foreach {x y} $polycoords1 {
    lappend polycoords2 [expr $x + 50]
    lappend polycoords2 [expr $y + 0]
}

foreach {x y} $polycoords1 {
    lappend polycoords3 [expr $x + 200]
    lappend polycoords3 [expr $y + 0]
}
foreach {x y} $polycoords3 {
    lappend polycoords4 [expr $x + 50]
    lappend polycoords4 [expr $y + 0]
}


set poly1 [clip::polygon create $polycoords1]
set poly2 [clip::polygon create $polycoords2]
# draw them
draw_poly .c [$poly1 get_poly] \#0000ff
draw_poly .c [$poly2 get_poly] \#ff0000 +


set poly1 [clip::polygon create $polycoords3]
set poly2 [clip::polygon create $polycoords4]
# clip them
clip::create_intersections $poly1 $poly2
# draw them
draw_poly .c [$poly1 get_poly] \#0000ff
draw_poly .c [$poly2 get_poly] \#ff0000 +

# Get neighbors

foreach v [$poly1 get_vertices] {
    puts "INTERSECTION: $poly1: $v: [$v get_is_intersection]"
}

foreach v [$poly2 get_vertices] {
    puts "INTERSECTION: $poly2: $v: [$v get_is_intersection]"
}

