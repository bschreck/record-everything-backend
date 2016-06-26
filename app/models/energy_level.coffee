mongoose = require 'mongoose'
Schema = mongoose.Schema
[RatingName,Rating] = require './rating'

EnergyLevelSchema = Rating.discriminator 'EnergyLevel',
    new mongoose.Schema({})

EnergyLevel = mongoose.model 'EnergyLevel', EnergyLevelSchema
module.exports = ["EnergyLevel",EnergyLevel]
