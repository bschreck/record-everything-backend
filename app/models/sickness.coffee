mongoose = require 'mongoose'
Schema = mongoose.Schema
[RatingName, Rating] = require './rating'

SicknessSchema = Rating.discriminator 'Sickness',
    new mongoose.Schema({})

Sickness = mongoose.model 'Sickness', SicknessSchema
module.exports = ["Sickness", Sickness]
