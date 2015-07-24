"use strict"

_ = require 'lodash'
codfish = require './lib/morue'

path = require 'path'

$path = path.resolve __dirname, './lib/simple.js'

j4 = ->
    if 1 is _.size arguments
        return JSON.stringify arguments[0], null, 4
    return _.each arguments, (arg)->
        return JSON.stringify arg, null, 4

c = new codfish {}
c.read($path).then (hooray)->
    console.log "it's over!", j4 hooray