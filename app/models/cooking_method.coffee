mongoose = require 'mongoose'
Schema = mongoose.Schema

CookingMethodSchema = new Schema
    name:
        type: String
        required: true
        enum: ["Bake","Roast","Broil","Grill","Microwave","Raw","Stir-Fry","Fry","Saute","Boil","Simmer"]

CookingMethodSchema.index {name: 1},{unique: true}
module.exports = mongoose.model 'CookingMethod', CookingMethodSchema
