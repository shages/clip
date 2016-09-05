
package provide ghclip 1.0
package require ghclip::vertex
package require ghclip::polygon

namespace eval ghclip {
    namespace export intersect
    namespace export create_intersections
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
    puts "DEBUG: rxs: $rxs"

    if {$rxs == 0} {
        # collinear or parallel - don't want to record intersection for either
        return
    }

    # t = (q - p) x s / (r x s)
    # q = c1, p = s1, s = (s2 - s1)
    #
    #   q-p         s
    # [ (c1x - s1x) (c2x - c1x) ]
    # [ (c1y - s1y) (c2y - c1y) ]
    set t [expr {(($c1x - $s1x)*($c2y - $c1y) - ($c1y - $s1y)*($c2x - $c1x)) / $rxs}]
    puts "DEBUG: t: $t"

    # u = (q - p) x r / (r x s)
    # q = c1, p = s1, r = (c2 - c1)
    #
    #   q-p         s
    # [ (c1x - s1x) (s2x - s1x) ]
    # [ (c1y - s1y) (s2y - s1y) ]
    set u [expr {(($c1x - $s1x)*($s2y - $s1y) - ($c1y - $s1y)*($s2x - $s1x)) / $rxs}]
    puts "DEBUG: u: $u"

    # Check if lines intersect
    if {![expr {(0.0 <= $t) && ($t <= 1.0) && (0.0 <= $u) && ($u <= 1.0)}]} {
        puts "DEBUG: Lines don't intersect"
        return
    }

    # p + tr
    return [list \
    [expr {$s1x + $t*($s2x - $s1x)}] \
    [expr {$s1y + $t*($s2y - $s1y)}] \
    ]
}

proc ghclip::create_intersections {poly1 poly2} {
    set start1 [$poly1 get_start]
    set prev1 $start1
    set current1 [$start1 get_next]
    set dof1 1
    while {$dof1 || $prev1 ne $start1} {
        set line1 [list $prev1 $current1]

        set start2 [$poly2 get_start]
        set prev2 $start2
        set current2 [$start2 get_next]
        set dof2 1
        while {$dof2 || $prev2 ne $start2} {
            set line2 [list $prev2 $current2]
            puts "DEBUG: LINE1: $line1"
            puts "DEBUG: LINE1: $line2"
            # Check lines for intersection
            set inters [ghclip::intersect \
            [list {*}[[lindex $line1 0] getc] {*}[[lindex $line1 1] getc]] \
            [list {*}[[lindex $line2 0] getc] {*}[[lindex $line2 1] getc]] \
            ]
            if {$inters ne ""} {
                puts "FOUND INTERSECTION at: $inters"
                # insert them
                set new1 [ghclip::vertex::insert_after {*}$inters $prev1]
                set new2 [ghclip::vertex::insert_after {*}$inters $prev2]
                # Set neighbors
                $new1 set_neighbor $new2
                $new2 set_neighbor $new1
                # Set intersection
                $new1 set_is_intersection 1
                $new2 set_is_intersection 1
            }
            set prev2 $current2
            set current2 [$current2 get_next]
            set dof2 0
        }

        set prev1 $current1
        set current1 [$current1 get_next]
        set dof1 0
    }
}

