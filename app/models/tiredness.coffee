mongoose = require 'mongoose'
Schema = mongoose.Schema
[RatingName, Rating] = require './rating'

TirednessSchema = Rating.discriminator 'Tiredness',
    new mongoose.Schema({})

Tiredness = mongoose.model 'Tiredness', TirednessSchema
module.exports = ["Tiredness", Tiredness]
