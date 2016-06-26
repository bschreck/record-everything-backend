mongoose = require 'mongoose'
Schema = mongoose.Schema

#THIS IS THE ONE PLACE WHERE ALL COOKING METHODS ARE DEFINED
possible_cooking_methods = [
    "Bake","Roast","Broil","Grill",
    "Microwave","Raw","Stir-Fry",
    "Fry","Pan-Fry","Saute","Boil",
    "Simmer","Ferment", "Smoked", "Sous-Vide"
]
CookingMethodSchema = new Schema
    name:
        type: String
        required: true
        enum: possible_cooking_methods

CookingMethodSchema.index {name: 1},{unique: true}
module.exports = ["CookingMethod", mongoose.model 'CookingMethod', CookingMethodSchema]
