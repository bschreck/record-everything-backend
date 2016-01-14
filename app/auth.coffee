basicAuth = require 'basic-auth'
module.exports =
    loadUser: ->
        console.log "load user"
    auth: (req, res, next) ->
        unauthorized = (res) ->
            res.set 'WWW-Authenticate', 'Basic realm=Authorization Required'
            return res.send 401
        user = basicAuth(req)
        if not user or not user.name or not user.pass
            return unauthorized res
        if user.name == 'foo' and user.pass == 'bar'
            return next()
        else
            return unauthorized res
    signup: (user, pass, pass_check, callback) ->
        console.log "do stuff"
