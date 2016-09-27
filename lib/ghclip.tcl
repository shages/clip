
package provide ghclip 1.0
package require ghclip::vertex
package require ghclip::polygon

namespace eval ghclip {
    namespace export ghclip
    namespace export clip
}

proc ghclip::intersect {s c} {
    # Calculate intersection point of two line segments
    #
    # Algorithm taken from:
    # http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
    #
    # Args
    # s - subject line
    # c - clipping line
    #
    # Returns the point of intersection if the lines intersect
    # Returns nothing if the lines are parallel

    set s1x [lindex $s 0]
    set s1y [lindex $s 1]
    set s2x [lindex $s 2]
    set s2y [lindex $s 3]

    set c1x [lindex $c 0]
    set c1y [lindex $c 1]
    set c2x [lindex $c 2]
    set c2y [lindex $c 3]

    # r x s
    #   r           s
    # [ (s2x - s1x) (c2x - c1x) ]
    # [ (s2y - s1y) (c2y - c1y) ]
    set rxs [expr {1.0*($s2x - $s1x)*($c2y - $c1y) - ($s2y - $s1y)*($c2x - $c1x)}]

    if {$rxs == 0} {
        # collinear or parallel - don't want to record intersection for either
        return
    }

    # t = (q - p) x s / (r x s)
    # q = c1, p = s1, s = (c2 - c1)
    #
    #   q-p         s
    # [ (c1x - s1x) (c2x - c1x) ]
    # [ (c1y - s1y) (c2y - c1y) ]
    set t [expr {(($c1x - $s1x)*($c2y - $c1y) - ($c1y - $s1y)*($c2x - $c1x)) / $rxs}]

    # u = (q - p) x r / (r x s)
    # q = c1, p = s1, r = (s2 - s1)
    #
    #   q-p         r
    # [ (c1x - s1x) (s2x - s1x) ]
    # [ (c1y - s1y) (s2y - s1y) ]
    set u [expr {(($c1x - $s1x)*($s2y - $s1y) - ($c1y - $s1y)*($s2x - $s1x)) / $rxs}]

    # Check if lines intersect
    if {!((0.0 <= $t) && ($t <= 1.0) && (0.0 <= $u) && ($u <= 1.0))} {
        return
    }

    # p + tr
    return [list [list \
    [expr {$s1x + $t*($s2x - $s1x)}] \
    [expr {$s1y + $t*($s2y - $s1y)}] \
    ] [list $t $u]]
}

proc ghclip::create_intersections {poly1 poly2} {
    # Find intersections and create them in each polygon
    #
    # Args
    # poly1 - Subject polygon
    # poly2 - Clipping polygon
    #
    # Return
    # 1 - Intersections found
    # 0 - No intersections found

    set intersections_found 0
    set start1 [$poly1 get_start]
    set prev1 $start1
    set current1 [$start1 getp next]
    set dof1 1
    while {$dof1 || $prev1 ne $start1} {
        set line1 [list $prev1 $current1]

        if {[$prev1 getp is_intersection] == 0} {
            set start2 [$poly2 get_start]
            set prev2 $start2
            set current2 [$start2 getp next]
            set dof2 1
            while {$dof2 || $prev2 ne $start2} {
                if {[$prev2 getp is_intersection] == 0} {
                    set line2 [list $prev2 [get_next_non_intersection $prev2]]
                    # Check lines for intersection
                    set inters [intersect \
                    [list {*}[[lindex $line1 0] getp coord] {*}[[lindex $line1 1] getp coord]] \
                    [list {*}[[lindex $line2 0] getp coord] {*}[[lindex $line2 1] getp coord]] \
                    ]
                    if {$inters ne ""} {
                        set intersections_found 1
                        # insert them
                        set new1 [$poly1 insert_between {*}[lindex $inters 0] [lindex $inters 1 0] $prev1 [get_next_non_intersection $prev1]]
                        set new2 [$poly2 insert_between {*}[lindex $inters 0] [lindex $inters 1 1] $prev2 [get_next_non_intersection $prev2]]
                        # Set neighbors
                        $new1 setp neighbor $new2
                        $new2 setp neighbor $new1
                        # Set intersection
                        $new1 setp is_intersection 1
                        $new2 setp is_intersection 1
                    }
                }
                set prev2 $current2
                set current2 [$current2 getp next]
                set dof2 0
            }
        }

        set prev1 $current1
        set current1 [$current1 getp next]
        set dof1 0
    }
    return $intersections_found
}

