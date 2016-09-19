#!/usr/bin/env tclsh

lappend auto_path [file normalize [file join [pwd] ..]]
package require ghclip

source ./testutils.tcl

_init

# lshift
_suite "lshift" {
  {
    set var {}
    catch {[ghclip::lshift var]} msg err
    _assert_eq [dict get $err -errorstack INNER returnStk] Empty
  }
  {
    set var {0}
    _assert_eq [ghclip::lshift var] 0
    _assert_eq $var {}
  }
  {
    set var {0 1 2}
    _assert_eq [ghclip::lshift var] 0
    _assert_eq $var {1 2}
  }
}

# Example assertion error
#_suite "lshift2" {
#  {
#    set var {0 0}
#    lshift var
#    _assert_eq $var {0 0}
#  }
#}

# elaborate_expression
_suite "elaborate_expression" {
  {
    _assert_eq [elaborate_expression {A AND B}] {A AND B}
  }
  {
    _assert_eq [elaborate_expression {A XOR B}] {A XOR B}
  }
  {
    _assert_eq [elaborate_expression {A OR B}] {A OR B}
  }
  {
    _assert_eq [elaborate_expression {A OR B AND C XOR A}] {A OR B AND C XOR A}
  }
  {
    _assert_eq [elaborate_expression {A ANDNOT B}] {A XOR B AND A}
  }
  {
    # Wrong expectation
    # Should be:
    # (A OR B) XOR C AND (A OR B)
    _assert_eq [elaborate_expression {A OR B ANDNOT C}] {A OR B XOR C AND B}
  }
}
#_suite [elaborate {A ANDNOT B}] == {A XOR B AND A}
#_suite [elaborate {A XOR B ANDNOT C}] == {A XOR B XOR C AND {A XOR B}}

_summarize
