mongoose = require 'mongoose'
Schema = mongoose.Schema

BowelMovementSchema = new Schema
    objectId:
        type: String
        required: true
        unique: true
    bsScale:
        type: Number
        required: true
        min: 1
        max: 7
    date:
        type: Date
        required: true
    duration:
        type: Number
        required: true
    username:
        type: String
        required: true

BowelMovementSchema.index {username: 1, date: 1},{unique: true}
BowelMovementSchema.index {objectId: 1},{unique: true}
#TODO: in production:
#RatingSchema.set('autoIndex', false);

BowelMovementSchema.methods.toFrontEnd = ->
    objectId: this.objectId
    bsScale: this.bsScale
    duration: this.duration
    date:   this.date


BowelMovement = mongoose.model 'BowelMovement', BowelMovementSchema

module.exports = ["BowelMovement",BowelMovement]
