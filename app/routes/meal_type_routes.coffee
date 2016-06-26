mealTypeRouteFunction = (router, auth, models, dbFunctions, utils) ->
    meal_route = router.route '/meal'

    meal_route.get (req, res) ->
        models.Meal.find(username: auth.username).sort(date:1).exec (err,meals)->
            prefix = ['cookingMethod', 'ingredient']
            suffix = ['Additions', 'Removals']
            populateItems = []
            populateItems = populateItems.concat p+s for p in prefix for s in suffix
            populateItems = populateItems.join('')
            populateItems += 'mealBase mealBase.cookingMethods mealBase.ingredients'
            models.Meal.deepPopulate meals, populateItems, (err, _meals) ->
                if err
                    res.status(401).send err
                mealsWithBases = []
                for meal in meals
                    mealFrontEnd = meal.toFrontEnd()

                    mealBaseFrontEnd = meal.mealBase.toFrontEnd()
                    mealFrontEnd.cookingMethods = mealBaseFrontEnd.cookingMethods
                    mealFrontEnd.ingredients = mealBaseFrontEnd.ingredients
                    mealFrontEnd.name = mealBaseFrontEnd.name
                    mealFrontEnd.baseServerId = mealBaseFrontEnd.serverId
                    mealFrontEnd.baseObjectId = mealBaseFrontEnd.jsonId
                    mealsWithBases.push mealFrontEnd
                res.json mealsWithBases

    meal_route.post (req, res) ->
        mealsToProcess = req.body
        console.log "posting #{mealsToProcess.length} meals"
        for meal,index in mealsToProcess
            if not meal.jsonId?
                console.log "no object id provided for meal index #{index}"
                res.status(500).send "no object id provided for meal index #{index}"
                return
            if not meal.baseObjectId?
                console.log "no base object id provided for meal index #{index}"
                res.status(500).send "no base object id provided for meal index #{index}"
                return
        savedMeals = []
        unsavedMeals = []

        processMeal = (index, next)->
            item = mealsToProcess[index]
            roundDate = utils.roundDateToNearest10Min
            [newMeal, mealBase] = dbFunctions.parseMeal item, auth.username, roundDate
            dbFunctions.createMeal newMeal, mealBase, models, (err,meal)->
                if err
                    console.log 'err creating meal'
                    if err == "Meal already in DB" or err.code = 11000
                        console.log 'meal already in db:',err.code
                        savedMeals.push newMeal.objectId
                    else
                        console.log "other create meal err:",err
                        unsavedMeals.push newMeal.objectId
                else
                    console.log "successfully created"
                    savedMeals.push newMeal.objectId
                index += 1
                if index == mealsToProcess.length
                    res.json
                        savedMeals: savedMeals
                        unsavedMeals: unsavedMeals
                else
                    next(index,next)
        processMeal(0,processMeal)

    meal_route.put (req,res) ->
        ##if item has mealBase ID, grab that entity
        ##otherwise create it
        ##then create Meal, and set its mealBase to the mealBase above:
        #
        #TODO: need to reintroduce the "edit" flag

        item = req.body
        console.log "ITEM:"
        console.log 'type:',item.type
        console.log 'jsonId:', item.jsonId
        console.log 'name:',item.name
        console.log 'date:',item.date
        console.log 'mealBase objectID:', item.baseObjectId

        if not item.jsonId?
            console.log "no object id provided"
            res.status(500).send "no object id provided"
            return
        if not item.baseObjectId?
            console.log "no base object id provided"
            res.status(500).send "no base object id provided"
            return
        roundDate = utils.roundDateToNearest10Min
        [newMeal, mealBase] = dbFunctions.parseMeal item, auth.username, roundDate
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
                    console.log 'err creating meal'
                    if err == "Meal already in DB" or err.code = 11000
                        console.log 'meal already in db:',err.code
                        res.status(600).send {message:"Meal already in DB"}
                        return
                    else
                        console.log "other create meal err:",err
                        res.status(500).send {message: "unknown error"}
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
