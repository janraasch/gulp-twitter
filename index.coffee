{inspect} = require 'util'
through = require 'through2'
Twitter = require 'node-twitter-api'
gutil = require 'gulp-util'
PluginError = gutil.PluginError

createPluginError = (message) ->
    new PluginError 'gulp-twitter', message

twitterPlugin = (oauth = {}, message = '') ->
    # twitter client
    twitter = null

    # init twitter client
    try
        twitter = new Twitter(
            consumerKey: oauth.consumerKey,
            consumerSecret: oauth.consumerSecret,
            callback: null
        )
    catch e
        throw createPluginError "could not create twitter API: #{e}"

    # convert `String` message to `Function`
    if typeof message is 'string'
        _ret = message
        message = -> _ret

    # check `message` type
    if typeof message isnt 'function'
        throw createPluginError(
            'message param needs to be a String or a Function'
        )

    # return stream
    through.obj (file, enc, done) ->
        # create message
        fileMessage = message file

        # push file along
        @push file
        done()

        callback = (error, data, response) ->
            if error
                gutil.log(
                    "gulp-twitter: error sending tweet: #{inspect error}"
                )

        # tweet
        try
            twitter.statuses(
                'update',
                status: fileMessage,
                oauth.accessToken,
                oauth.accessTokenSecret,
                callback
            )
        catch e
            @emit 'error', createPluginError "error sending tweet: #{e}"

module.exports = twitterPlugin
