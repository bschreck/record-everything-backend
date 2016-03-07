exports.up = (next) ->
    updateDoc =
        $set:
            ingredientAdditions: []
            ingredientRemovals: []
            cookingMethodsAdditions: []
            cookingMethodsRemovals: []

    options =
        multi: true
        strict: false
    this.model('Meal').update {},updateDoc,options,(error,raw)->
        if error
            console.error error
        #console.log('The number of updated documents was %d', numberAffected)
        console.log('The raw response from Mongo was ', raw)
        next()

exports.down = (next) ->
    updateDoc =
        $unset:
            ingredientAdditions: []
            ingredientRemovals: []
            cookingMethodsAdditions: []
            cookingMethodsRemovals: []

    options =
        multi: true
        strict: false
    this.model('Meal').update {},updateDoc, options,(error,raw)->
        if error
            console.error error
        #console.log('The number of updated documents was %d', numberAffected)
        console.log('The raw response from Mongo was ', raw)
        next()
