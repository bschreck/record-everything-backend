module.exports =
    loadUser: ->
        console.log "load user"
    login: (user, pass, callback) ->
        result = (user == 'testUser' and pass == 'testPass')
        callback null /* error */, result
    signup: (user, pass, pass_check, callback) ->
        console.log "do stuff"
