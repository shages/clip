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

_suite "vertex" {
    {
        set v1 [ghclip::vertex::create 40 10]
        _assert_eq [$v1 getc] {40 10}
    }
    {
        set v1 [ghclip::vertex::create 20 30]
        _assert_eq [$v1 getc] {20 30}
    }
    {
        set v1 [ghclip::vertex::create 10.0 10.0]
        _assert_eq [$v1 getc] {10.0 10.0}
    }
    {
        set v1 [ghclip::vertex::create ]
        _assert_eq [$v1 getc] {0 0}
    }
    {
        set v1 [ghclip::vertex::create 0 0]
        _assert_eq [$v1 get_next] null
        _assert_eq [$v1 get_prev] null
        _assert_eq [$v1 get_neighbor] null
        _assert_eq [$v1 get_is_intersection] 0
        _assert_eq [$v1 get_entry] -1
    }
    {
        # Vertex insertion
        set v1 [ghclip::vertex::create 0 0]
        set v2 [ghclip::vertex::insert_after 10 10 $v1]
        _assert_eq [$v1 get_next] $v2
        _assert_eq [$v1 get_prev] null
        _assert_eq [$v2 get_prev] $v1
        _assert_eq [$v2 get_next] null
    }
    {
        # Vertex insertion in between
        set v1 [ghclip::vertex::create 0 0]
        set v2 [ghclip::vertex::insert_after 10 10 $v1]
        set v3 [ghclip::vertex::insert_between 5 5 0.5 $v1 $v2]
        _assert_eq [$v1 get_next] $v3
        _assert_eq [$v1 get_prev] null
        _assert_eq [$v2 get_prev] $v3
        _assert_eq [$v2 get_next] null
        _assert_eq [$v3 get_prev] $v1
        _assert_eq [$v3 get_next] $v2
        _assert_eq [set ${v3}::alpha] 0.5
        _assert_eq [$v3 get_is_intersection] 0
    }
}

_suite "poly" {
    {
        set poly {200 200 250 200 250 250 200 250}
        set pobj [ghclip::polygon create $poly]
        _assert_eq [$pobj get_poly] $poly
        _assert_eq [[$pobj get_start] getc] {200 200}
        _assert_eq [[[$pobj get_start] get_next] getc] {250 200}
        _assert_eq [[[$pobj get_start] get_prev] getc] {200 250}
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


## elaborate_expression - deprecated
#_suite "elaborate_expression" {
#  {
#    _assert_eq [elaborate_expression {A AND B}] {A AND B}
#  }
#  {
#    _assert_eq [elaborate_expression {A XOR B}] {A XOR B}
#  }
#  {
#    _assert_eq [elaborate_expression {A OR B}] {A OR B}
#  }
#  {
#    _assert_eq [elaborate_expression {A OR B AND C XOR A}] {A OR B AND C XOR A}
#  }
#  {
#    _assert_eq [elaborate_expression {A ANDNOT B}] {A XOR B AND A}
#  }
#}

_summarize
