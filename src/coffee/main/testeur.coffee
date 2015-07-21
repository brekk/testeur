"use strict"

fs = require 'graceful-fs'
_ = require 'lodash'

Testeur = (runner)->

    jsonify = ->
        return _.map _.toArray arguments, (arg)->
            return JSON.stringify arg, null, 4
    data = {
        raw: jsonify runner
        total: {
            tests: runner.total
            passes: 0
            fails: 0 # could this always be derived from `.passes` (above)?
        }

    }
    # loosely based on the mocha-matrix reporter (for now)
    # https://github.com/tj/mocha-matrix/blob/master/index.js
    runner.on 'pass', (test)->
        console.log "SUCCESS"
        data.total.passes++
        console.log jsonify test

    runner.on 'fail', (test, err)->
        console.log "FAILURE!"
        data.total.fails++
        console.log exports
        if err.stack?
            console.log err.stack
        console.log jsonify test


module.exports = Testeur