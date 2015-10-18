assert        = require 'assert'
thru          = require 'through2'
buildCapturer = require '../../lib'

noMatchString = 'some non-matching text which gets ignored'
noMatchRegex = /nomatch/

wordsString = 'one two three'
wordsRegex  = /^(\w+)\s+(\w+)\s+(\w+)$/

numsString = '-1.23 +81742.2153 7028261.3'
numsRegex  = /^([+-]?\d+(?:\.\d*)*)\s+([+-]?\d+(?:\.\d*)*)\s+([+-]?\d+(?:\.\d*)*)$/

describe 'test non-matched value', ->

  describe 'with ignore=true', ->

    it 'should finish without pushing anything', (done) ->
      pushed = []
      target = thru.obj (result, _, next) -> pushed.push result ; next()
      target.on 'finish', ->
        assert.equal pushed.length, 0, 'pushed array should be empty'
        done()
      capturer = buildCapturer [noMatchRegex], ignore:true # explicit
      capturer.pipe target
      capturer.end noMatchString

  describe 'with ignore=false', ->

    it 'should finish after pushing the string as `unknown`', ->
      pushed = []
      target = thru.obj (result, _, next) -> pushed.push result ; next()
      target.on 'finish', ->
        assert.equal pushed.length, 1, 'pushed array should contain single unknown result'
        assert.equal pushed[0].unknown, noMatchString, 'unknown property should equal input string'
        done()
      capturer = buildCapturer [noMatchRegex], ignore:false # explicit
      capturer.pipe target
      capturer.end noMatchString


describe 'test both matching and non-matching values', ->

  describe 'with ignore=true', ->

    it 'should finish after pushing matched parts', (done) ->
      pushed = []
      target = thru.obj (result, _, next) -> pushed.push result ; next()
      target.on 'finish', ->
        assert.equal pushed.length, 2, 'pushed array should contain both matchable captures'
        # match words
        assert.equal pushed[0].capture[1], 'one'
        assert.equal pushed[0].capture[2], 'two'
        assert.equal pushed[0].capture[3], 'three'
        # match nums
        assert.equal pushed[1].capture[1], -1.23
        assert.equal pushed[1].capture[2], 81742.2153
        assert.equal pushed[1].capture[3], 7028261.3
        # all done with test
        done()
      capturer = buildCapturer
        ignore:true # explicit
        array: [ wordsRegex, numsRegex, noMatchRegex ]
      capturer.pipe target
      capturer.write wordsString
      capturer.write noMatchString
      capturer.end numsString

  describe 'with ignore=false', ->

    it 'should finish after pushing the string as `unknown`', ->
      pushed = []
      target = thru.obj (result, _, next) -> pushed.push result ; next()
      target.on 'finish', ->
        assert.equal pushed.length, 3, 'pushed array should contain both matchable and unmatchable captures'
        # match words
        assert.equal pushed[0].capture[1], 'one'
        assert.equal pushed[0].capture[2], 'two'
        assert.equal pushed[0].capture[3], 'three'
        # match the `unknown` result
        assert.equal pushed[1].capture.unknown, noMatchString
        # match nums
        assert.equal pushed[2].capture[1], -1.23
        assert.equal pushed[2].capture[2], 81742.2153
        assert.equal pushed[2].capture[3], 7028261.3
        # all done with test
        done()
      capturer = buildCapturer
        ignore:true # explicit
        array: [ wordsRegex, numsRegex, noMatchRegex ]
      capturer.pipe target
      capturer.write wordsString
      capturer.write noMatchString
      capturer.end numsString
