"use strict"

_ = require 'lodash'
cod = require 'cod'
promise = require 'bluebird'
fs = promise.promisifyAll require 'graceful-fs'
path = require 'path'
debug = require('debug')('testeur-morue')
delve = require 'delve'
coffee = require 'coffee-script'

j4 = require('./jsonify')(4)

Morue = (settings)->
    $ = @
    options = _.extend {
        bufferSize: 100
    }, settings
    __read = ->
        fs.readAsync.apply fs, arguments
    __write = ->
        fs.writeAsync.apply fs, arguments
    __readFile = ->
        fs.readFileAsync.apply fs, arguments
    __writeFile = ->
        fs.writeFileAsync.apply fs, arguments
    @read = ($path)->
        $path = path.normalize $path
        # apply cod to given file
        fishify = (data)->
            return new promise (resolve, reject)->
                try
                    resolve cod data, {
                        docBegin: '/*'
                        docEnd: '*/'
                    }
                    return
                catch e
                    reject e
                    return
        # we should write a thing
        # which can deal with
        ###
            @example
                @coffee !!!
                    @!!!file <fileNameSomewhere>.coffee
            and
            @example
                @js !!!
                    @!!!file <fileNameSomewhere>.js
        ###
        # and convert them into resolved files which we can stuff inside of the examples object
                
        transformify = (data)->
            return new promise (resolve, reject)->
                try
                    if data?
                        if data.examples?
                            # store a reference to data.examples, 'cause we're gonna delete it
                            ___examples = data.examples
                            _.each ___examples, (ex, name)->
                                # this will deal with the case of
                                # @example.coffee.compile flags
                                if ex?.coffee?
                                    if ex.coffee.compile? and ex.coffee.compile and ex.coffee['!text']
                                        unless ex.js?
                                            debug "auto converting coffee"
                                            result = coffee.compile ex.coffee['!text'], {
                                                bare: true
                                            }
                                            ___examples[name].js = {
                                                "!value": '!!!'
                                                "!text": result
                                                "compiled": true
                                            }
                                            debug 'examples[%s].js = result', name, ___examples[name].js?
                            # create a function which acts as a dictionary for the examples
                            getAnExample = (ex)->
                                debug 'looking up example: %s', ex
                                # using delve and a simple pattern
                                exists = delve ___examples, ex
                                ### to find, use the pattern:
                                @example
                                    @coffee !!!
                                        @!!! <exampleName>.coffee
                                    @js !!!
                                        @!!! <exampleName>.js
                                ###
                                if exists? and exists["!value"]? and (exists["!value"] is '!!!') and (exists['!text']?)
                                    debug 'example found.', ex
                                    return exists["!text"]
                            delete data.examples
                        if data.object?
                            ### replace all instances of this pattern:
                                @example
                                    @coffee !!!
                                        @!!! <exampleName>.coffee
                                and this pattern
                                @example
                                    @js !!!
                                        @!!! <exampleName>.js
                                with their counterparts (if they exist)
                                in the examples object
                            ###
                            
                            mapper = (item, key)->
                                if item.example?.coffee? or item.example?.js?
                                    replacements = item.example
                                    _.each replacements, (ref, refName)->
                                        if ref?
                                            if (ref['!!!']?) and (ref['!value']?) and (ref['!value'] is '!!!')
                                                codeReference = ref['!!!']
                                                givenExample = getAnExample codeReference
                                                if givenExample?
                                                    ref['!!!'] = givenExample
                                            if ref?
                                                item.example[refName] = ref
                                out = {}
                                out[key] = item
                                return out
                            # simple extension
                            reducer = (x,y)->
                                return _.extend x, y
                            # there's probably a more efficient way than this
                            data.object = _(data.object).map mapper
                                                        .reduce reducer, {}
                        # this is sloppy, but we'll do it for now
                        setTimeout ->
                            resolve data
                        , 2e3
                catch e
                    console.log "error"
                    reject e
                    return

                
        errors = (e)->
            console.log "THIS IS AN ERROR", e
            if e.stack?
                console.log e.stack
        __readFile($path).then fishify
                         .then transformify
                         .catch errors

    return $


module.exports = Morue
    