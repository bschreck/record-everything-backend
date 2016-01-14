mealTypeRouteFunction = (router, models, dbFunctions, utils) ->
    meals_route = router.route '/:username/meals'
    meals_route.post (req, res) ->
        itemIndex = 0
        errs = []
        saveCallback = (meal,mealInDB) ->
            if not mealInDB
                models.PastMeal.incrementMeal meal.name, meal.type, meal.username, (err, numAffected) ->
                    if err then console.log "past meal increment error:",err
                meal.save (err) ->
                    if err
                        errs.push err
            itemIndex += 1
            if itemIndex < req.body.length
                item = req.body[itemIndex]
                meal = new models.Meal()
                meal.name = item.name
                meal.type = item.type
                meal.photo = item.photo
                meal.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
                meal.username = req.params.username
                dbFunctions.checkIfMealInDB meal,models,saveCallback
            else
                if errs.length > 0
                    res.send errs
                else
                    res.json {message: 'Meals created!'}
        item = req.body[0]
        meal = new models.Meal()
        meal.name = item.name
        meal.type = item.type
        meal.photo = item.photo
        meal.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        meal.username = req.params.username
        dbFunctions.checkIfMealInDB meal,models, saveCallback


    meals_route.get (req, res) ->
        models.Meal.find(username: req.params.username).sort(date:1).exec (err, meals) ->
            if err
                res.send err
            res.json (meal.toFrontEnd() for meal in meals)
    meals_route.put (req,res) ->
        item = req.body
        meal = new models.Meal()
        meal.name = item.name
        meal.type = item.type
        meal.photo = item.photo
        meal.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        meal.username = req.params.username
        dbFunctions.checkIfMealInDB meal,models, (meal,mealInDB) ->
            if not mealInDB
                models.PastMeal.incrementMeal meal.name, meal.type, meal.username, (err, numAffected) ->
                    if err then console.log "past meal increment error:",err

                meal.save (err) ->
                    if err
                        console.log "err:",err
                        res.status(500).send err
                    res.json {message: "Successfully saved"}
            else
                console.log "in db"
                res.status(600).send 'Already in db'
    meal_route = router.route('/:username/meals/:meal_id')
    meal_route.get (req,res) ->
        models.Meal.findById req.params.meal_id, (err,meal) ->
            if err
                res.send err
            res.json meal.toFrontEnd()
    meal_route.put (req,res) ->
        models.Meal.findById req.params.meal_id, (err,meal) ->
            if err
                res.send err
            if req.body.name? then meal.name = req.body.name
            if req.body.type? then meal.type = req.body.type
            if req.body.photo? then meal.photo = req.body.photo
            if req.body.date? then meal.date = req.body.date
            meal.save (err)->
                if err
                    res.send err
                res.json {message: 'Meal updated'}
    meal_route.delete (req,res) ->
        models.Meal.findById req.params.meal_id, (err,meal) ->
            if err
                res.send err
            if meal.username != req.params.username
                res.status(401).send "Attempt to delete meal of different user"
            else
                models.Meal.remove {_id: req.params.meal_id}, (err,meal)->
                  if err
                      res.send err
                  res.json {message: 'Successfully deleted'}

    past_meals_route = router.route('/:username/past_meals')
    past_meals_route.all auth, (req, res, next) ->
        next()
    past_meals_route.get (req,res) ->
        models.PastMeal.find(username: req.params.username).exec (err, pastMealsArray) ->
            if err
                res.send err
            pastMeals = models.PastMeal.toFrontEnd(pastMealsArray)
            console.log "pastMeals:",pastMeals
            res.json pastMeals

    return [meals_route, meal_route, past_meals_route]

module.exports = mealTypeRouteFunction
