mongoose = require 'mongoose'
Schema = mongoose.Schema

PastMealSchema = new Schema
    name:
        type: String
        requred: true
    type:
        type: String
        required: true
    count:
        type: Number
        required: true
    username:
        type: String
        required: true

PastMealSchema.index {username: 1,type: 1,name: 1},{unique: true}
#TODO: in production:
#PastMealSchema.set('autoIndex', false);

PastMealSchema.statics.incrementMeal = (name,type, username, callback)->
    model = this
    conditions = { name: name, type: type, username: username}
    this.find conditions, (err,past_meals) ->
        if past_meals.length == 0
            console.log "saving"
            past_meal = new model()
            past_meal.name = name
            past_meal.type = type
            past_meal.count = 1
            past_meal.username = username
            past_meal.save (err) ->
                if err
                    console.log "past meal save err:",err
        else
            console.log "updating"
            update = { $inc: { count: 1 }}
            options = {}
            console.log conditions
            console.log update
            model.update(conditions, update, options, callback)

PastMealSchema.statics.toFrontEnd = (pastMealsArray)->
    pastMeals = {}
    for pastMeal in pastMealsArray
        mealType = pastMeal.type
        if mealType not of pastMeals
            pastMeals[mealType] = {}
            pastMeals[mealType][pastMeal.name] = pastMeal.count
        else
            pastMeals[mealType][pastMeal.name] = pastMeal.count
    return pastMeals


module.exports = mongoose.model 'PastMeal', PastMealSchema
