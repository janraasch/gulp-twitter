'use strict'
{spawn} = require 'child_process'
fs = require 'fs'
gulp = require 'gulp'
{log,colors} = require 'gulp-util'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
del = require 'del'

# compile `index.coffee`
gulp.task 'coffee', ->
    gulp.src 'index.coffee'
        .pipe coffee bare: true
        .pipe gulp.dest './'

# remove `index.js` and `coverage` dir
gulp.task 'clean', ->
    del(['index.js', 'coverage'])

# run tests
gulp.task 'test', ['coffee'], ->
    spawn 'npm', ['test'], stdio: 'inherit'

# run `gulp-twitter` for testing purposes
gulp.task 'twitter', ->
    env = process.env
    twitter = require './index.coffee'
    job = env.TRAVIS_JOB_NUMBER
    oauth = null
    message = (file) ->
        if file.coffeelint.success
            return "(##{job}) #{file.relative} is lint free"
        else
            return "(##{job}) #{file.relative} did not lint"

    if env.CI and env.TRAVIS
        oauth = {
            consumerKey: env.CONSUMER_KEY
            consumerSecret: env.CONSUMER_SECRET
            accessToken: env.ACCESS_TOKEN
            accessTokenSecret: env.ACCESS_TOKEN_SECRET
        }
    else
        oauth = JSON.parse fs.readFileSync './not-so-secret-test.json'

    gulp.src './{,test/}*.coffee'
        .pipe coffeelint()
        .pipe twitter oauth, message

    gulp.src 'package.json'
        .pipe twitter oauth, "(##{job}) *gulp*... *gulp*... *gulp*..."

# start workflow
gulp.task 'default', ['coffee'], ->
    gulp.watch ['./{,test/,test/fixtures/}*.coffee'], ['test']

# Generated on 2014-01-25 using generator-gulpplugin-coffee 0.0.3
