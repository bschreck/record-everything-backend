exports.up = (next) ->
    updateDoc =
        $set:
            duration: 0
        $unset:
            photo: 1

    options =
        multi: true
        strict: false
    this.model('BowelMovement').update {},updateDoc,options,(error,raw)->
        if error
            console.error error
        #console.log('The number of updated documents was %d', numberAffected)
        console.log('The raw response from Mongo was ', raw)
        next()

exports.down = (next) ->
    updateDoc =
        $unset:
            duration: 1
        $set:
            photo: null

    options =
        multi: true
        strict: false
    this.model('BowelMovement').update {},updateDoc, options,(error,raw)->
        if error
            console.error error
        #console.log('The number of updated documents was %d', numberAffected)
        console.log('The raw response from Mongo was ', raw)
        next()
