# transform which runs each regular expression's exec() on part until it matches
# then passes on the capture result as an object
class Capturer extends require('stream').Transform

  constructor: (regexes, options) ->
    # if we only receive an options object, then `regexes` won't be an array
    unless Array.isArray regexes
      # get array from options, which is the first argument
      options = regexes
      regexes = options.array
    else options ?= {} # ensure we have an options object

    # ensure we're in object mode
    options.objectMode = true

    # pass to super constructor
    super options

    # hold onto regular expressions we test for
    @regexes = regexes

    # default to ignoring unmatched parts
    @ignore = options?.ignore ? true

  _transform: (input, encoding, next) ->
    if 'string' is typeof input then string = input
    else if Buffer.isBuffer input then string = input.toString 'utf8'
    else if input.string? then string = input.string

    # run each regex's exec() until a match is found, or there are no more
    for regex in @regexes
      match = regex.exec string

      # TODO: check if global, if so, rerun and build a series of results

      # if a match is found then return from calling next() with result
      if match? then return next null, capture:match#, id:regex.id # TODO: put id on regex's ??

    # if we aren't ignoring non-matches then push it
    unless @ignore then @push unknown:string

    next() # all done

# export a builder function
module.exports = (regexes, options) -> new Capturer regexes, options
module.exports.Capturer = Capturer
