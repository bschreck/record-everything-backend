mongoose = require 'mongoose'
Schema = mongoose.Schema
model = {}

ClientsSchema = new Schema
  clientId:
      type: String
  clientSecret:
      type: String

UsersSchema = new Schema
  username:
      type: String
  password:
      type: String
  firstname:
      type: String
  lastname:
      type: String
  email:
      type: String
      default: ''

ClientsModel = mongoose.model 'Clients', ClientsSchema
UsersModel = mongoose.model 'Users', UsersSchema

model.getClient = (clientId, clientSecret, callback) ->
  console.log 'in getClient (clientId: ' + clientId + ', clientSecret: ' + clientSecret + ')'
  if clientSecret == null
    return ClientsModel.findOne { clientId: clientId }, callback
  ClientsModel.findOne {clientId: clientId, clientSecret: clientSecret }, callback

model.setClient = (clientId, clientSecret, redirectUri, callback) ->
    ClientsModel.findOne {clientId: clientId, clientSecret: clientSecret }, (err, client) ->
        if err
            return callback err
        if client?
            console.log "client #{clientId} already exists"
            return callback null, client._id
        else
            client = new ClientsModel()
            client.clientId = clientId
            client.clientSecret = clientSecret
            client.redirectUri = redirectUri
            client.save (err) ->
                if err
                    return callback err
                return callback null, client._id

model.getUser = (username, password, callback) ->
    console.log 'in getUser (username: ' + username + ', password: ' + password + ')'

    UsersModel.findOne { username: username, password: password }, (err, user) ->
        return callback err, if user? then user._id else false

model.setUser = (username, password, callback) ->
    console.log 'in setUser (username: ' + username + ', password: ' + password + ')'

    UsersModel.findOne { username: username, password: password }, (err, user) ->
        if err
            return callback err
        if user?
            console.log "user #{username} already exists"
            return callback "user #{username} already exists"
        else
            user = new UsersModel()
            user.username = username
            user.password = password
            user.save (err) ->
                if err
                    return callback err
                return callback null, user._id

module.exports = model
