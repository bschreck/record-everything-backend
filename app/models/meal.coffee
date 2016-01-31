mongoose = require 'mongoose'
deepPopulate = (require 'mongoose-deep-populate') mongoose
Schema = mongoose.Schema

MealSchema = new Schema
    mealBase:
        type: mongoose.Schema.ObjectId
        ref: 'MealBase'
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
    objectId:
        type: String
        required: true
        unique: true
        index: true

MealSchema.index {username: 1, date: 1,type: 1, mealBase: 1},{unique: true}
#TODO: in production:
#MealSchema.set('autoIndex', false);
MealSchema.plugin deepPopulate, {}

MealSchema.methods.toFrontEnd = ->
    type:    this.type
    date:    this.date
    serverId: this._id
    jsonId: this.objectId

MealSchema.methods.baseObjectId = (callback)->
    this.model('MealBase').findById this.mealBase (err,mb)->
        callback err, mb.objectId

module.exports = mongoose.model 'Meal', MealSchema
