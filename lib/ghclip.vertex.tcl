
package provide ghclip::vertex 1.0

namespace eval ghclip::vertex {
    namespace export create
    namespace export insert_after
    namespace export insert_between

    variable counter 0 
}


proc ghclip::vertex::create {{x 0} {y 0} {prev null} {next null}} {
    # Create new vertex as a namespace with ensemle sub commands
    # Namespaces are tracked with $ghclip::vertex::counter
    # 
    # Sub commands:
    #   set -- x y
    #     Sets the coordinate for the vertex. Defaults to (0, 0) if not specified.
    #   get
    #     Returns the coordinate as a 2-item list
    variable counter

    set name V_${counter}
    puts "INFO: Creating vertex $name with coordinates: ($x, $y)"
    namespace eval $name {
        namespace export setc
        namespace export getc
        namespace export set_prev
        namespace export set_next
        namespace export get_prev
        namespace export get_next
        namespace export set_neighbor
        namespace export get_neighbor
        namespace export set_is_intersection
        namespace export get_is_intersection
        namespace export set_entry
        namespace export get_entry

        variable x 0
        variable y 0
        variable next "null"
        variable prev "null"
        variable neighbor "null"
        variable is_intersection 0
        # entry = 0, exit = 1
        variable entry -1
        variable alpha 0.0
        variable visited 0

        proc setc {X Y} {
            variable x
            variable y
            set x $X
            set y $Y
        }

        proc getc {} {
            variable x
            variable y
            return [list $x $y]
        }
        
        proc set_prev {Prev} {
            variable prev
            set prev $Prev
        }

        proc set_next {Next} {
            variable next
            set next $Next
        }

        proc get_prev {} {
            variable prev
            return $prev
        }

        proc get_next {} {
            variable next
            return $next
        }

        proc set_neighbor {Neighbor} {
            variable neighbor
            set neighbor $Neighbor
        }

        proc get_neighbor {} {
            variable neighbor
            return $neighbor
        }

        proc set_is_intersection {I} {
            variable is_intersection
            set is_intersection $I
        }

        proc get_is_intersection {} {
            variable is_intersection
            return $is_intersection
        }

        proc set_entry {Entry} {
            variable entry
            set entry $Entry
        }

        proc get_entry {} {
            variable entry
            return $entry
        }
        
        namespace ensemble create
    }

    $name setc $x $y
    $name set_prev $prev
    $name set_next $next
    incr counter
    return "::ghclip::vertex::$name"
}

# Inserts new vertex after the provided vertex
proc ghclip::vertex::insert_after {x y first} {
    set second [$first get_next]
    set new [create $x $y $first $second]
    $first set_next $new
    $second set_prev $new
    return $new
}

# first and last are non-intersection vertices, but may
# have one or more pre-existing insertion vertices between
# them
proc ghclip::vertex::insert_between {x y alpha first last} {
    puts "DEBUG: Inserting new vertex between $first and $last with alpha $alpha"
    # Find place to insert
    set v $first
    while {$v ne $last && [set ${v}::alpha] < $alpha} {
        set v [$v get_next]
    }

    puts "DEBUG: Inserting before $v ([$v get_is_intersection], [set ${v}::alpha])"

    # Create new vertex
    set new [create $x $y [$v get_prev] $v]
    set ${new}::alpha $alpha
    
    # Update adjacent vertices
    puts "DEBUG: $v get_prev (b): [$v get_prev]"
    $v set_prev $new
    puts "DEBUG: $v get_prev (a): [$v get_prev]"
    [$new get_prev] set_next $new

    puts "DEBUG: Returning new vertex: $new"
    return $new
}


