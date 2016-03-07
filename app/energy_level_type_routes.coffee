energyLevelTypeRouteFunction = (router, auth, models, dbFunctions, utils) ->
    energy_levels_route = router.route '/energy_levels'
    energy_levels_route.post (req, res) ->
        itemIndex = 0
        errs = []
        saveCallback = (energyLevel,energyLevelInDB) ->
            itemIndex += 1
            if itemIndex < req.body.length
                item = req.body[itemIndex]
                energyLevel = new models.EnergyLevel()
                energyLevel.rating = item.rating
                energyLevel.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
                energyLevel.username = auth.username
                dbFunctions.checkIfMealInDB meal,models,saveCallback
            else
                if errs.length > 0
                    res.send errs
                else
                    res.json {message: 'Energy Levels created!'}
        item = req.body[0]
        energyLevel = new models.EnergyLevel()
        energyLevel.rating = item.rating
        energyLevel.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        energyLevel.username = auth.username
        dbFunctions.checkIfEnergyLevelInDB energyLevel,models, saveCallback


    energy_levels_route.get (req, res) ->
        models.EnergyLevel.find(username: auth.username).sort(date:1).exec (err, energyLevels) ->
            if err
                res.send err
            res.json (energyLevel.toFrontEnd() for energyLevel in energyLevels)
    energy_levels_route.put (req,res) ->
        item = req.body
        console.log item
        energyLevel = new models.EnergyLevel()
        energyLevel.rating = item.rating
        energyLevel.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        energyLevel.username = auth.username
        energyLevel.objectId = item.jsonId

        dbFunctions.checkIfEnergyLevelInDB energyLevel,models, (_,energyLevelInDB) ->
            if not energyLevelInDB
                energyLevel.save (err) ->
                    if err
                        console.log "err:",err
                        res.status(500).send err
                    res.json {message: "Successfully saved"}
            else
                console.log "in db"
                res.status(600).send 'Already in db'
    energy_level_route = router.route('/energy_levels/:energy_level_id')


    return energy_levels_route

module.exports = energyLevelTypeRouteFunction
