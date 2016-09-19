
proc _init {} {
  namespace eval ___test {
    variable total_tests
    variable total_errors
    variable msg
    variable err
  }
}

proc _summarize {} {
  puts "######################"
  if {$___test::total_errors} {
    puts "## ERRORS"
  } else {
    puts "## PASS"
  }

  set pass_rate [expr {100 - 100.0*$___test::total_errors/$___test::total_tests}]
  puts "######################"
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
