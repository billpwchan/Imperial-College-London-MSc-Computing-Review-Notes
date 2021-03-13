// EXAMINATION PLACEHOLDER






// 15-16 MongoDB QUESTION

db.restaurant.find();
db.restaurant.find({
    "borough": "Bronx"
});
// Distinct restaurants that achieved a score of more than 90
db.restaurant.distinct({
    "grades.score": {
        $gt: 90
    }
});
// coord: [-73.1, 72.2]
db.restaurant.find({
    "address.coord.1": {
        $lt: -95.754168
    }
});
// Show certain columns with 'Wil' as first three letters in their names 
db.restaurant.find({
    "name": {
        $regex: /^Wil/
    }
}, {
    "restaurant_ID": 1,
    "name": 1,
    "borough": 1,
    "cuisine": 1
});
// Either this or not for a particular field
db.restaurant.find({
    $and: [{
            "borough": "Bronx"
        },
        {
            "cuisine": {
                $in: ["American", "Chinese"]
            }
        }
    ]
});

// Field between certain value range
db.restaurants.find({
        "address.coord.1": {
            $gt: 42,
            $lt: 52
        }
    })
    .sort({
        "name": 1,
        "address": 1,
        "address.coord.1": 1
    });

// Select all documents in the restaurants collection where the coordfield value is a double
db.restaurants.find({
    "address.coord": {
        $all: [{
            "$elemmatch": {
                $type: "double"
            }
        }]
    }
})

// Join two datasets. Origin restaurants, Second boroughs. using field Borough
db.restaurants.aggregate([{
    $lookup: {
        from: "boroughs",
        localField: "borough",
        foreignField: "borough",
        as: "borough_info"
    }
}]);

// Find all baked goods of type Donus with chocolate dough but without sugar topping
db.bakeware.find({
    $and: [{
            "type": "donut"
        },
        {
            "batters.batter": {
                $elemMatch: {
                    "type": "Chocolate"
                }
            }
        },
        {
            "toppings": {
                $not: {
                    $elemMatch: {
                        "type": "sugar"
                    }
                }
            }
        }
    ]
})