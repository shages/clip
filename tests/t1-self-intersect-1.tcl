#!/usr/bin/env tclsh

package require Tk

lappend auto_path [file normalize [file join [pwd] ..]]
package require ghclip

source ./testutils.tcl

set poly1 {
   50 150
  150 150
  150  75
   75  75
   75 100
  125 100
  125 125
  100 125
  100  50
   50  50
}
set poly2 {
   40  60
  160  60
  160 120
   40 120
}

_clip_test 0 0 {}       [list $poly1 $poly2]
_clip_test 0 1 {OR}     [list $poly1 $poly2]
_clip_test 0 2 {AND}    [list $poly1 $poly2]
_clip_test 0 3 {XOR}    [list $poly1 $poly2]
_clip_test 0 4 {NOT} [list $poly1 $poly2]

