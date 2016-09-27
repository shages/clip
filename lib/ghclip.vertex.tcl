
package provide ghclip::vertex 1.0

namespace eval ghclip::vertex {
    namespace export create

    namespace ensemble create

    variable counter 0
}


proc ghclip::vertex::create {{coord {0 0}} {prev null} {next null}} {
    # Create new vertex as a namespace with ensemle sub commands
    # Namespaces are tracked with $ghclip::vertex::counter
    #
    # Sub commands:
    #   set -- x y
    #     Sets the coord for the vertex. Defaults to (0, 0) if not specified.
    #   get
    #     Returns the coordinate as a 2-item list

    variable counter

    set name V_${counter}
    namespace eval $name {
        namespace export init
        namespace export setp
        namespace export getp
        namespace ensemble create

        variable coord {0 0}
        variable next "null"
        variable prev "null"
        variable neighbor "null"
        variable is_intersection 0
        # entry = 0, exit = 1
        variable entry -1
        variable alpha 0.0
        variable visited 0

        proc init {Coord Prev Next} {
            variable coord
            variable prev
            variable next

            set coord $Coord
            set prev $Prev
            set next $Next
        }

        proc setp {prop value} {
            # Set property value
            variable $prop
            if {[info exists $prop]} {
                return [set $prop $value]
            } else {
                puts "ERROR: Property $prop doesn't exist yet. Can't set"
            }
        }

        proc getp {prop} {
            # Get property value
            variable $prop
            return [set $prop]
        }
    }

    $name init $coord $prev $next

    incr counter
    return "::ghclip::vertex::$name"
}
