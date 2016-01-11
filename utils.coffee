module.exports =
    mergeObjects: (obj1,obj2) ->
        for key of obj2
            if (obj2.hasOwnProperty(key))
                obj1[key] = obj2[key]

    roundDateToNearest10Min: (dateObject) ->
        coeff = 1000 * 60 * 10
        return new Date(Math.round(dateObject.getTime() / coeff) * coeff)
