authFunctions = require './auth'
routeFunction = (router,models,dbFunctions,utils) ->

    router.use (req, res, next) ->
        next()


    router.get '/', (req,res) ->
        res.json {message: 'welcome to api!'}

    auth = authFunctions.auth

    router.post '/signup', (req, res) ->
        authFunctions.signup req, res

    #router.all '/oauth/token', oauth.grant()

    router.all '*', auth, (req,res,next) ->
        next()
    router.post '/login', (req,res) ->
        res.json {message: "Welcome!"}

    mealBaseTypeRouteFunction = require './meal_base_routes'
    [meal_base_route] = mealBaseTypeRouteFunction(router, authFunctions, models, dbFunctions,utils)

    mealTypeRouteFunction = require './meal_type_routes'
    [meal_route,past_meals_route] = mealTypeRouteFunction(router, authFunctions, models, dbFunctions,utils)

    energyLevelTypeRouteFunction = require './energy_level_type_routes'
    energy_levels_routes = energyLevelTypeRouteFunction(router, authFunctions, models, dbFunctions,utils)

    stomachPainTypeRouteFunction = require './stomach_pain_type_routes'
    stomachPainTypeRoutes = stomachPainTypeRouteFunction(router, authFunctions, models, dbFunctions,utils)

    sicknessTypeRouteFunction = require './sickness_type_routes'
    sicknessTypeRoutes = sicknessTypeRouteFunction(router, authFunctions, models, dbFunctions,utils)

    bmTypeRouteFunction = require './bowel_movement_type_routes'
    bmTypeRoutes = bmTypeRouteFunction(router, authFunctions, models, dbFunctions,utils)

module.exports = routeFunction
