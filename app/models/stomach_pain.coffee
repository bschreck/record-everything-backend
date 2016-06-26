mongoose = require 'mongoose'
Schema = mongoose.Schema
[RatingName,Rating] = require './rating'

StomachPainSchema = Rating.discriminator 'StomachPain',
    new mongoose.Schema({})

StomachPain = mongoose.model 'StomachPain', StomachPainSchema
module.exports = ["StomachPain",StomachPain]
