#!/usr/bin/env tclsh

package require Tk

lappend auto_path [file normalize [file join [pwd] ..]]
package require ghclip

source ./testutils.tcl

set poly1 { 50  50  50 150 150 150 150  50}
set poly2 { 30 100 100 180 180 100 100  30}

_clip_test 0 0 {}       [list $poly1 $poly2]
_clip_test 0 1 {OR}     [list $poly1 $poly2]
_clip_test 0 2 {AND}    [list $poly1 $poly2]
_clip_test 0 3 {XOR}    [list $poly1 $poly2]
_clip_test 0 4 {NOT} [list $poly1 $poly2]

