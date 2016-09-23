
package provide ghclip::polygon 1.0

namespace eval ghclip::polygon {
    namespace export create

    variable counter 0

    namespace ensemble create
}

proc ghclip::polygon::create {poly} {
    variable counter
    set name P_${counter}
    #puts "DEBUG: Creating polygon: $name"
    namespace eval $name {
        namespace export create
        #namespace export set_poly
        namespace export get_poly
        namespace export get_start
        namespace export get_vertices
        namespace export encloses
        namespace export get_unvisited_intersection
        # "Starting" vertex of the polygon
        variable start_vertex

        proc get_start {} {
            variable start_vertex
            return $start_vertex
        }

        proc get_unvisited_intersection {} {
            variable start_vertex

            if {[$start_vertex getp is_intersection] && [set ${start_vertex}::visited] == 0} {
                return $start_vertex
            } else {
                set curr [$start_vertex getp next]
                while {$curr ne $start_vertex} {
                    if {[$curr getp is_intersection] && [set ${curr}::visited] == 0} {
                        break
                    }
                    set curr [$curr getp next]
                }
            }
            return $curr
        }

        proc create {poly} {
            variable start_vertex
            if {[llength $poly] % 2 != 0} {
                puts "Input poly does not have even number of values"
                return
            }

            set count 0
            foreach {x y} $poly {
                if {$count > 0} {
                    set new [ghclip::vertex create $x $y $prev]
                    $prev setp next $new
                } else {
                    set new [ghclip::vertex create $x $y]
                    set start_vertex $new
                }
                set prev $new
                incr count
            }
            # Fix startpoint/endpoint
            # Need to check these aren't the same point first
            $start_vertex setp prev $new
            $new setp next $start_vertex
        }

        # Returns even-number list of coordinates in this polygon
        proc get_poly {{vertices 0}} {
            variable start_vertex
            set poly {}
            set polyv {}
            lappend poly {*}[$start_vertex getp coord]
            lappend polyv $start_vertex
            set current [$start_vertex getp next]
            while {$current ne $start_vertex} {
                lappend poly {*}[$current getp coord]
                lappend polyv $current
                set current [$current getp next]
            }
            if {$vertices} {
                return $polyv
            } else {
                return $poly
            }
        }

        # Returns list of vertex objects belonging to this polygon
        proc get_vertices {} {
            return [get_poly 1]
        }

        # Test if point is inside this polygon
        # Based off of algorithm here:
        #   http://geomalgorithms.com/a03-_inclusion.html
        proc encloses {x y} {
            variable start_vertex

            # is_left(): tests if a point is Left|On|Right of an infinite line.
            #    Input:  three points P0, P1, and P2
            #    Return: >0 for P2 left of the line through P0 and P1
            #            =0 for P2  on the line
            #            <0 for P2  right of the line
            proc is_left {p0 p1 p2} {
                return [expr {
                    ([lindex $p1 0] - [lindex $p0 0])*([lindex $p2 1] - [lindex $p0 1])
                    - ([lindex $p2 0] - [lindex $p0 0])*([lindex $p1 1] - [lindex $p0 1])
                }]
            }

            set wn 0                ; # winding number
            set prev $start_vertex
            set current [$prev getp next]
            set dof 1               ; # do while flag
            while {$dof || $prev ne $start_vertex} {
                set dof 0

                if {[lindex [$prev getp coord] 1] <= $y} {
                    # start lower
                    if {[lindex [$current getp coord] 1] > $y} {
                        # upward crossing
                        if {[is_left [$prev getp coord] [$current getp coord] [list $x $y]] > 0} {
                            # valid up intersect
                            incr wn
                        }
                    }
                } else {
                    # start higher
                    if {[lindex [$current getp coord] 1] <= $y} {
                        # downward crossing
                        if {[is_left [$prev getp coord] [$current getp coord] [list $x $y]] < 0} {
                            # valid down intersect
                            set wn [expr {$wn - 1}]
                        }
                    }
                }
                set prev $current
                set current [$current getp next]
            }
            return [expr {abs($wn)}]
        }

        namespace ensemble create
    }

    $name create $poly

    incr counter
    set full_name "ghclip::polygon::$name"
    return $full_name
}
