
proc _init {} {
  namespace eval ___test {
    variable total_tests
    variable total_errors
    variable msg
    variable err
  }
}

proc _summarize {} {
    puts ""
  if {$___test::total_errors} {
    puts ".########.########..########...#######..########...######."
    puts ".##.......##.....##.##.....##.##.....##.##.....##.##....##"
    puts ".##.......##.....##.##.....##.##.....##.##.....##.##......"
    puts ".######...########..########..##.....##.########...######."
    puts ".##.......##...##...##...##...##.....##.##...##.........##"
    puts ".##.......##....##..##....##..##.....##.##....##..##....##"
    puts ".########.##.....##.##.....##..#######..##.....##..######."
  } else {
    puts ".########.....###.....######...######."
    puts ".##.....##...##.##...##....##.##....##"
    puts ".##.....##..##...##..##.......##......"
    puts ".########..##.....##..######...######."
    puts ".##........#########.......##.......##"
    puts ".##........##.....##.##....##.##....##"
    puts ".##........##.....##..######...######."
  }
  puts ""

  set pass_rate [expr {100 - 100.0*$___test::total_errors/$___test::total_tests}]
  puts "Summary:"
  puts " Total tests: $___test::total_tests"
  puts " Failed tests: $___test::total_errors"
  puts " Pass rate: [format {%.1f%%} $pass_rate]"
}

proc _suite {name tests} {
  puts "######################"
  puts "## Test: $name"
  set count 0
  set errcount 0
  foreach test $tests {
    puts "Running subtest $count..."
    if {[catch {set r [eval $test]} ___test::msg ___test::err]} {
      puts "ERROR: Exception during test: [dict get $___test::err -errorinfo]"
      incr errcount
    }
    #elseif {!$r}
    #  puts "ERROR: Incorrect result for test: $test"
    #  incr errcount
    incr count
  }

  # Record summary
  incr ___test::total_tests $count
  incr ___test::total_errors $errcount

  puts "Summary:"
  puts " Total tests: $count"
  puts " Failed tests: $errcount"
  puts " Pass rate: [format {%.1f%%} [expr {100 - 100.0*$errcount/$count}]]"
  puts ""
  return $errcount
}

proc _assert_eq {a b} {
  if {$a == $b} {
    return 0
  } else {
    puts "ERROR: Not equal:"
    puts " a: $a"
    puts " b: $b"
    error AssertionError
  }
}

proc _clip_test {row col ops polylist} {
    # create valid canvas
    while {[info command [set canv ".c[incr i]"]] ne ""} {}
    grid [canvas $canv -width 200 -height 200 -background \#ffffff]
    grid configure $canv -row $row -column $col

    # Draw polylist
    set colors {\#0000ff \#ff0000 \#00ffff \#ffff00 \#ff00ff}
    set letters {A B C D E}
    set t {A}
    lappend e [lindex $polylist 0]
    if {$ops eq ""} {
        set t "Original"
    } else {
        for {set i 0} {$i < [llength $polylist]} {incr i} {
            # Build expression
            if {$i != 0} {
                lappend t [lindex $ops [expr $i-1]] [lindex $letters $i]
                lappend e  [lindex $ops [expr $i-1]] [lindex $polylist $i]
            }
        }
    }
    # Write expression
    $canv create text 0 0 -text $t -anchor nw

    # Do clipping
    if {$t ne "Original" && [catch {set cliplist [ghclip::clip_exp {*}$e]} msg err]} {
        $canv create text 100 100 -text "ERROR" -fill \#ff0000
        puts [dict get $err -errorinfo]
        return
    }

    # Draw polylist
    for {set i 0} {$i < [llength $polylist]} {incr i} {
        $canv create polygon {*}[lindex $polylist $i] -fill {} -outline [lindex $colors $i] -width 2
        $canv create text 0 [expr ($i+1)*10] -text [lindex $letters $i] -fill [lindex $colors $i] -anchor nw
    }

    # Draw clipped polygon
    if {$t ne "Original"} {
        if {[llength $cliplist]} {
            foreach poly $cliplist {
                $canv create polygon {*}$poly -fill \#00ff00 -outline {}
            }
        }
    }
}
