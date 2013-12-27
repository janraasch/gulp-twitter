# module dependencies
should = require 'should'
gutil = require 'gulp-util'
path = require 'path'

# const
PLUGIN_NAME = 'gulp-twitter'
ERRS =
    MESSAGE:
        'message param needs to be a String or a Function'

# SUT
twitter = require '../'

describe 'gulp-twitter', ->
    describe 'twitter()', ->

        # TODO
        # Use something like
        # https://github.com/felixge/node-sandboxed-module
        # for mocking `node-twitter-api`
        # and test calls to the API

        it 'should pass through empty files', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: null

            stream = twitter()

            stream.on 'data', (newFile) ->
                should.exist(newFile)
                should.exist(newFile.path)
                should.exist(newFile.relative)
                should.not.exist(newFile.contents)
                newFile.path.should.equal fakeFile.path
                newFile.relative.should.equal 'file.js'
                ++dataCounter

            stream.once 'end', ->
                dataCounter.should.equal 1
                done()

            stream.write fakeFile
            stream.end()

        it 'should pass through a file', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'sure()'

            stream = twitter()

            stream.on 'data', (newFile) ->
                should.exist(newFile)
                should.exist(newFile.path)
                should.exist(newFile.relative)
                should.exist(newFile.contents)
                newFile.path.should.equal './test/fixture/file.js'
                newFile.relative.should.equal 'file.js'
                ++dataCounter


            stream.once 'end', ->
                dataCounter.should.equal 1
                done()

            stream.write fakeFile
            stream.end()

        it 'should pass through two files', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'yeah()'

            fakeFile2 = new gutil.File
                path: './test/fixture/file2.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'yeahmetoo()'


            stream = twitter()

            stream.on 'data', (newFile) ->
                ++dataCounter

            stream.once 'end', ->
                dataCounter.should.equal 2
                done()

            stream.write fakeFile
            stream.write fakeFile2
            stream.end()

        describe 'errors', ->
            describe 'are thrown', ->
                it 'if message is neither a function nor a string', (done) ->
                    try
                        stream = twitter {}, false
                    catch e
                        should(e.plugin).equal PLUGIN_NAME
                        should(e.message).equal ERRS.MESSAGE
                        done()
