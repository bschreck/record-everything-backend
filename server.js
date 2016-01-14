require('coffee-script').register()
var utils = require('./utils');

var express = require('express');
var app = express();

var bodyParser = require('body-parser');

app.use(bodyParser.json({limit: '50mb'}));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));

var port = process.env.PORT || 8080;

var router = express.Router()
app.use('/api', router);

var mongoose = require('mongoose');
mongoose.connect("mongodb://localhost:27017/recordEverythingDB");

var models = {};
var Meal = require('./app/models/meal');
models.Meal = Meal;
var PastMeal = require('./app/models/past_meal');
models.PastMeal = PastMeal;
var ratingModels = require('./app/models/rating');
utils.mergeObjects(models, ratingModels);

var dbFunctions = require('./app/db_functions');

require('./app/routes')(router, models, dbFunctions, utils);

app.listen(port);
