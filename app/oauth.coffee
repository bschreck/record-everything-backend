mongoose = require 'mongoose'
Schema = mongoose.Schema
model = {}

OAuthAccessTokensSchema = new Schema
  accessToken:
      type: String
  clientId:
      type: String
  userId:
      type: String
  expires:
      type: Date

OAuthRefreshTokensSchema = new Schema
  refreshToken:
      type: String
  clientId:
      type: String
  userId:
      type: String
  expires:
      type: Date

OAuthClientsSchema = new Schema
  clientId:
      type: String
  clientSecret:
      type: String
  redirectUri:
      type: String

OAuthUsersSchema = new Schema
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

OAuthAccessTokensModel = mongoose.model 'OAuthAccessTokens', OAuthAccessTokensSchema
OAuthRefreshTokensModel = mongoose.model 'OAuthRefreshTokens', OAuthRefreshTokensSchema
OAuthClientsModel = mongoose.model 'OAuthClients', OAuthClientsSchema
OAuthUsersModel = mongoose.model 'OAuthUsers', OAuthUsersSchema


# oauth2-server callbacks

model.getAccessToken = (bearerToken, callback) ->

  OAuthAccessTokensModel.findOne { accessToken: bearerToken }, callback

model.getClient = (clientId, clientSecret, callback) ->
  if clientSecret == null
    return OAuthClientsModel.findOne { clientId: clientId }, callback
  OAuthClientsModel.findOne {clientId: clientId, clientSecret: clientSecret }, callback

model.setClient = (clientId, clientSecret, redirectUri, callback) ->
    OAuthClientsModel.findOne {clientId: clientId, clientSecret: clientSecret }, (err, client) ->
        if err
            return callback err
        if client?
            return callback null, client._id
        else
            client = new OAuthClientsModel()
            client.clientId = clientId
            client.clientSecret = clientSecret
            client.redirectUri = redirectUri
            client.save (err) ->
                if err
                    return callback err
                return callback null, client._id



# This will very much depend on your setup, I wouldn't advise doing anything exactly like this but
# it gives an example of how to use the method to resrict certain grant types
model.grantTypeAllowed = (clientId, grantType, callback) ->

  if grantType in ['password','authorization_code','client_credentials','refresh_token']
    OAuthClientsModel.findOne {clientId: clientId }, (err, client) ->
      if err
          return callback err, false
      if client?
          return callback false, true
  else
    callback false, true

model.saveAccessToken = (token, clientId, expires, userId, callback) ->

  accessToken = new OAuthAccessTokensModel
    accessToken: token
    clientId: clientId
    userId: userId
    expires: expires

  accessToken.save callback

#
# Required to support password grant type
#
model.getUser = (username, password, callback) ->

    OAuthUsersModel.findOne { username: username, password: password }, (err, user) ->
        return callback err, if user? then user._id else false

model.setUser = (username, password, callback) ->

    OAuthUsersModel.findOne { username: username, password: password }, (err, user) ->
        if err
            return callback err
        if user?
            return callback "user #{username} already exists"
        else
            user = new OAuthUsersModel()
            user.username = username
            user.password = password
            user.save (err) ->
                if err
                    return callback err
                return callback null, user._id

#
# Required to support refreshToken grant type
#
model.saveRefreshToken = (token, clientId, expires, userId, callback) ->

  refreshToken = new OAuthRefreshTokensModel
    refreshToken: token
    clientId: clientId
    userId: userId
    expires: expires

  refreshToken.save callback

model.getRefreshToken = (refreshToken, callback) ->

  OAuthRefreshTokensModel.findOne { refreshToken: refreshToken }, callback

model.revokeRefreshToken = (refreshToken, callback) ->

  OAuthRefreshTokensModel.remove { refreshToken: refreshToken }, callback

module.exports = model
