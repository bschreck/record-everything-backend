mongoose = require 'mongoose'
Schema = mongoose.Schema

IngredientSchema = new Schema
    name:
        type: String
        required: true

IngredientSchema.index {name: 1},{unique: true}

module.exports = ["Ingredient",mongoose.model 'Ingredient', IngredientSchema]