proc ghclip::ghclip {op p1 p2} {
    # Execute the Greiner-Hormann polygon clipping algorithm
    #
    # Args
    # p1 - Subject polygon
    # p2 - Clipping polygon
    # dirs - Direction to traverse for subject and clipping polygons,
    #        respectively. Determines the clipping function

    # Phase 1 - Initialize polygons and create intersections
    set poly1 [polygon create $p1]
    set poly2 [polygon create $p2]
    if {[create_intersections $poly1 $poly2] == 0} {
        # Either p1 is inside p2, p2 is inside p1, or they are disjoint
        if {[$poly1 encloses_poly $poly2]} {
            if {$op eq "AND"} {
                return [list $p2]
            } elseif {$op eq "OR"} {
                return [list $p1]
            } else {
                return [list $p1 $p2]
            }
        } elseif {[$poly2 encloses_poly $poly1]} {
            if {$op eq "AND"} {
                return [list $p1]
            } elseif {$op eq "OR"} {
                return [list $p2]
            } else {
                return [list $p2 $p1]
            }
        } else {
            if {$op eq "AND"} {
                return {}
            } elseif {$op eq "OR"} {
                return [list $p1 $p2]
            } else {
                return [list $p1]
            }
        }
    }

    # Phase 2 - Mark entry and exit points
    # Start at the startpoint and figure out if you're inside or outside poly1
    set start [$poly1 get_start]
    if {[$poly2 encloses {*}[$start getp coord]] != 0} {
        # inside -> next intersection will be exit
        set entry 1
    } else {
        # outside
        set entry 0
    }
    set current [$start getp next]
    # skip first since it can't be an intersection?
    while {$current ne $start} {
        if {[$current getp is_intersection]} {
            # if an intersection point, record entry/exit
            $current setp entry $entry
            set entry [expr {$entry ? 0 : 1}] ; #toggle
        }
        set current [$current getp next]
    }
    # poly2
    set start [$poly2 get_start]
    if {[$poly1 encloses {*}[$start getp coord]] != 0} {
        # inside -> next intersection will be exit
        set entry 1
    } else {
        # outside
        set entry 0
    }
    set current [$start getp next]
    # skip first since it can't be an intersection?
    while {$current ne $start} {
        if {[$current getp is_intersection]} {
            # if an intersection point, record entry/exit
            $current setp entry $entry
            set entry [expr {$entry ? 0 : 1}] ; #toggle
        }
        set current [$current getp next]
    }

    # Phase 3 - Create clipped polygon(s)
    # Get initial set of all unvisited intersection vertices
    set unvisited {}
    set curr [$poly1 get_start]
    set start $curr
    set do 1
    while {$do || $curr ne $start} {
        if {[$curr getp is_intersection]} {
            lappend unvisited $curr
        }
        set curr [$curr getp next]
        set do 0
    }
    set curr [$poly2 get_start]
    set start $curr
    set do 1
    while {$do || $curr ne $start} {
        if {[$curr getp is_intersection]} {
            lappend unvisited $curr
        }
        set curr [$curr getp next]
        set do 0
    }

    set dirs [get_opcode $op]
    set dindex 0
    set polies {}
    set inpoly 0
    while {[llength $unvisited]} {
        # Start traversing first unvisited intersection in poly1
        set v [$poly1 get_unvisited_intersection]
        set poly {}
        lappend poly [vertex create [$v getp coord]]
        set do 1
        while {$do || [set ${v}::visited] == 0} {
            # mark this and its neighbor as visited
            set ${v}::visited 1
            set [$v getp neighbor]::visited 1
            set unvisited [lreplace $unvisited [lsearch $unvisited $v] [lsearch $unvisited $v]]

            if {[set ${v}::entry] == [lindex $dirs $dindex]} {
                # Go forward to next intersection
                set do1 1
                while {$do1 || [$v getp is_intersection] == 0} {
                    set v [$v getp next]
                    set unvisited [lreplace $unvisited [lsearch $unvisited $v] [lsearch $unvisited $v]]
                    lappend poly [vertex create [$v getp coord]]
                    set do1 0
                }
            } else {
                # Go backward to next intersection
                set do1 1
                while {$do1 || [$v getp is_intersection] == 0} {
                    set v [$v getp prev]
                    set unvisited [lreplace $unvisited [lsearch $unvisited $v] [lsearch $unvisited $v]]
                    lappend poly [vertex create [$v getp coord]]
                    set do1 0
                }
            }
            # swap
            set v [$v getp neighbor]
            # toggle dir index
            set dindex [expr {$dindex == 1 ? 0 : 1}]
            set do 0
        }
        lappend polies $poly
    }

    # Convert polygon objects to lists
    # TODO - use polygon objects for return elements. Can reuse get_poly proc
    set rpolies {}
    foreach poly $polies {
        set rpoly {}
        foreach v $poly {
            lappend rpoly {*}[$v getp coord]
        }
        lappend rpolies $rpoly
    }
    return $rpolies
}

