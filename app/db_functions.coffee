module.exports =
    updateMeal: (newMeal, mealBase, models, callback) ->
        throw "not implemented"

    createMeal: (newMeal, mealBase, models, callback) ->
        module.exports.checkIfMealInDB newMeal, models, (meal, mealInDB)->
            if not mealInDB
                module.exports.createFindOrUpdateMealBaseWithSubdocs mealBase, models, false,(err,mealBaseID)->
                    meal = new models.Meal
                        name:           newMeal.name
                        username:       newMeal.username
                        type:           newMeal.type
                        date:           newMeal.date
                        photo:          newMeal.photo
                        mealBase:       mealBaseID
                        objectId:       newMeal.objectId
                    console.log "create or find mealbase err:", err
                    console.log "mealBaseID:", mealBaseID
                    meal.save callback
            else
                callback "Meal already in DB", null

    checkIfCookingMethodInDBAndCreate: (name,models, callback) ->
        findQuery =
            name:     name
        models.CookingMethod.findOne findQuery, (err,cm)->
            if cm?
                callback null, cm
            else
                cm = models.CookingMethod({name:name})
                cm.save (err)->
                    if err
                        callback err, null
                    else
                        callback null, cm
    checkIfIngredientInDBAndCreate: (name,models, callback) ->
        findQuery =
            name:     name
        models.Ingredient.findOne findQuery, (err,ing)->
            if ing?
                callback null, ing
            else
                ing = models.Ingredient({name:name})
                ing.save (err)->
                    if err
                        callback err, null
                    else
                        callback null, ing


    checkIfMealBaseInDB: (mealBase,models, callback) ->
        findQuery =
            name:     mealBase.name
            username: mealBase.username
        models.MealBase.findOne findQuery, (err,dbMealBase)->
            if dbMealBase?
                if dbMealBase.objectId == mealBase.objectId
                    callback null, dbMealBase,true
                else
                    callback "Wrong object id", dbMealBase, true
            else
                models.MealBase.findOne {objectId:mealBase.objectId}, (err,dbMealBase)->
                    if dbMealBase?
                        callback "Object id already exists", dbMealBase, true
                    else
                        callback null, null,false

    checkIfMealInDB: (meal,models, callback) ->
        findQuery =
            name:     meal.name
            type:     meal.type
            date:     meal.date
            username: meal.username
            mealBase: meal.mealBase
        models.Meal.findOne findQuery, (err,dbMeal)->
            if dbMeal?
                callback dbMeal,true
            else
                callback dbMeal,false

    updateMealBase: (objectId, name, username, cookingMethodIDs, ingredientIDs, models, callback)->
        findQuery =
            objectId: mealBase.objectId
        updateQuery =
            $set:
                name: name
                username: username
                cookingMethods: cookingMethodsIDs
                ingredients: ingredientIDs
        models.MealBase.update findQuery, updateQuery, (err)->
            if err
                callback err, null
            else
                mb = models.MealBase.findOne findQuery, (err,mb)->
                    console.log "updated mealbase"
                    callback err, mb
    createMealBase: (objectId, name, username, cookingMethodIDs, ingredientIDs, models, callback) ->
        console.log "create meal base"
        mealBase = new models.MealBase
            name:           name
            username:       username
            cookingMethods: cookingMethodIDs
            ingredients:    ingredientIDs
            objectId:       objectId
        mealBase.save (err,mb)->
            if err? then callback err,null else callback null,mb._id

    createCM: (name, models, callback) ->
        module.exports.checkIfCookingMethodInDBAndCreate name,models, (err,cm)->
            if cm? then callback err,cm._id else callback err,null
    createIngredient: (name, models, callback) ->
        module.exports.checkIfIngredientInDBAndCreate name,models, (err,ing)->
            if ing? then callback err,ing._id else callback err,null

    createFindOrUpdateMealBaseWithSubdocs: (newMealBase, models, edit,callback) ->
        cmIndex = 0
        ingredientIndex = 0
        cookingMethodIDs = []
        ingredientIDs = []
        if not newMealBase.name?
            callback "no name provided", null
        if not newMealBase.username?
            callback "no username provided", null
        if not newMealBase.objectId?
            callback "no objectId provided", null
        console.log "newMealBase:",newMealBase
        console.log "cookingMethods:",newMealBase.cookingMethods
        console.log "length:",newMealBase.cookingMethods.length
        if not newMealBase.cookingMethods? or newMealBase.cookingMethods.length == 0
            callback "must have at least one cooking method", null
        module.exports.checkIfMealBaseInDB newMealBase, models, (err, mealBase, mbInDB)->
            if err
                callback err, null
            else if mbInDB and not edit
                callback null, mealBase._id
            else
                cookingMethods = if newMealBase.cookingMethods? then newMealBase.cookingMethods else []
                ingredients = if newMealBase.ingredients? then newMealBase.ingredients else []


                ingCallback = (err,ing_id)->
                    ingredientIDs.push ing_id
                    ingredientIndex += 1
                    if ingredientIndex < ingredients.length
                        module.exports.createIngredient(ingredients[ingredientIndex], models, ingCallback)
                    else if not edit
                        module.exports.createMealBase(newMealBase.objectId, newMealBase.name, newMealBase.username, cookingMethodIDs, ingredientIDs, models, callback)
                    else
                        module.exports.updateMealBase(newMealBase.objectId, newMealBase.name, newMealBase.username, cookingMethodIDs, ingredientIDs, models, callback)
                cmCallback = (err,cm_id)->
                    cookingMethodIDs.push cm_id
                    cmIndex += 1
                    if cmIndex < cookingMethods.length
                        module.exports.createCM(cookingMethods[cmIndex], models, cmCallback)
                    else if ingredients.length > 0
                        module.exports.createIngredient(ingredients[ingredientIndex], models, ingCallback)
                    else if not edit
                        module.exports.createMealBase(newMealBase.objectId, newMealBase.name, newMealBase.username, cookingMethodIDs, ingredientIDs, models, callback)
                    else
                        module.exports.updateMealBase(newMealBase.objectId, newMealBase.name, newMealBase.username, cookingMethodIDs, ingredientIDs, models, callback)

                if cookingMethods.length > 0
                    module.exports.createCM cookingMethods[cmIndex], models, cmCallback
                else if not edit
                    module.exports.createMealBase(newMealBase.objectId, newMealBase.name, newMealBase.username, cookingMethodIDs, ingredientIDs, models, callback)
                else
                    module.exports.updateMealBase(newMealBase.objectId, newMealBase.name, newMealBase.username, cookingMethodIDs, ingredientIDs, models, callback)


    checkIfEnergyLevelInDB: (energyLevel,models, callback) ->
        findQuery =
            date: energyLevel.date
            username: energyLevel.username
        models.EnergyLevel.findOne findQuery, (err,energyLevel)->
            if energyLevel?
                callback energyLevel,true
            else
                callback energyLevel,false
