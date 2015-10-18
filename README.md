# each-part-capture
[![Build Status](https://travis-ci.org/elidoran/node-each-part-capture.svg?branch=master)](https://travis-ci.org/elidoran/node-each-part-capture)
[![Dependency Status](https://gemnasium.com/elidoran/node-each-part-capture.png)](https://gemnasium.com/elidoran/node-each-part-capture)
[![npm version](https://badge.fury.io/js/each-part-capture.svg)](http://badge.fury.io/js/each-part-capture)

Transform uses array of regex's to run exec() on each part and pass on capture results to next stream.

## Install

```sh
npm install each-part-capture --save
```

## Usage: Simplified


```coffeescript
# get builder function
buildCapturer = require 'each-part-capture'

# build capturer transform with array of regular expressions
capturer = buildCapturer [ /(\w+)=(\d+)/ ]

# write a string which will match the regular expression
capturer.write 'num=12345'

# capturer will push an object, `result` to the next stream with
# the `capture` property containing the regex.exec(string) result:
result =
  capture:
  # capture[1] = 'num'
  # capture[2] = 12345

# write a string which does *NOT* match any of the regex's
capturer.write 'wont match any pattern'
# *nothing* is pushed to the next stream. non-matching strings are *ignored*
# by default. override this via the `ignore` option at creation time:
nonIgnoringCapturer = buildCapturer [/some regex/], ignore:false
# this capturer will provide unmatchable strings in a `unknown` property on `result`
result =
  unknown: 'wont match any pattern'
```

## Usage: Stream Pipeline


```coffeescript
# get the each-part module to breakup the parts
buildEacher = require 'each-part'
# make an eacher transform
eacher = buildEacher()

# get this module
buildCapturer = require 'each-part-capture'

# get module to enhance regex's exec() to use names for the capture groups
buildNameCapture = require 'regex-named-groups'

# build a capturer transform with an array of regular expressions which are
# enhanced to use capture group names
capturer = buildCapturer [
  # three words separated by spaces
  buildNameCapture /^(\w+)\s+(\w+)\s+(\w+)$/, ['first', 'second', 'third']
  # three numbers separated by spaces
  buildNameCapture /^([+-]?\d+(?:\.\d*)*)\s+([+-]?\d+(?:\.\d*)*)\s+([+-]?\d+(?:\.\d*)*)$/,
    ['d1', 'd2', 'd3']
]

# test strings to write thru transforms:
words = 'one two three'
nums = '-1.23 +81742.2153 7028261.3'
nomatch = 'some non-matching text which gets ignored'
testString = words + '\n' + nomatch + '\n' + nums

# create a target stream, as a sample, to receive the capture results
target = thru.obj (result, _, next) ->
  # first result is the words capture:
  result.capture.first  = 'one'
  result.capture.second = 'two'
  result.capture.third  = 'three'

  # NOTE: the 'nomatch' string is ignored because it didn't match any regex

  # second result (next time this function is called) is the nums.
  result.capture.d1 = -1.23
  result.capture.d2 = 81742.2153
  result.capture.d3 = 7028261.3

# pipe them together
eacher.pipe(capturer).pipe(target)

# write our test string to the pipeline
eacher.end testString

```

## MIT License
