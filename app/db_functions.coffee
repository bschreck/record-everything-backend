module.exports =
    updateMeal: (newMeal, mealBase, models, callback) ->
        throw "not implemented"

    createMeal: (newMeal, mealBase, models, callback) ->
        module.exports.createFindOrUpdateMealBaseWithSubdocs mealBase, models, false,(err,mealBaseID)->
            if err?
                console.log "create or find mealbase err:", err
                console.log "mealBaseID:", mealBaseID
            newMeal.mealBase = mealBaseID
            module.exports.checkIfMealInDB newMeal, models, (meal, mealInDB)->
                if mealInDB
                    callback "Meal already in DB", null
                else
                    cookingMethodAdditions = newMeal.cookingMethodAdditions
                    cookingMethodRemovals = newMeal.cookingMethodRemovals
                    ingredientAdditions = newMeal.ingredientAdditions
                    ingredientRemovals = newMeal.ingredientRemovals

                    cookingMethodAdditionIDs = []
                    cookingMethodRemovalIDs = []
                    ingredientAdditionIDs = []
                    ingredientRemovalIDs = []
                    state = "cm_addition"
                    actuallyCreateMeal = ()->
                        meal = new models.Meal
                            username:               newMeal.username
                            type:                   newMeal.type
                            ingredientAdditions:    ingredientAdditionIDs
                            ingredientRemovals:     ingredientRemovalIDs
                            cookingMethodAdditions: cookingMethodAdditionIDs
                            cookingMethodRemovals:  cookingMethodRemovalIDs
                            date:                   newMeal.date
                            photo:                  newMeal.photo
                            mealBase:               mealBaseID
                            objectId:               newMeal.objectId
                        meal.save callback
                    order = ["cm_addition","cm_removal","ing_addition","ing_removal"]
                    info =
                        "cm_addition":
                            func: module.exports.createCM
                            data: cookingMethodAdditions
                            ids:  cookingMethodAdditionIDs
                        "cm_removal":
                            func: module.exports.createCM
                            data: cookingMethodRemovals
                            ids:  cookingMethodRemovalIDs
                        "ing_addition":
                            func: module.exports.createIngredient
                            data: ingredientAdditions
                            ids:  ingredientAdditionIDs
                        "ing_removal":
                            func: module.exports.createIngredient
                            data: ingredientRemovals
                            ids:  ingredientRemovalIDs
                    pickNext = module.exports.pickNextItemToSave(state, actuallyCreateMeal,
                        order, info, models)
                    pickNext(null,null)


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
            type:     meal.type
            date:     meal.date
            username: meal.username
            mealBase: meal.mealBase
        console.log "checking for duplicates:", findQuery
        models.Meal.findOne findQuery, (err,dbMeal)->
            if dbMeal?
                console.log "found duplicate meal"
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
                cookingMethodIDs = []
                ingredientIDs = []
                actuallyCreateMealBase = ()->
                    createFunc = if edit then module.exports.updateMealBase else module.exports.createMealBase
                    createFunc(newMealBase.objectId,newMealBase.name,newMealBase.username,
                        cookingMethodIDs, ingredientIDs, models, callback)

                order = ["cm", "ing"]
                info =
                    "cm":
                        func: module.exports.createCM
                        data: cookingMethods
                        ids:  cookingMethodIDs
                    "ing":
                        func: module.exports.createIngredient
                        data: ingredients
                        ids:  ingredientIDs
                state = "cm"
                pickNext = module.exports.pickNextItemToSave state, actuallyCreateMealBase,
                    order, info, models
                pickNext(null,null)

    pickNextItemToSave: (stateVar, finishFunc, stateOrder, info, models) ->
        pickNext = (err,obj_id) ->
            if not err? and obj_id?
                info[stateVar]["ids"].push obj_id
            for dtype in stateOrder[(stateOrder.indexOf stateVar)..]
                data = info[dtype]['data']
                func = info[dtype]['func']
                if data.length > 0
                    stateVar = dtype
                    newDatum = data.shift()
                    func newDatum, models, pickNext
                    return
            finishFunc()
        return pickNext


    checkIfEnergyLevelInDB: (energyLevel,models, callback) ->
        findQuery =
            date: energyLevel.date
            username: energyLevel.username
        models.EnergyLevel.findOne findQuery, (err,energyLevel)->
            if energyLevel?
                callback energyLevel,true
            else
                callback energyLevel,false
