prompt = require 'prompt'
colors = require 'colors/safe'
slug = require 'slug'
path = require 'path'
fs = require 'fs'

migrationFunctions= {}
config_path = process.cwd() + '/.migrate.coffee'

CONFIG = {}

# The models should be shared between migration files
timestamp_path = process.cwd() + '/.timestamp.json'

timestamp_CONFIG = {}


# Helpers

error = (msg) ->
    console.error colors.red(msg)
    process.exit 1

success = (msg) ->
  console.log colors.green(msg)

loadConfiguration = ()->
    try
        return require config_path
    catch e
        error 'Missing ' + config_path + ' file. Type `migrate init` to create.'

timestampConfiguration = () ->
    try
        return require(timestamp_path);
    catch e
        data = JSON.stringify { current_timestamp: 0 }, null, 2
        fs.writeFileSync timestamp_path, data

updateTimestamp = (timestamp, cb) ->
    timestamp_CONFIG.current_timestamp = timestamp
    data = JSON.stringify(timestamp_CONFIG, null, 2)
    fs.writeFile(timestamp_path, data, cb)

migrationFunctions.init = ()->

    if fs.existsSync(config_path)
        error(config_path + ' already exists!')

    schema =
        properties:
            basepath:
                description: 'Enter migrations directory'
                type: 'string'
                default: 'migrations'
        connection:
          description: 'Enter mongo connection string'
          type: 'string'
          required: true
    prompt.start()
    prompt.get schema, (error, result)->
      data = fs.readFileSync path.normalize(__dirname + '/migration_templates/config.coffee'), 'ascii'
      data = data
        .replace('MIGRATION_KEY', result.basepath)
        .replace('CONNECTION_KEY', result.connection)

      fs.writeFileSync(config_path, data)

      success(config_path + ' file created!\nEdit to add your models')
      process.exit()

migrationFunctions.createMigration = (description) ->

    CONFIG = loadConfiguration()
    timestamp_CONFIG = timestampConfiguration()

    timestamp = Date.now()
    migrationName = timestamp + '-' + slug(description) + '.coffee'
    template = path.normalize(__dirname + '/migration_templates/migration.coffee')
    filename = path.normalize(CONFIG.basepath + '/' + migrationName)

    # create migrations directory
    if not fs.existsSync(CONFIG.basepath)
        fs.mkdirSync(CONFIG.basepath)

    data = fs.readFileSync(template)
    fs.writeFileSync(filename, data)
    success('Created migration ' + migrationName)
    process.exit()

connnectDB = () ->
    # load local app mongoose instance
    mongoose = require 'mongoose'
    mongoose.connect(CONFIG.connection)
    # mongoose.set('debug', true);

loadModel = (model_name) ->
    return require(process.cwd() + '/' + CONFIG.models[model_name])

getTimestamp = (name) ->
    return parseInt((name.split('-'))[0])

migrationFunctions.migrate = (direction, cb, number_of_migrations)->

    CONFIG = loadConfiguration()
    timestamp_CONFIG = timestampConfiguration()

    if not number_of_migrations
        number_of_migrations = 1

    if direction == 'down'
        number_of_migrations = -1 * number_of_migrations

    migrations = fs.readdirSync(CONFIG.basepath)

    connnectDB()

    migrations = migrations.filter (migration_name) ->
        timestamp = getTimestamp(migration_name)

        if  number_of_migrations > 0
            return timestamp > timestamp_CONFIG.current_timestamp
        else if number_of_migrations < 0
            return timestamp <= timestamp_CONFIG.current_timestamp

    loopMigrations(number_of_migrations, migrations, cb)

loopMigrations = (direction, migrations, cb) ->

    if direction == 0 || migrations.length == 0
        return cb()

    if direction > 0
        applyMigration 'up', migrations.shift(), ()->
            direction--
            loopMigrations(direction, migrations, cb)
    else if (direction < 0)
        applyMigration 'down', migrations.pop(), () ->
            direction++
            loopMigrations(direction, migrations, cb)

applyMigration = (direction, name, cb)->
    migration = require(process.cwd() + '/' + CONFIG.basepath + '/' + name)
    timestamp = getTimestamp(name)

    success('Applying migration ' + name + ' - ' + direction);
    callback = ()->
        if direction == 'down'
            timestamp--
        updateTimestamp(timestamp, cb)
    migration[direction].call {model: loadModel}, callback

module.exports = migrationFunctions
