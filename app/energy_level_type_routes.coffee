energyLevelTypeRouteFunction = (router, models, dbFunctions, utils) ->
    energy_levels_route = router.route '/:username/energy_levels'
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
                energyLevel.username = req.params.username
                dbFunctions.checkIfMealInDB meal,models,saveCallback
            else
                if errs.length > 0
                    res.send errs
                else
                    res.json {message: 'Meals created!'}
        item = req.body[0]
        energyLevel = new models.EnergyLevel()
        energyLevel.rating = item.rating
        energyLevel.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        energyLevel.username = req.params.username
        dbFunctions.checkIfEnergyLevelInDB energyLevel,models, saveCallback


    energy_levels_route.get (req, res) ->
        models.EnergyLevel.find(username: req.params.username).sort(date:1).exec (err, energyLevels) ->
            if err
                res.send err
            res.json (energyLevel.toFrontEnd() for energyLevel in energyLevels)
    energy_levels_route.put (req,res) ->
        item = req.body
        energyLevel = new models.EnergyLevel()
        energyLevel.rating = item.rating
        energyLevel.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        energyLevel.username = req.params.username

        dbFunctions.checkIfEnergyLevelInDB energyLevel,models, (energyLevel,energyLevelInDB) ->
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
    energy_level_route.get (req,res) ->
        models.EnergyLevel.findById req.params.energy_level_id, (err,energyLevel) ->
            if energyLevel.username != req.params.username
                res.status(401).send "Attempt to update meal of different user"
            else if err
                res.send err
            else
                res.json energyLevel.toFrontEnd()
    energy_level_route.put (req,res) ->
        models.EnergyLevel.findById req.params.meal_id, (err,energyLevel) ->
            if energyLevel.username != req.params.username
                res.status(401).send "Attempt to update meal of different user"
            else if err
                res.send err
            else
                if req.body.rating? then energyLevel.rating = req.body.rating
                if req.body.date? then energyLevel.date = req.body.date
                if req.body.username? then energyLevel.username = req.body.username
                energyLevel.save (err)->
                    if err
                        res.send err
                    res.json {message: 'Energy Level updated'}
    energy_level_route.delete (req,res) ->
        if energyLevel.username != req.params.username
            res.status(401).send "Attempt to update meal of different user"
        else if err
            res.send err
        else
            models.EnergyLevel.remove {_id: req.params.energy_level_id}, (err,energyLevel)->
                if err
                    res.send err
                res.json {message: 'Successfully deleted'}

    return [energy_levels_route, energy_level_route]

module.exports = energyLevelTypeRouteFunction
