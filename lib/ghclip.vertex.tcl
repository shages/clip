
package provide ghclip::vertex 1.0

namespace eval ghclip::vertex {
    namespace export create
    namespace export insert_after

    namespace ensemble create

    variable counter 0
}


proc ghclip::vertex::create {{x 0} {y 0} {prev null} {next null}} {
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

    $name setp coord [list $x $y]
    $name setp prev $prev
    $name setp next $next
    incr counter
    return "::ghclip::vertex::$name"
}

proc ghclip::vertex::insert_after {x y first} {
    # Insert new vertex after another and update prev/next pointers
    #
    # Args
    # x         x coord
    # y         y coord
    # first     vertex to insert after

    set second [$first getp next]
    set new [create $x $y $first $second]
    $first setp next $new
    if {$second ne "null"} {
        $second setp prev $new
    }
    return $new
}
