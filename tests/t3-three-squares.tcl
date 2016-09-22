#!/usr/bin/env tclsh

package require Tk

lappend auto_path [file normalize [file join [pwd] ..]]
package require ghclip

source ./testutils.tcl

set poly1 {50 50 50 100 100 100 100 50}
set poly2 {60 60 60 110 110 110 110 60}
set poly3 {70 70 70 120 120 120 120 70}

#_clip_test             row   col     A       B      C      Clip
_clip_test 0 0 {}           [list $poly1 $poly2 $poly3]

_clip_test 0 1 {OR OR}      [list $poly1 $poly2 $poly3]
_clip_test 0 2 {OR AND}     [list $poly1 $poly2 $poly3]
_clip_test 0 3 {OR XOR}     [list $poly1 $poly2 $poly3]
_clip_test 0 4 {OR ANDNOT}  [list $poly1 $poly2 $poly3]

_clip_test 1 1 {AND OR}      [list $poly1 $poly2 $poly3]
_clip_test 1 2 {AND AND}     [list $poly1 $poly2 $poly3]
_clip_test 1 3 {AND XOR}     [list $poly1 $poly2 $poly3]
_clip_test 1 4 {AND ANDNOT}  [list $poly1 $poly2 $poly3]

_clip_test 2 1 {XOR OR}      [list $poly1 $poly2 $poly3]
_clip_test 2 2 {XOR AND}     [list $poly1 $poly2 $poly3]
_clip_test 2 3 {XOR XOR}     [list $poly1 $poly2 $poly3]
_clip_test 2 4 {XOR ANDNOT}  [list $poly1 $poly2 $poly3]

_clip_test 3 1 {ANDNOT OR}      [list $poly1 $poly2 $poly3]
_clip_test 3 2 {ANDNOT AND}     [list $poly1 $poly2 $poly3]
_clip_test 3 3 {ANDNOT XOR}     [list $poly1 $poly2 $poly3]
_clip_test 3 4 {ANDNOT ANDNOT}  [list $poly1 $poly2 $poly3]

