mongoose = require 'mongoose'
Schema = mongoose.Schema

RatingSchema = new Schema
    rating:
        type: Number
        required: true
    date:
        type: Date
        required: true
    username:
        type: String
        required: true

RatingSchema.index {username: 1, date: 1},{unique: true}
#TODO: in production:
#RatingSchema.set('autoIndex', false);

RatingSchema.methods.toFrontEnd = ->
    rating: this.rating
    date:   this.date


Rating = mongoose.model 'Rating', RatingSchema

EnergyLevelSchema = Rating.discriminator 'EnergyLevel',
    new mongoose.Schema({})

EnergyLevel = mongoose.model 'EnergyLevel', EnergyLevelSchema
module.exports =
    Rating: Rating
    EnergyLevel: EnergyLevel
