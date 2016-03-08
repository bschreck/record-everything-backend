CONFIG =
  "basepath": "migrations"
  "connection": "mongodb://localhost:27017/recordEverythingDB"
  "models":
      "Meal": "app/models/meal.coffee"
      "MealBase": "app/models/meal_base.coffee"
      "CookingMethod": "app/models/cooking_method.coffee"
      "EnergyLevel": "app/models/energy_level.coffee"
      "Rating": "app/models/rating.coffee"
      "Ingredient": "app/models/ingredient.coffee"
      "PastMeal": "app/models/past_meal.coffee"
      "BowelMovement": "app/models/bowel_movement.coffee"

module.exports = CONFIG
