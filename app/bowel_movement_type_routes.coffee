bowelMovementTypeRouteFunction = (router, auth, models, dbFunctions, utils) ->
    bowel_movements_route = router.route '/bowel_movements'
    bowel_movements_route.post (req, res) ->
        itemIndex = 0
        errs = []
        saveCallback = (bowelMovement,bowelMovementInDB) ->
            itemIndex += 1
            if itemIndex < req.body.length
                item = req.body[itemIndex]
                bowelMovement = new models.BowelMovement()
                bowelMovement.bsScale = item.bsScale
                bowelMovement.photo = if item.photo? then item.photo else null
                bowelMovement.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
                bowelMovement.username = auth.username
                dbFunctions.checkIfMealInDB meal,models,saveCallback
            else
                if errs.length > 0
                    res.send errs
                else
                    res.json {message: 'Bowel Movement Data created!'}
        item = req.body[0]
        bowelMovement = new models.BowelMovement()
        bowelMovement.bsScale = item.bsScale
        bowelMovement.photo = if item.photo? then item.photo else null
        bowelMovement.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        bowelMovement.username = auth.username
        dbFunctions.checkIfBowelMovementInDB bowelMovement,models, saveCallback


    bowel_movements_route.get (req, res) ->
        models.BowelMovement.find(username: auth.username).sort(date:1).exec (err, bowelMovements) ->
            if err
                res.send err
            res.json (bowelMovement.toFrontEnd() for bowelMovement in bowelMovements)
    bowel_movements_route.put (req,res) ->
        item = req.body
        console.log item
        bowelMovement = new models.BowelMovement()
        bowelMovement.bsScale = item.bsScale
        bowelMovement.photo = if item.photo? then item.photo else null
        bowelMovement.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        bowelMovement.username = auth.username
        bowelMovement.objectId = item.jsonId

        dbFunctions.checkIfBowelMovementInDB bowelMovement,models, (_,bowelMovementInDB) ->
            if not bowelMovementInDB
                bowelMovement.save (err) ->
                    if err
                        console.log "err:",err
                        res.status(500).send err
                    res.json {message: "Successfully saved"}
            else
                console.log "in db"
                res.status(600).send 'Already in db'
    bowel_movement_route = router.route('/bowel_movements/:bowel_movement_id')


    return bowel_movements_route

module.exports = bowelMovementTypeRouteFunction
