mongoose = require 'mongoose'
Schema = mongoose.Schema

MealBaseSchema = new Schema
    name:
        type: String
        required: true
    cookingMethods:
        type: [{type : mongoose.Schema.ObjectId, ref : 'CookingMethod'}]
    ingredients:
        type: [{type : mongoose.Schema.ObjectId, ref : 'Ingredient'}]
    username:
        type: String
        required: true
    objectId:
        type: String
        required: true
        unique: true
        index: true

MealBaseSchema.index {username: 1, name: 1},{unique: true}
#TODO: in production:
#MealBaseSchema.set('autoIndex', false);

MealBaseSchema.methods.toFrontEnd = ->
    #must be populated
    serverId:       this._id
    name:           this.name
    cookingMethods: (cm.name for cm in this.cookingMethods)
    ingredients:    (ing.name for ing in this.ingredients)
    jsonId:       this.objectId

module.exports = ["MealBase",mongoose.model 'MealBase', MealBaseSchema]
