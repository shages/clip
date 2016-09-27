
package provide ghclip::polygon 1.0

namespace eval ghclip::polygon {
    variable __doc__ "Parent namespace of all poly objects"

    namespace export create

    variable counter 0

    namespace ensemble create
}

proc ghclip::polygon::create {poly} {
    # Create a polygon object and return it
    #
    # Args
    # poly - list of coordinate representation of a polygon
    #
    # The polygon object is "created" by making a unique namespace within the
    # ghclip::polygon namespace. Because the namespace is unique, its data
    # is also unique. The namespace contains several methods to inspect and
    # manipulate the object

    variable counter

    set name P_${counter}
    namespace eval $name {
        variable __doc__ "Polygon object namespace"

        namespace export init
        namespace export get_poly
        namespace export get_start
        namespace export get_vertices
        namespace export encloses
        namespace export encloses_poly
        namespace export get_unvisited_intersection
        namespace export insert_between
        namespace ensemble create
        # "Starting" vertex of the polygon
        variable start_vertex

        proc get_start {} {
            # Return the starting vertex of this polygon
            variable start_vertex
            return $start_vertex
        }

        proc get_unvisited_intersection {} {
            # Get a single unvisited intersection of this polygon.
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

        proc init {poly} {
            # Initialize the vertices of this polygon

            variable start_vertex

            if {[llength $poly] % 2 != 0} {
                puts "Input poly does not have even number of values"
                return
            }

            # Unclose closed poly
            if {[lindex $poly 0] == [lindex $poly end-1] \
                && [lindex $poly 1] == [lindex $poly end]} {
                set poly [lrange $poly 0 end-2]
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
            # Tie startpoint/endpoint together
            $start_vertex setp prev $new
            $new setp next $start_vertex
        }

        proc get_poly {{vertices 0}} {
            # Return even-number list of coordinates in this polygon
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

        proc get_vertices {} {
            # Return list of vertex objects belonging to this polygon
            return [get_poly 1]
        }

        proc encloses_poly {other_poly} {
            # Check if all vertices of other_poly are enclosed by this poly.
            # Assume there are no intersections (already checked)
            #
            # Args
            # other_poly - The other polygon object to compare against

            set this [namespace qualifiers [lindex [info level 0] 0]]
            foreach vertex [$other_poly get_vertices] {
                if {[$this encloses {*}[$vertex getp coord]]} {
                    return 1
                }
            }
            return 0
        }

        proc encloses {x y} {
            # Test if point is inside this polygon
            # Based off of algorithm here:
            #   http://geomalgorithms.com/a03-_inclusion.html

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
            return [expr {abs($wn) % 2}]
        }

        proc insert_between {x y alpha first last} {
            # Insert new vertex between two vertices
            #
            # There may be other existing vertices between the specified first and
            # last vertices. They should also be intersection vertices.
            #
            # Args:
            # x         x coord
            # y         y coord
            # alpha     ratio of distance between first and last
            # first     vertex to insert after
            # last      vertex to insert before

            # Find place to insert
            set v $first
            while {$v ne $last && [set ${v}::alpha] < $alpha} {
                set v [$v getp next]
            }

            # Create new vertex, and then update adjacent vertices
            set new [ghclip::vertex::create $x $y [$v getp prev] $v]
            set ${new}::alpha $alpha
            $v setp prev $new
            [$new getp prev] setp next $new

            return $new
        }
    }

    $name init $poly

    incr counter
    return "::ghclip::polygon::$name"
}
