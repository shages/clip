#!/usr/bin/env tclsh

set dir [file dirname [info script]]

lappend auto_path [file normalize [file join $dir ..]]
package require ghclip

source [file join $dir testutils.tcl]

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

_suite "vertex" {
    {
        set v1 [ghclip::vertex::create 40 10]
        _assert_eq [$v1 getp coord] {40 10}
    }
    {
        set v1 [ghclip::vertex::create 20 30]
        _assert_eq [$v1 getp coord] {20 30}
    }
    {
        set v1 [ghclip::vertex::create 10.0 10.0]
        _assert_eq [$v1 getp coord] {10.0 10.0}
    }
    {
        set v1 [ghclip::vertex::create ]
        _assert_eq [$v1 getp coord] {0 0}
    }
    {
        set v1 [ghclip::vertex::create 0 0]
        _assert_eq [$v1 getp next] null
        _assert_eq [$v1 getp prev] null
        _assert_eq [$v1 getp neighbor] null
        _assert_eq [$v1 getp is_intersection] 0
        _assert_eq [$v1 getp entry] -1
    }
    {
        # Vertex insertion
        set v1 [ghclip::vertex::create 0 0]
        set v2 [ghclip::vertex::insert_after 10 10 $v1]
        _assert_eq [$v1 getp next] $v2
        _assert_eq [$v1 getp prev] null
        _assert_eq [$v2 getp prev] $v1
        _assert_eq [$v2 getp next] null
    }
    {
        # Vertex insertion in between
        set v1 [ghclip::vertex::create 0 0]
        set v2 [ghclip::vertex::insert_after 10 10 $v1]
        set v3 [ghclip::vertex::insert_between 5 5 0.5 $v1 $v2]
        _assert_eq [$v1 getp next] $v3
        _assert_eq [$v1 getp prev] null
        _assert_eq [$v2 getp prev] $v3
        _assert_eq [$v2 getp next] null
        _assert_eq [$v3 getp prev] $v1
        _assert_eq [$v3 getp next] $v2
        _assert_eq [set ${v3}::alpha] 0.5
        _assert_eq [$v3 getp is_intersection] 0
    }
}

_suite "poly" {
    {
        set poly {200 200 250 200 250 250 200 250}
        set pobj [ghclip::polygon create $poly]
        _assert_eq [$pobj get_poly] $poly
        _assert_eq [[$pobj get_start] getp coord] {200 200}
        _assert_eq [[[$pobj get_start] getp next] getp coord] {250 200}
        _assert_eq [[[$pobj get_start] getp prev] getp coord] {200 250}
        _assert_eq [llength [$pobj get_vertices]] 4
    }
    {
        # winding number
        set poly {200 200 250 200 250 250 200 250}
        set pobj [ghclip::polygon create $poly]
        _assert_eq [$pobj encloses 225 225] 1
        _assert_eq [$pobj encloses 100 100] 0
    }
    {
        # winding number with self intersection
        set poly {
            100 300
            300 300
            300 150
            150 150
            150 200
            250 200
            250 250
            200 250
            200 100
            100 100
        }
        set pobj [ghclip::polygon create $poly]
        _assert_eq [$pobj encloses 0 0] 0
        _assert_eq [$pobj encloses 100 100] 1
        _assert_eq [$pobj encloses 175 175] 2
        _assert_eq [$pobj encloses 225 225] 0
    }
}

_summarize
