sicknessTypeRouteFunction = (router, auth, models, dbFunctions, utils) ->
    sicknesses_route = router.route '/sicknesses'
    sicknesses_route.post (req, res) ->
        itemIndex = 0
        errs = []
        saveCallback = (sickness,sicknessInDB) ->
            itemIndex += 1
            if itemIndex < req.body.length
                item = req.body[itemIndex]
                sickness = new models.Sickness()
                sickness.rating = item.rating
                sickness.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
                sickness.username = auth.username
                dbFunctions.checkIfMealInDB meal,models,saveCallback
            else
                if errs.length > 0
                    res.send errs
                else
                    res.json {message: 'Sickness Ratings created!'}
        item = req.body[0]
        sickness = new models.Sickness()
        sickness.rating = item.rating
        sickness.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        sickness.username = auth.username
        dbFunctions.checkIfSicknessInDB sickness,models, saveCallback


    sicknesses_route.get (req, res) ->
        models.Sickness.find(username: auth.username).sort(date:1).exec (err, sicknesss) ->
            if err
                res.send err
            res.json (sickness.toFrontEnd() for sickness in sicknesss)
    sicknesses_route.put (req,res) ->
        item = req.body
        console.log item
        sickness = new models.Sickness()
        sickness.rating = item.rating
        sickness.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        sickness.username = auth.username
        sickness.objectId = item.jsonId

        dbFunctions.checkIfSicknessInDB sickness,models, (_,sicknessInDB) ->
            if not sicknessInDB
                sickness.save (err) ->
                    if err
                        console.log "err:",err
                        res.status(500).send err
                    res.json {message: "Successfully saved"}
            else
                console.log "in db"
                res.status(600).send 'Already in db'
    sickness_route = router.route('/sicknesses/:sickness_id')


    return sicknesses_route

module.exports = sicknessTypeRouteFunction
