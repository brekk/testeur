"use strict"

promise = require 'bluebird'
path = require 'path'
fs = promise.promisifyAll require 'graceful-fs'
_ = require 'lodash'
debug = require('debug') "testeur"
raconteur = require 'raconteur'
json2yaml = require 'json2yaml'

Testeur = (runner)->

    jsonify = ->
        return _.map _.toArray arguments, (arg)->
            return JSON.stringify arg, null, 4
    parsify = (x)->
        return JSON.parse x
    debug "runner data", jsonify arguments
    data = {
        total: {
            tests: runner.total
            passes: 0
            fails: 0 # could this always be derived from `.passes` (above)?
        }
        suites: {}
    }
    # loosely based on the mocha-matrix reporter (for now)
    # https://github.com/tj/mocha-matrix/blob/master/index.js

    level = 0
    firstSuiteFound = false
    location = path.resolve __dirname, '../logs/last-run.md'

    runner.on 'suite', (suite)->
        ++level
        # if (suite.title? and suite.title is '') and !firstSuiteFound
        #     firstSuiteFound = true
        #     data.suites['global'] = parsify jsonify suite
        #     debug 'sweet sweet suits', suite.suites.length > 0, suite.suites
        # else
        #     data.suites[suite.title] = parsify jsonify suite
        reference = {}
        if suite.title is ''
            suite.title = 'global'
        if (suite.suites? and suite.suites.length > 0) and suite.title?
            reference.title = suite.title
            reference.suites = _.map suite.suites, (sweet)->
                return sweet.title
            data.suites[suite.title] = reference

    runner.on 'suite end', ()->
        --level

    runner.on 'pass', (test)->
        debug "SUCCESS"
        data.total.passes++
        debug "test parent?", test.parent

    runner.on 'fail', (test, err)->
        console.log "FAILURE!"
        data.total.fails++
        console.log exports
        if err.stack?
            console.log err.stack
        console.log jsonify test

    runner.on 'end', _.once ()->
        try
            debug "it's over... writing file"
            win = ()->
                debug 'Wrote file to %s', location
            lose = (e)->
                console.log "Error during writing.", e
                if e.stack?
                    console.log e.stack
            yamlData = json2yaml.stringify data
            markdown = ''
            file = "#{yamlData}\n---\n#{markdown}"
            fs.writeFileAsync(location, file, {encoding: 'utf8'}).then win
                                                                 .catch lose
        catch e
            console.log "Error during end", e
            if e.stack?
                console.log e.stack




module.exports = Testeur