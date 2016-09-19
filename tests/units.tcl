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
