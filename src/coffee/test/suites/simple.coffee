"use strict"

_ = require 'lodash'
must = require 'must'

butt = {
    smell: 'gross'
}

module.exports = (->
    describe "your butt", ->
        describe "the smell", ->
            it "should be all gross", ->
                butt.must.be.truthy()
                butt.smell.must.equal 'gross'
)()