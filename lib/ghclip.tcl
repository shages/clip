
package provide ghclip 1.0
package require ghclip::vertex
package require ghclip::polygon

namespace eval ghclip {
    namespace export intersect
    namespace export create_intersections
    namespace export clip
    namespace export create_clip
    namespace export clip_exp
}

# Algorithm taken from:
# http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
proc ghclip::intersect {s c} {
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
    #puts "DEBUG: rxs: $rxs"

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
    #puts "DEBUG: t: $t"

    # u = (q - p) x r / (r x s)
    # q = c1, p = s1, r = (s2 - s1)
    #
    #   q-p         r
    # [ (c1x - s1x) (s2x - s1x) ]
    # [ (c1y - s1y) (s2y - s1y) ]
    set u [expr {(($c1x - $s1x)*($s2y - $s1y) - ($c1y - $s1y)*($s2x - $s1x)) / $rxs}]
    #puts "DEBUG: u: $u"

    # Check if lines intersect
    if {![expr {(0.0 <= $t) && ($t <= 1.0) && (0.0 <= $u) && ($u <= 1.0)}]} {
        #puts "DEBUG: Lines don't intersect"
        return
    }

    # p + tr
    return [list [list \
    [expr {$s1x + $t*($s2x - $s1x)}] \
    [expr {$s1y + $t*($s2y - $s1y)}] \
    ] [list $t $u]]
}

proc ghclip::create_intersections {poly1 poly2} {
    set start1 [$poly1 get_start]
    set prev1 $start1
    set current1 [$start1 get_next]
    set dof1 1
    while {$dof1 || $prev1 ne $start1} {
        set line1 [list $prev1 $current1]

        if {[$prev1 get_is_intersection] == 0} {
            set start2 [$poly2 get_start]
            set prev2 $start2
            set current2 [$start2 get_next]
            set dof2 1
            while {$dof2 || $prev2 ne $start2} {
                if {[$prev2 get_is_intersection] == 0} {
                    set line2 [list $prev2 [get_next_non_intersection $prev2]]
                    # Check lines for intersection
                    set inters [ghclip::intersect \
                    [list {*}[[lindex $line1 0] getc] {*}[[lindex $line1 1] getc]] \
                    [list {*}[[lindex $line2 0] getc] {*}[[lindex $line2 1] getc]] \
                    ]
                    if {$inters ne ""} {
                        #puts "DEBUG: FOUND INTERSECTION at: $inters"
                        # insert them
                        set new1 [ghclip::vertex::insert_between {*}[lindex $inters 0] [lindex $inters 1 0] $prev1 [get_next_non_intersection $prev1]]
                        set new2 [ghclip::vertex::insert_between {*}[lindex $inters 0] [lindex $inters 1 1] $prev2 [get_next_non_intersection $prev2]]
                        # Set neighbors
                        $new1 set_neighbor $new2
                        $new2 set_neighbor $new1
                        # Set intersection
                        $new1 set_is_intersection 1
                        $new2 set_is_intersection 1
                    }
                }
                set prev2 $current2
                set current2 [$current2 get_next]
                set dof2 0
            }
        }

        set prev1 $current1
        set current1 [$current1 get_next]
        set dof1 0
    }
}

