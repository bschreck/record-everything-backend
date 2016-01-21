basicAuth = require 'basic-auth'
authModel = require './auth_models'
authObject =
    model: authModel
auth = (req, res, next) ->
    unauthorized = (res, text) ->
        res.set 'WWW-Authenticate', 'Basic realm=Authorization Required'
        return res.status(401).send text
    if not req.headers["client-id"]?
        return unauthorized res, "client_id not provided"
    else
        clientId = req.headers["client-id"]
    authModel.getClient clientId, null, (err,id) ->
        if err
            return unauthorized res,"Unrecognized client id"
        user = basicAuth(req)
        if not user or not user.name or not user.pass
            return unauthorized res, "usename or password not provided"
        authModel.getUser user.name, user.pass, (err,id) ->
            if err or not id
                return unauthorized res, err
            authObject.username = user.name
            return next()
authObject.auth = auth
signup = (req, res) ->
    unauthorized = (res, text) ->
        res.set 'WWW-Authenticate', 'Basic realm=Authorization Required'
        return res.status(401).send text
    if not req.headers["client-id"]?
        return unauthorized res, "client_id not provided"
    else
        clientId = req.headers["client-id"]
    user = basicAuth(req)
    if not user or not user.name or not user.pass
        return unauthorized res, "username or password not provided"
    authModel.getClient clientId, null, (err,id) ->
        if err
            return unauthorized res, "Unrecognized client id"
        authModel.setUser user.name, user.pass, (err,id) ->
            if err
                return unauthorized res, error
            res.json {message: "User creation successful"}
authObject.signup = signup
module.exports = authObject
