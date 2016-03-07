stomachPainTypeRouteFunction = (router, auth, models, dbFunctions, utils) ->
    stomach_pains_route = router.route '/stomach_pains'
    stomach_pains_route.post (req, res) ->
        itemIndex = 0
        errs = []
        saveCallback = (stomachPain,stomachPainInDB) ->
            itemIndex += 1
            if itemIndex < req.body.length
                item = req.body[itemIndex]
                stomachPain = new models.StomachPain()
                stomachPain.rating = item.rating
                stomachPain.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
                stomachPain.username = auth.username
                dbFunctions.checkIfMealInDB meal,models,saveCallback
            else
                if errs.length > 0
                    res.send errs
                else
                    res.json {message: 'Stomach Pain Ratings created!'}
        item = req.body[0]
        stomachPain = new models.StomachPain()
        stomachPain.rating = item.rating
        stomachPain.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        stomachPain.username = auth.username
        dbFunctions.checkIfStomachPainInDB stomachPain,models, saveCallback


    stomach_pains_route.get (req, res) ->
        models.StomachPain.find(username: auth.username).sort(date:1).exec (err, stomachPains) ->
            if err
                res.send err
            res.json (stomachPain.toFrontEnd() for stomachPain in stomachPains)
    stomach_pains_route.put (req,res) ->
        item = req.body
        console.log item
        stomachPain = new models.StomachPain()
        stomachPain.rating = item.rating
        stomachPain.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        stomachPain.username = auth.username
        stomachPain.objectId = item.jsonId

        dbFunctions.checkIfStomachPainInDB stomachPain,models, (_,stomachPainInDB) ->
            if not stomachPainInDB
                stomachPain.save (err) ->
                    if err
                        console.log "err:",err
                        res.status(500).send err
                    res.json {message: "Successfully saved"}
            else
                console.log "in db"
                res.status(600).send 'Already in db'
    stomach_pain_route = router.route('/stomach_pains/:stomach_pain_id')


    return stomach_pains_route

module.exports = stomachPainTypeRouteFunction
