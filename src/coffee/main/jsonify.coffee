"use strict"

module.exports = (indent=4)->
    return (x)->
        return JSON.stringify x, null, indent