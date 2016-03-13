mongoose = require 'mongoose'
Schema = mongoose.Schema

CookingMethodSchema = new Schema
    name:
        type: String
        required: true
        enum: ["Bake","Roast","Broil","Grill","Microwave","Raw","Stir-Fry","Fry","Pan-Fry","Saute","Boil","Simmer","Ferment"]

CookingMethodSchema.index {name: 1},{unique: true}
module.exports = mongoose.model 'CookingMethod', CookingMethodSchema
