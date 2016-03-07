mongoose = require 'mongoose'
Schema = mongoose.Schema

RatingSchema = new Schema
    objectId:
        type: String
        required: true
        unique: true
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
RatingSchema.index {objectId: 1},{unique: true}
#TODO: in production:
#RatingSchema.set('autoIndex', false);

RatingSchema.methods.toFrontEnd = ->
    objectId: this.objectId
    rating: this.rating
    date:   this.date


Rating = mongoose.model 'Rating', RatingSchema

module.exports = Rating
