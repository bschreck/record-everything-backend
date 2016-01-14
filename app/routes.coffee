routeFunction = (router,auth,models,dbFunctions,utils) ->
    router.use (req, res, next) ->
        console.log 'Something is happening.'
        next()


    router.get '/', (req,res) ->
        res.json {message: 'welcome to api!'}

    router.get '/login', (req, res) ->
        console.log "login route"

    loginFunctions = require './auth'
    router.all '*', auth, loginFunctions.loadUser

    mealTypeRouteFunction = require './meal_type_routes'
    [meals_route, meal_route,past_meals_route] = mealTypeRouteFunction(router, models, dbFunctions,utils)

    energyLevelTypeRouteFunction = require './energy_level_type_routes'
    [energy_levels_route, energy_level_route] = energyLevelTypeRouteFunction(router, models, dbFunctions,utils)

module.exports = routeFunction
