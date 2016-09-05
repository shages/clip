
package provide clip::polygon 1.0

namespace eval clip::polygon {
    namespace export create

    variable counter 0

    namespace ensemble create
}

proc clip::polygon::create {poly} {
    variable counter
    set name P_${counter}

    namespace eval $name {
        namespace export create
        #namespace export set_poly
        namespace export get_poly
        namespace export get_start
        # "Starting" vertex of the polygon
        variable start_vertex

        proc get_start {} {
            variable start_vertex
            return $start_vertex
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
                    set new [clip::vertex::create $x $y $prev]
                    $prev set_next $new
                } else {
                    set new [clip::vertex::create $x $y]
                    set start_vertex $new
                }
                set prev $new
                incr count
            }
            # Fix startpoint/endpoint
            # Need to check these aren't the same point first
            $start_vertex set_prev $new
            $new set_next $start_vertex
        }

        # Returns even-number list of coordinates in this polygon
        proc get_poly {} {
            variable start_vertex
            set poly {}
            lappend poly {*}[$start_vertex getc]
            set current [$start_vertex get_next]
            while {$current ne $start_vertex} {
                lappend poly {*}[$current getc]
                set current [$current get_next]
            }
            return $poly
        }

        namespace ensemble create
    }

    $name create $poly

    incr counter
    set full_name "clip::polygon::$name"
    return $full_name
}


