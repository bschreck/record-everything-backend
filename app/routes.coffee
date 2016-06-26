fs = require 'fs'
path = require 'path'
authFunctions = require './auth'

routeFunction = (router,models,dbFunctions,utils) ->

    router.get '/', (req,res) ->
        res.json {message: 'welcome to api!'}

    auth = authFunctions.auth

    router.post '/signup', (req, res) ->
        authFunctions.signup req, res

    #router.all '/oauth/token', oauth.grant()

    router.all '*', auth, (req,res,next) ->
        next()
    router.post '/login', (req,res) ->
        res.json {message: "Welcome!"}

    #read the rest of the routes from the routes directory
    fs.readdir './app/routes',(err,files)->
        for f in files
            if path.extname(f) is ".coffee"
                routeFunc = require "./routes/#{f[..-8]}"
                routeFunc(router, authFunctions, models, dbFunctions, utils)

module.exports = routeFunction
