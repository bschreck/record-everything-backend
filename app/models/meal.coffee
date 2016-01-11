mongoose = require 'mongoose'
Schema = mongoose.Schema

MealSchema = new Schema
    name:
        type: String
        required: true
    type:
        type: String
        required: true
    photo:
        type: String
        required: false
    date:
        type: Date
        required: true
    username:
        type: String
        required: true

MealSchema.index {username: 1, date: 1,type: 1, name: 1},{unique: true}
#TODO: in production:
#MealSchema.set('autoIndex', false);

MealSchema.methods.toFrontEnd = ->
    name:   this.name
    type:   this.type
    date:   this.date

module.exports = mongoose.model 'Meal', MealSchema
