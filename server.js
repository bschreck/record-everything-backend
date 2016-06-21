require('coffee-script').register()
var utils = require('./utils');

var program = require('commander');
var prompt = require('prompt');
var colors = require('colors/safe');
var slug = require('slug');
var path = require('path');
var fs = require('fs');

migrations = require('./migrate')
//


//taken from npm module mongoose-migration and turned into coffeescript:
program
    .command('minit')
    .description('Init migrations on current path')
    .action(migrations.init);

program
  .command('mcreate <description>')
  .description('Create Migration')
  .action(migrations.createMigration);

program
  .command('mdown [number_of_migrations] (default = 1)')
  .description('Migrate down')
  .action(migrations.migrate.bind(null, 'down', process.exit));

program
  .command('mup [number_of_migrations]')
  .description('Migrate up (default command)')
  .action(migrations.migrate.bind(null, 'up', process.exit));

program
  .command('start')
  .description('Start server')
  .action(startServer)

program
  .command('startlocal')
  .description('Start server locally')
  .action(startLocal)

program.version(require('./package.json').version);

program.parse(process.argv);
// Default command ?
if (program.args.length === 0) {
    start();
    process.exit();
}
function startLocal() {
  var env = "local";
  start(env);
}
function startServer() {
  var env = "production";
  start(env);
}

function start(env) {

    var express = require('express');
    var app = express();

    var bodyParser = require('body-parser');

    app.use(bodyParser.json({limit: '50mb'}));
    app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));

    if (env == "local") {
      var port = process.env.PORT || 8080;
    } else {
      var port = process.env.PORT || 80;
    }
    console.log(port);

    var router = express.Router()
    app.use('/api', router);

    var mongoose = require('mongoose');
    mongoose.connect("mongodb://localhost:27017/recordEverythingDB");

    /*
     *var oauthserver = require('oauth2-server');
     *app.oauth = oauthserver({
     *    model: require('./app/oauth'),
     *    grants: ['password','authorization_code', 'refresh_token'],
     *    debug: true
     *});
     */

    var models = {};
    models.CookingMethod = require('./app/models/cooking_method')
    models.Ingredient = require('./app/models/ingredient')
    models.MealBase = require('./app/models/meal_base')
    models.Meal = require('./app/models/meal');
    models.PastMeal = require('./app/models/past_meal');
    models.Rating = require('./app/models/rating');
    models.EnergyLevel = require('./app/models/energy_level');
    models.StomachPain = require('./app/models/stomach_pain');
    models.Sickness = require('./app/models/sickness');
    models.BowelMovement = require('./app/models/bowel_movement');

    var dbFunctions = require('./app/db_functions');

    require('./app/routes')(router, models, dbFunctions, utils);

    app.listen(port);
}
