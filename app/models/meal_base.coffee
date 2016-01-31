mongoose = require 'mongoose'
Schema = mongoose.Schema

CookingMethodSchema = new Schema
    name:
        type: String
        required: true
        enum: ["Bake","Roast","Broil","Grill","Microwave","Raw","Stir-Fry","Fry","Saute","Boil","Simmer"]
CookingMethodSchema.index {name: 1},{unique: true}

IngredientSchema = new Schema
    name:
        type: String
        required: true

IngredientSchema.index {name: 1},{unique: true}

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

IngredientModel = mongoose.model 'Ingredient', IngredientSchema
CookingMethodModel = mongoose.model 'CookingMethod', CookingMethodSchema
MealBaseModel = mongoose.model 'MealBase', MealBaseSchema
module.exports =
    IngredientModel:    IngredientModel
    CookingMethodModel: CookingMethodModel
    MealBaseModel:      MealBaseModel
