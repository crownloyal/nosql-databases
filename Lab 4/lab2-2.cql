// Query 2:
MATCH (n:Cake)-[]->(i:Ingredient)
RETURN n,i

// Query 3:
MATCH (n:Cake {name: "Brownies"})-[]->(i:Ingredient)
RETURN n,i

// Query 4:
MATCH (n:Cake)-[]->(f:Flour)
RETURN n,f

// Query 5:
MATCH (n:Cake)-[]->(i:Ingredient)
WHERE i.name="milk" OR i.name="cream"
RETURN n,i

// Query 6:
MATCH (c:Chef)-[cr:CREATES]->(food:Cake)
RETURN c,food

//Query 7:
MATCH (c:Chef)-[cr:CREATES]->(food:Cake)
RETURN c,sum(cr.servedLastWeek)

// Query 8:
MATCH (food:Cake)-[c:CONTAINS]->(ing:Ingredient)
RETURN ing, COLLECT(food) as foods
ORDER BY SIZE(foods) DESC LIMIT 5

// Query 9:
MATCH (food:Cake)-[c:CONTAINS]->(ing:Ingredient)
RETURN ing, COLLECT(food) as foods
ORDER BY SIZE(foods) ASC LIMIT 5

// Query 10:
MATCH (c:Cake)-[]->(i:Ingredient),
      (c2:Cake)-[]->(i2:Ingredient)
WITH c, c2, collect(i) AS ingre
RETURN c, c2, ingre, size(ingre) AS score
ORDER BY score DESC