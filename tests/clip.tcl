#!/usr/bin/env tclsh
package require Tk

lappend auto_path [file normalize [file join [pwd] ..]]
package require ghclip

# setup canvas
grid [canvas .c -width 600 -height 600 -background \#ffffff]

# Draw poly with points
proc draw_poly {canv poly {color \#000000} {dir "-"} {marker_size 4}} {
    $canv create polygon {*}$poly -outline $color -fill {} -width 3
    setp prev ""
    foreach {x y} $poly {
        # Draw point
        $canv create line $x $y [expr $x + $marker_size] [expr $y $dir $marker_size] -width [expr $marker_size/2.0] -fill \#000000
        setp prev [list $x $y]
    }
}

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

draw_poly .c [$poly1 get_poly] \#0000ff
draw_poly .c [$poly2 get_poly] \#ff0000 +

# Set intersections
ghclip::create_intersections $poly1 $poly2

puts "==== poly1 intersection ===="
foreach v [$poly1 get_vertices] {
    puts "INTERSECTION: $poly1: $v:\t[$v getp coord]\t[$v getp is_intersection]\t[$v getp entry]"
}
puts "==== poly2 intersection ===="
foreach v [$poly2 get_vertices] {
    puts "INTERSECTION: $poly2: $v:\t[$v getp coord]\t[$v getp is_intersection]\t[$v getp entry]"
}


# Re-use poly1/2 from above
set rpolies [ghclip::clip $poly1 $poly2]

foreach poly $rpolies {
    .c create polygon {*}$poly -fill \#cccc00 -outline {}
}

puts "==== poly1 entry/exit  ===="
foreach v [$poly1 get_vertices] {
    puts "INTERSECTION: $poly1: $v:\t[$v getp coord]\t[$v getp is_intersection]\t[$v getp entry]"
}
puts "==== poly2 entry/exit  ===="
foreach v [$poly2 get_vertices] {
    puts "INTERSECTION: $poly2: $v:\t[$v getp coord]\t[$v getp is_intersection]\t[$v getp entry]"
}


#############################
# Clip2 - mark entry/exits
#############################

puts ""
puts "Entries/exits"
set polycoords1 {100 100 100 200 200 200 200 100}
set polycoords2 {80 100 80 200 200 200 200 100}

set polycoords3 {}
foreach {x y} $polycoords1 {
    lappend polycoords3 [expr $x + 0]
    lappend polycoords3 [expr $y + 0]
}
set polycoords4 {}
foreach {x y} $polycoords2 {
    lappend polycoords4 [expr $x + 0]
    lappend polycoords4 [expr $y + 0]
}


set poly1 [ghclip::polygon create $polycoords3]
set poly2 [ghclip::polygon create $polycoords4]

draw_poly .c [$poly1 get_poly] \#0000ff
draw_poly .c [$poly2 get_poly] \#ff0000 +

# Set intersections
ghclip::create_intersections $poly1 $poly2

puts "==== poly1 intersection ===="
foreach v [$poly1 get_vertices] {
    puts "INTERSECTION: $poly1: $v:\t[$v getp coord]\t[$v getp is_intersection]\t[$v getp entry]"
}
puts "==== poly2 intersection ===="
foreach v [$poly2 get_vertices] {
    puts "INTERSECTION: $poly2: $v:\t[$v getp coord]\t[$v getp is_intersection]\t[$v getp entry]"
}


# Re-use poly1/2 from above
set rpolies [ghclip::clip $poly1 $poly2]

foreach poly $rpolies {
    .c create polygon {*}$poly -fill \#cccc00 -outline {}
}

puts "==== poly1 entry/exit  ===="
foreach v [$poly1 get_vertices] {
    puts "INTERSECTION: $poly1: $v:\t[$v getp coord]\t[$v getp is_intersection]\t[$v getp entry]"
}
puts "==== poly2 entry/exit  ===="
foreach v [$poly2 get_vertices] {
    puts "INTERSECTION: $poly2: $v:\t[$v getp coord]\t[$v getp is_intersection]\t[$v getp entry]"
}

#############################
# Clip2 - mark entry/exits
#############################
if {0} {
puts ""
puts "Entries/exits"
set polycoords1 {100 100 100 300 200 300 200 200 300 200 300 100}
set polycoords2 {80 100 80 200 220 200 220 100}

set polycoords3 {}
foreach {x y} $polycoords1 {
    lappend polycoords3 [expr $x + 0]
    lappend polycoords3 [expr $y + 0]
}
set polycoords4 {}
foreach {x y} $polycoords2 {
    lappend polycoords4 [expr $x + 0]
    lappend polycoords4 [expr $y + 0]
}


set poly1 [ghclip::polygon create $polycoords3]
set poly2 [ghclip::polygon create $polycoords4]

draw_poly .c [$poly1 get_poly] \#0000ff
draw_poly .c [$poly2 get_poly] \#ff0000 +

# Set intersections
ghclip::create_intersections $poly1 $poly2

puts "==== poly1 intersection ===="
foreach v [$poly1 get_vertices] {
    puts "INTERSECTION: $poly1: $v:\t[$v getp coord]\t[$v getp is_intersection]\t[$v getp entry]"
}
puts "==== poly2 intersection ===="
foreach v [$poly2 get_vertices] {
    puts "INTERSECTION: $poly2: $v:\t[$v getp coord]\t[$v getp is_intersection]\t[$v getp entry]"
}


# Re-use poly1/2 from above
set rpolies [ghclip::clip $poly1 $poly2]

foreach poly $rpolies {
    .c create polygon {*}$poly -fill \#cccc00 -outline {}
}

puts "==== poly1 entry/exit  ===="
foreach v [$poly1 get_vertices] {
    puts "INTERSECTION: $poly1: $v:\t[$v getp coord]\t[$v getp is_intersection]\t[$v getp entry]"
}
puts "==== poly2 entry/exit  ===="
foreach v [$poly2 get_vertices] {
    puts "INTERSECTION: $poly2: $v:\t[$v getp coord]\t[$v getp is_intersection]\t[$v getp entry]"
}
}
#############################
# Clip3 - box and diamond
#############################
set polycoords1 {100 300 100 350 150 350 150 300}
set polycoords2 {90  325 125 360 160 325 125 290}

set poly1 [ghclip::polygon create $polycoords1]
set poly2 [ghclip::polygon create $polycoords2]

draw_poly .c [$poly1 get_poly] \#0000ff - 0
draw_poly .c [$poly2 get_poly] \#ff0000 + 0

# Set intersections
ghclip::create_intersections $poly1 $poly2

# Re-use poly1/2 from above
set rpolies [ghclip::clip $poly1 $poly2]

foreach poly $rpolies {
    .c create polygon {*}$poly -fill \#cccc00 -outline {}
}

#############################
# Clip4 - self-intersection
#############################
set polycoords1 {300 100 500 100 500 250 400 250 400 150 450 150 450 200 375 200 375 150 325 150 325 200}
set polycoords1 {300 100 500 100 500 250 400 250 400 150 350 150 350 200 450 200 450 225 425 225 300 225}

set polycoords1 {300 100 500 100 500 250 400 250 400 150 450 150 450 200 300 200}
set polycoords2 {280 120 520 120 520 240 280 240}
set polycoords1 {300 300 500 300 500 150 350 150 350 200 450 200 450 250 400 250 400 100 300 100}

set poly1 [ghclip::polygon create $polycoords1]
set poly2 [ghclip::polygon create $polycoords2]

draw_poly .c [$poly1 get_poly] \#0000ff - 0
draw_poly .c [$poly2 get_poly] \#ff0000 + 0

# Set intersections
ghclip::create_intersections $poly1 $poly2

# Re-use poly1/2 from above
set rpolies [ghclip::clip $poly1 $poly2]

foreach poly $rpolies {
    .c create polygon {*}$poly -fill \#cccc00 -outline {}
}
