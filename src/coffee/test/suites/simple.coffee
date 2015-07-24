"use strict"

_ = require 'lodash'
must = require 'must'

$ = {
    mock: true
}

whoCares = ->
    $.mock.must.be.truthy()

###
@namespace raconteur
@examples
    @invocation
        @coffee !!!
            telepath = require('raconteur').telepath
            @compile
    @chain
        @coffee !!!
            chain = telepath.chain()
            @compile
    @$raw$html$json$callback
        @coffee !!!
            templateContent = """
            <section>
                <header>
                    <h1>{model.attributes.title}</h1>
                </header>
                <div class="summary">
                    <p>{model.content|s}</p>
                </div>
            </section>
            """
            postContent = """
            {{{
                title: "news"
            }}}
            Summary of the *strongly* _emphasized_ news.
            """
            chain = telepath.chain()
                            .raw()
                            .post postContent
                            .template "templateName", templateContent
                            .ready (e, out)->
                                console.log "1: ", (e is null) // prints: true
                                console.log "2: ", out.length // prints: 1
                                console.log "3: ", out[0] // prints the converted template, populated with the raw content.
@object Telepath
    @example
        @coffee !!!
            @!!! invocation.coffee
        @js !!!
            @!!! invocation.js
    @description A utility for tying together both the `raconteur-scribe` and `raconteur-crier` modules.
###
describe "Telepath", ->
    ###
    @object Telepath:chain
        @description The root method for generating an object with a fluent-API which is then invoked using the .ready() method
        @method true
        @example
            @coffee !!!
                @!!! chain.coffee
    ###
    describe ".chain()", ()->
        ###
        @object Telepath:chain:assertions:sanity:methods
            @test sanity
        ###
        it "should have all of the methods available to the chain object", ()->
            whoCares()
        ###
        @object Telepath:chain:assertions:sanity:factory
            @test sanity
        ###
        it "should generate chains via a factory function", ()->
            whoCares()
        ###
        @object Telepath:chain:raw
            @description Converts the expected input to the `raw` input, so raw string input is expected instead of filepaths.
            @example
                @coffee !!!
                    @!!! $raw$html$json$callback.coffee
            @method true
        ###
        describe ".raw()", ()->
            it "should set the raw state to true", ()->
                whoCares()
        describe ".sugar()", ()->
            it "should set the sugar state to true", ()->
                whoCares()
        describe ".promise()", ()->
            it "should set the promise state to true", ()->
                whoCares()
