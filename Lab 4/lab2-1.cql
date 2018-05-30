create

// Special ingredients
  (chocolatechips:Ingredient {name: "chocolatechips"}),
  (raisin:Ingredient {name: "raisin"}),
  (apricot:Garnish {name: "apricot"}),

// Cooks
    (Tim:Chef {name: "Tim Maelzer"}),
    (Gordon:Chef {name: "Gordon Ramsey"}),
    (Alfons:Chef {name: "Alfons Schuhbeck"}),

// Create some recipes
    (pancake:Cake {name: "Pancake"}),
        (pancake)-[:CONTAINS {quantity: 25, unit: "grams"}]->(selfraising),
        (pancake)-[:CONTAINS {quantity: 25, unit: "grams"}]->(butter),
        (pancake)-[:CONTAINS {quantity: 300, unit: "grams"}]->(milk),
        (pancake)-[:CONTAINS {quantity: 125, unit: "grams"}]->(sugar),
        (pancake)-[:CONTAINS {quantity: 2, unit: "whole"}]->(egg),
        (pancake)-[:GARNISHED_WITH {how: "sprinkled"} ]->(apple),
        (pancake)-[:GARNISHED_WITH {how: "good whip"} ]->(cream),

    (muffin:Cake {name: "Muffin"}),
        (muffin)-[:CONTAINS {quantity: 250, unit: "grams"}]->(white),
        (muffin)-[:CONTAINS {quantity: 25, unit: "grams"}]->(butter),
        (muffin)-[:CONTAINS {quantity: 125, unit: "grams"}]->(sugar),
        (muffin)-[:CONTAINS {quantity: 100, unit: "grams"}]->(milk),
        (muffin)-[:GARNISHED_WITH {how: "chopped on top"} ]->(apple),
        (muffin)-[:GARNISHED_WITH {how: "good whip"} ]->(cream),

    (cookie:Cake {name: "Cookie"}),
        (cookie)-[:CONTAINS {quantity: 250, unit: "grams"}]->(white),
        (cookie)-[:CONTAINS {quantity: 50, unit: "grams"}]->(butter),
        (cookie)-[:CONTAINS {quantity: 250, unit: "grams"}]->(sugar),
        (cookie)-[:CONTAINS {quantity: 250, unit: "grams"}]->(milk),
        (cookie)-[:GARNISHED_WITH {how: "chopped on top"} ]->(orange),

// Relationships
    (Tim)-[:CREATES {popularity: 80, servedLastWeek: 200}]->(pancake),
    (Gordon)-[:CREATES {popularity: 55, servedLastWeek: 96}]->(muffin),
    (Alfons)-[:CREATES {popularity: 99, servedLastWeek: 550}]->(cookie),
    (Tim)-[:CREATES {popularity: 68, servedLastWeek: 10}]->(fruitCake),
    (Gordon)-[:CREATES {popularity: 79, servedLastWeek: 122}]->(brownies),
    (Alfons)-[:CREATES {popularity: 22, servedLastWeek: 1}]->(scones),
    (Tim)-[:CREATES {popularity: 30, servedLastWeek: 33}]->(brownscones),
    (Gordon)-[:CREATES {popularity: 68, servedLastWeek: 50}]->(applescones),
    (Alfons)-[:CREATES {popularity: 60, servedLastWeek: 71}]->(bmousse)
