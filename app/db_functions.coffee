module.exports =
    checkIfMealInDB: (meal,models, callback) ->
        findQuery =
            name:     meal.name
            type:     meal.type
            date:     meal.date
            username: meal.username
        models.Meal.find findQuery, (err,meals)->
            if meals.length == 0
                callback meal,false
            else
                callback null,true
    checkIfEnergyLevelInDB: (energyLevel,models, callback) ->
        findQuery =
            date: energyLevel.date
            username: energyLevel.username
        models.EnergyLevel.find findQuery, (err,energyLevels)->
            if energyLevels.length == 0
                callback energyLevel,false
            else
                callback null,true
