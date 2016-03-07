exports.up = (next) ->
    this.model('Rating').collection.dropIndex "username_1_date_1", (error,raw)->
        if error?
            console.error error
        #console.log('The number of updated documents was %d', numberAffected)
        console.log('The raw response from Mongo was ', raw)
        next()

exports.down = (next) ->
    self = this
    this.model('Rating').collection.dropIndex "__t_1_username_1_date_1", (error,raw)->
        if error?
            console.error error
        #console.log('The number of updated documents was %d', numberAffected)
        console.log('The raw response from Mongo was ', raw)
        options =
            name: "username_1_date_1"
            unique: true
            background: true
        keys =
            username: 1
            date: 1
        self.model('Rating').collection.createIndex keys, options, (error, raw)->
            if error?
                console.error error
            console.log('The raw response from Mongo was ', raw)
            next()
