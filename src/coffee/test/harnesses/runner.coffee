"use strict"
Mocha = require('mocha')
_ = require 'lodash'
testeur = require './testeur'

argv = require('minimist')(process.argv.splice 2)

module.exports = (->
    mocha = new Mocha
        reporter: testeur
    mocha.addFile argv.files
    mocha.run (fails)->
        process.on 'exit', ->
            process.exit fails
            return
        return
    return
)()