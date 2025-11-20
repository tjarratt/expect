# Changelog

## v.21

### Enhancement

* variables bound with `pattern_match/1` are available for later assertions (see docs for `pattern_match/1` for more info)

## v2.0

### Enhancement

* Implementing custom matchers can be done using the `CustomMatcher` struct
* `expect/2` raises when provided incorrect arguments

### Breaking changes

* the previous tuple-based API for custom matchers is no longer supported

## v1.0

This is our first v1.0 release, and it features a breaking change from the v0.1 version.
In order to support negative assertions (eg: a value does not satisfy a matcher) we needed
to rethink the interface between the matcher and `expect`. Doing so also enabled us to implement
a fancy `pattern_match/1` matcher.

### Enhancements

* our first v1 release !
* support for asserting that a given value does not satisfy a matcher
* added `pattern_match/1` matcher that can verify a given value matches a pattern

### Breaking changes

* `expect/1` can no longer be piped to matchers
* all existing matchers have been rewritten to use a new interface with `expect/1`