proc ghclip::clip {p1 p2 {dir 0}} {
    # (Phase 0) - create polygon objects
    set poly1 [polygon create $p1]
    set poly2 [polygon create $p2]

    # Phase 1 - create intersections
    create_intersections $poly1 $poly2

    # Phase 2

    # Mark entries/exits
    # start at the startpoint and figure out if you're inside or outside
    # poly1
    set start [$poly1 get_start]
    if {[$poly2 encloses {*}[$start getc]] != 0} {
        # inside -> next intersection will be exit
        set entry 1
    } else {
        # outside
        set entry 0
    }
    set current [$start get_next]
    # skip first since it can't be an intersection?
    while {$current ne $start} {
        if {[$current get_is_intersection]} {
            # if an intersection point, record entry/exit
            $current set_entry $entry
            set entry [expr {$entry ? 0 : 1}] ; #toggle
        }
        set current [$current get_next]
    }
    # poly2
    set start [$poly2 get_start]
    if {[$poly1 encloses {*}[$start getc]] != 0} {
        # inside -> next intersection will be exit
        set entry 1
    } else {
        # outside
        set entry 0
    }
    set current [$start get_next]
    # skip first since it can't be an intersection?
    while {$current ne $start} {
        if {[$current get_is_intersection]} {
            # if an intersection point, record entry/exit
            $current set_entry $entry
            set entry [expr {$entry ? 0 : 1}] ; #toggle
        }
        set current [$current get_next]
    }

    # Phase 3
    # Get initial set of all unvisited intersection vertices
    set unvisited {}
    set curr [$poly1 get_start]
    set start $curr
    set do 1
    while {$do || $curr ne $start} {
        if {[$curr get_is_intersection]} {
            lappend unvisited $curr
        }
        set curr [$curr get_next]
        set do 0
    }
    set curr [$poly2 get_start]
    set start $curr
    set do 1
    while {$do || $curr ne $start} {
        if {[$curr get_is_intersection]} {
            lappend unvisited $curr
        }
        set curr [$curr get_next]
        set do 0
    }

    set polies {}
    set inpoly 0
    while {[llength $unvisited]} {
        # Start traversing first unvisited intersection in poly1
        set v [$poly1 get_unvisited_intersection]
        set poly {}
        lappend poly [ghclip::vertex::create {*}[$v getc]]
        set do 1
        #puts "DEBUG: Starting new poly on $v"
        #puts "DEBUG: Unvisited: $unvisited"
        while {$do || [set ${v}::visited] == 0} {
            # mark this and its neighbor as visited
            set ${v}::visited 1
            set [$v get_neighbor]::visited 1
            set unvisited [lreplace $unvisited [lsearch $unvisited $v] [lsearch $unvisited $v]]
            #puts "DEBUG: Unvisited: $unvisited"

            if {[set ${v}::entry] == $dir || $dir == 2} {
                # Go forward to next intersection
                set do1 1
                while {$do1 || [$v get_is_intersection] == 0} {
                    set v [$v get_next]
                    #puts "DEBUG: Looping forward: $v -> [$v get_next]"
                    set unvisited [lreplace $unvisited [lsearch $unvisited $v] [lsearch $unvisited $v]]
                    lappend poly [ghclip::vertex::create {*}[$v getc]]
                    set do1 0
                }
            } else {
                # Go backward to next intersection
                set do1 1
                while {$do1 || [$v get_is_intersection] == 0} {
                    #puts "DEBUG: Looping backward: $v -> [$v get_prev]"
                    set v [$v get_prev]
                    set unvisited [lreplace $unvisited [lsearch $unvisited $v] [lsearch $unvisited $v]]
                    lappend poly [ghclip::vertex::create {*}[$v getc]]
                    set do1 0
                }
            }
            # swap
            set v [$v get_neighbor]
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
            lappend rpoly {*}[$v getc]
        }
        lappend rpolies $rpoly
    }
    #puts "DEBUG: Returning: $rpolies"
    return $rpolies
}

proc ghclip::get_next_non_intersection {v} {
    set curr $v
    while {[[set curr [$curr get_next]] get_is_intersection] == 1} {
        if {$curr == $v} {
            puts "ERROR: This should never happen"
            break
        }
    }
    return $curr
}

# Returns first item in a list and removes it from the list
proc ghclip::lshift {listVar} {
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

# Translates and executes the desired operation
proc ghclip::create_clip2 {op p1 p2} {
  puts "DEBUG: OP: $op"
  switch -exact -- $op {
    AND     {return [clip $p1 $p2 0]}
    OR      {return [clip $p1 $p2 1]}
    XOR     {return [clip $p1 $p2 2]}
    ANDNOT  {return [create_clip AND [create_clip XOR $p1 $p2] $p2]}
    default {
      error "Invalid operator in the expression:\n  $p1\n  $op\n  $p2"
    }
  }
}

proc ghclip::create_clip {op p1 p2} {
  set p1l [llength [lindex $p1 0]]
  set p2l [llength [lindex $p2 0]]
  set polylist {}
  if {$p1l > 1 && $p2l > 1} {
    # Both inputs are multi-polies
    foreach poly1 $p1 {
      foreach poly2 $p2 {
        lappend polylist {*}[create_clip2 $op $poly1 $poly2]
      }
    }
  } elseif {$p1l > 1} {
    foreach poly1 $p1 {
      lappend polylist {*}[create_clip2 $op $poly1 $p2]
    }
  } elseif {$p2l > 1} {
    foreach poly1 $p1 {
      lappend polylist {*}[create_clip2 $op $poly1 $p2]
    }
  } else {
    set polylist [create_clip2 $op $p1 $p2]
  }
  return $polylist
}

proc ghclip::clip_exp {args} {
  # Check args length
  if {[expr {([llength $args] - 1) % 2}] != 0} {
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
    set op1 [create_clip $operator $op1 $op2]
  }
  return $op1
}
