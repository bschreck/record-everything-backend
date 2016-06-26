makePlural = (singular)->
    if singular.endsWith('s')
        return "#{singular}es"
    else
        return "#{singular}s"
camelCase = (lowercase)->
    capitalize = lowercase[0].toUpperCase() + lowercase[1..]
    under = capitalize.indexOf "_"
    if under > -1
        capitalize = capitalize.replace("_","")
        capitalize = capitalize[...under]+capitalize[under].toUpperCase()+capitalize[under+1..]
    capitalize

ratingTypeRouteFunction = (ratingType, router, auth, models, dbFunctions, utils)->
    plural = makePlural ratingType
    ratings_route = router.route '/'+plural

    checkIfRatingInDB = (rating,models, callback) ->
        modelName = camelCase ratingType
        keys = ["date","username"]
        dbFunctions.checkIfObjInDBUsingKeys models, modelName, keys, rating, callback

    ratings_route.post (req, res) ->
        itemIndex = 0
        errs = []
        saveCallback = (rating,ratingInDB) ->
            itemIndex += 1
            if itemIndex < req.body.length
                item = req.body[itemIndex]
                Model = models[camelCase ratingType]
                rating = new Model()
                rating.rating = item.rating
                rating.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
                rating.username = auth.username
                dbFunctions.checkIfMealInDB meal,models,saveCallback
            else
                if errs.length > 0
                    res.send errs
                else
                    res.json {message: "#{camelCase ratingType} Ratings created!"}
        item = req.body[0]
        Model = models[camelCase ratingType]
        rating = new Model
        rating.rating = item.rating
        rating.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        rating.username = auth.username
        checkIfRatingInDB rating,models, saveCallback


    ratings_route.get (req, res) ->
        Model = models[camelCase ratingType]
        Model.find(username: auth.username).sort(date:1).exec (err, ratings) ->
            if err
                res.send err
            res.json (rating.toFrontEnd() for rating in ratings)
    ratings_route.put (req,res) ->
        item = req.body
        Model = models[camelCase ratingType]
        rating = new Model()
        rating.rating = item.rating
        rating.date = utils.roundDateToNearest10Min(new Date(item.date*1000))
        rating.username = auth.username
        rating.objectId = item.jsonId

        checkIfRatingInDB rating,models, (oldRating,ratingInDB) ->
            if not ratingInDB
                rating.save (err) ->
                    if err
                        console.log "err:",err
                        res.status(500).send err
                    res.json {message: "Successfully saved"}
            else
                console.log "in db"
                res.status(600).send 'Already in db'

    return ratings_route

allRatingTypeRouteFunctions = (router, auth, models, dbFunctions, utils)->
    ratingTypes = ["energy_level", "sickness", "tiredness", "stomach_pain"]
    routes = {}
    for ratingType in ratingTypes
        routes[ratingType] = ratingTypeRouteFunction ratingType, router, auth, models, dbFunctions, utils
    return routes
module.exports = allRatingTypeRouteFunctions