proc ghclip::get_next_non_intersection {v} {
    # Get the next vertex which isn't an intersection point
    #
    # Starts at the provided vertex and follows the linked list until a vertex
    # which is not an intersection is encountered
    #
    # Args
    # v - Starting vertex object
    set curr $v
    while {[[set curr [$curr getp next]] getp is_intersection] == 1} {
        if {$curr == $v} {
            puts "ERROR: This should never happen"
            break
        }
    }
    return $curr
}

proc ghclip::lshift {listVar} {
    # Remove the first item from the specified list and return its value

    upvar 1 $listVar l
    if {![info exists l]} {
        # make the error message show the real variable name
        error "can't read \"$listVar\": no such variable"
    }
    if {![llength $l]} {error Empty}
    set r [lindex $l 0]
    set l [lreplace $l [set l 0] 0]
    return $r
}

proc ghclip::get_opcode {op} {
    # Translate human readable operation into opcode for ghclip proc

    switch -exact -- [string toupper $op] {
        AND     {return {0 0}}
        OR      {return {1 1}}
        NOT     {return {1 0}}
        default {
            error "Invalid operator in the expression:\n  $p1\n  $op\n  $p2"
        }
    }
}

proc ghclip::multi_clip {op p1 p2} {
    # Handle multiple polygon list inputs and perform the specified operation
    #
    # Args
    # op - Human readable operation (AND|OR|XOR|NOT)
    # p1 - Subject polylist
    # p2 - Clip polylist

    # Convert inputs to lists of polies and then loop through all combinations
    if {[llength [lindex $p1 0]] == 1} {
        set p1 [list $p1]
    }
    if {[llength [lindex $p2 0]] == 1} {
        set p2 [list $p2]
    }

    set polylist {}
    if {$op eq "XOR"} {
        # XOR isn't distributive, so expand the function:
        # p1 = p11 OR p12 OR ... OR p1n
        # p2 = p21 OR p22 OR ... OR p2n
        # p1 XOR p2 =   p11 ANDNOT p21 ANDNOT p22 ANDNOT ... ANDNOT p2n
        #            OR p12 ANDNOT p21 ANDNOT p22 ANDNOT ... ANDNOT p2n
        #            OR ...
        #            OR p1n ANDNOT p21 ANDNOT p22 ANDNOT ... ANDNOT p2n
        #            OR p21 ANDNOT p11 ANDNOT p12 ANDNOT ... ANDNOT p1n
        #            OR p22 ANDNOT p11 ANDNOT p12 ANDNOT ... ANDNOT p1n
        #            OR ...
        #            OR p2n ANDNOT p11 ANDNOT p12 ANDNOT ... ANDNOT p1n
        foreach poly $p1 {
            set args [list $poly]
            foreach arg $p2 {
                lappend args NOT $arg
            }
            lappend polylist {*}[clip {*}$args]
        }
        foreach poly $p2 {
            set args [list $poly]
            foreach arg $p1 {
                lappend args NOT $arg
            }
            lappend polylist {*}[clip {*}$args]
        }
    } else {
        foreach poly1 $p1 {
            foreach poly2 $p2 {
                lappend polylist {*}[ghclip $op $poly1 $poly2]
            }
        }
    }
    return $polylist
}

proc ghclip::clip {args} {
    # Parse and execute poly clipping expression
    #
    # Args
    # args - Clipping expression to be parsed

    if {([llength $args] - 1) % 2 != 0} {
        error "Argument list is of wrong length"
    }

    # Evaluate expression step-by-step
    set op1 [lindex $args 0]
    set args [lrange $args 1 end]
    while {[llength $args]} {
        # shift operator and operand
        set operator [lshift args]
        set op2 [lshift args]

        # perform calculation
        set op1 [multi_clip $operator $op1 $op2]
    }
    return $op1
}
