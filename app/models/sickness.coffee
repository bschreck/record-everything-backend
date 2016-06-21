mongoose = require 'mongoose'
Schema = mongoose.Schema
Rating = require './rating'

SicknessSchema = Rating.discriminator 'Sickness',
    new mongoose.Schema({})

Sickness = mongoose.model 'Sickness', SicknessSchema
module.exports = Sickness
