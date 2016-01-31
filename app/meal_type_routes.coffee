mealTypeRouteFunction = (router, auth, models, dbFunctions, utils) ->
    meal_route = router.route '/meal'

    meal_route.get (req, res) ->
        populateQueryCM =
            path: 'mealBase'
            populate:
                path: 'cookingMethods'
                model: 'CookingMethod'
        populateQueryIng =
            path: 'mealBase'
            populate:
                path: 'ingredients'
                model: 'Ingredient'
        models.Meal.find(username: auth.username).sort(date:1).exec (err,meals)->
            models.Meal.deepPopulate meals, 'mealBase mealBase.cookingMethods mealBase.ingredients', (err, _meals) ->
                console.log meals
                if err
                    res.status(401).send err
                mealsWithBases = []
                for meal in meals
                    mealFrontEnd = meal.toFrontEnd()

                    mealBaseFrontEnd = meal.mealBase.toFrontEnd()
                    console.log mealBaseFrontEnd
                    mealFrontEnd.cookingMethods = mealBaseFrontEnd.cookingMethods
                    mealFrontEnd.ingredients = mealBaseFrontEnd.ingredients
                    mealFrontEnd.name = mealBaseFrontEnd.name
                    mealFrontEnd.baseServerId = mealBaseFrontEnd.serverId
                    mealFrontEnd.baseObjectId = mealBaseFrontEnd.jsonId
                    mealsWithBases.push mealFrontEnd
                res.json mealsWithBases

    #meal_route.post (req, res) ->
        #itemIndex = 0
        #errs = []
        #saveCallback = (meal,mealInDB) ->
            #if not mealInDB
                #models.PastMeal.incrementMeal meal.name, meal.type, meal.username, (err, numAffected) ->
                    #if err then console.log "past meal increment error:",err
                #meal.save (err) ->
                    #if err
                        #errs.push err
            #itemIndex += 1
            #if itemIndex < req.body.length
                #item = req.body[itemIndex]
                #meal = new models.Meal()
                #meal.name = item.name
                #meal.type = item.type
                #meal.photo = item.photo
                #meal.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
                #meal.username = auth.username
                #dbFunctions.checkIfMealInDB meal,models,saveCallback
            #else
                #if errs.length > 0
                    #res.status(401).send errs
                #else
                    #res.json {message: 'Meals created!'}
        #item = req.body[0]
        #meal = new models.Meal()
        #meal.name = item.name
        #meal.type = item.type
        #meal.photo = item.photo
        #meal.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        #meal.username = auth.username
        #dbFunctions.checkIfMealInDB meal,models, saveCallback



    meal_route.put (req,res) ->
        ##if item has mealBase ID, grab that entity
        ##otherwise create it
        ##then create Meal, and set its mealBase to the mealBase above:
        #
        #TODO: need to reintroduce the "edit" flag

        item = req.body

        if not item.jsonId?
            console.log "no object id provided"
            res.status(500).send "no object id provided"
            return
        if not item.baseObjectId?
            console.log "no base object id provided"
            res.status(500).send "no base object id provided"
            return
        newMeal =
            type:     item.type
            photo:    item.photo
            date:     utils.roundDateToNearest10Min(new Date(item.date*1000))
            username: auth.username
            objectId: item.jsonId
        mealBase =
            name:           item.name
            username:       auth.username
            cookingMethods: item.cookingMethods
            ingredients:    item.ingredients
            objectId:       item.baseObjectId
        console.log "mealbase:",mealBase
        if item.edit
            dbFunctions.updateMeal newMeal, mealBase, models, (err,meal)->
                if err
                    res.status(500).send err
                    return
                else
                    res.json {message: "Successfully updated"}
                    return
        else
            dbFunctions.createMeal newMeal, mealBase, models, (err,meal)->
                if err
                    if err == "Meal already in DB"
                        res.status(600).send err
                        return
                    else
                        console.log "create meal err:",err
                        res.status(500).send err
                        return
                else
                    console.log "successfully created"
                    res.json {message: "Successfully created"}
                    return





    meal_route.delete (req,res) ->
        item = req.body
        models.Meal.findOne {objectId: item.objectId}, (err,meal) ->
            if err or not meal?
                res.status(401).send err
            else if meal.username != auth.username
                res.status(401).send "Attempt to delete meal of different user"
            else
                models.Meal.remove {_id: meal._id}, (err,meal)->
                  if err
                      res.status(401).send err
                  res.json {message: 'Successfully deleted'}

    past_meals_route = router.route('/past_meals')
    past_meals_route.all (req, res, next) ->
        next()
    past_meals_route.get (req,res) ->
        models.PastMeal.find(username: auth.username).exec (err, pastMealsArray) ->
            if err
                res.status(401).send err
            pastMeals = models.PastMeal.toFrontEnd(pastMealsArray)
            console.log "pastMeals:",pastMeals
            res.json pastMeals

    return [meal_route, past_meals_route]

module.exports = mealTypeRouteFunction
