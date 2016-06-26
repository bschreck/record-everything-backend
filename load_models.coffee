fs = require 'fs'
path = require 'path'
models = {}
fs.readdir './app/models',(err,files) ->
    for f in files
        if path.extname(f) is ".coffee"
            [modelName,model] = require "./app/models/#{f[..-8]}"
            models[modelName] = model
module.exports = models
