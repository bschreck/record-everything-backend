mealBaseTypeRouteFunction = (router, auth, models, dbFunctions, utils) ->
    meal_base_route = router.route '/meal_base'

    meal_base_route.get (req, res) ->
        console.log "in get"
        models.MealBase.find({username: auth.username}).populate('cookingMethods ingredients').exec (err, mealBases) ->
            if err
                res.status(401).send err
            console.log (mealBase.toFrontEnd() for mealBase in mealBases)
            res.json (mealBase.toFrontEnd() for mealBase in mealBases)

    meal_base_route.put (req,res) ->
        console.log "PUT"
        console.log "REQ:", req.body
        item = req.body
        mealBase =
            name:           item.name
            username:       auth.username
            cookingMethods: item.cookingMethods
            ingredients:    item.ingredients
            objectId:       item.jsonId
        edit = if (item.edit? and item.edit) then true else false
        dbFunctions.createFindOrUpdateMealBaseWithSubdocs mealBase, models, edit, (err, mealBaseId)->
            if err
                console.log "unable to create meal base:, ",err
                res.status(500).send err
            else
                console.log "returning id"
                res.json {message: "Successfully created or found meal base"}


    meal_base_route.delete (req,res) ->
        item = req.body
        console.log "id:",item.serverId
        models.MealBase.findOne {objectId: item.jsonId}, (err,mealBase) ->
            console.log "mealbase:", mealBase
            if err or not mealBase?
                res.status(401).send err
            else if mealBase.username != auth.username
                res.status(401).send "Attempt to delete meal base of different user"
            else
                models.MealBase.remove {_id: mealBase._id}, (err,mealBase)->
                  if err
                      res.status(401).send err
                  res.json {message: 'Successfully deleted'}
    return [meal_base_route]
module.exports = mealBaseTypeRouteFunction
