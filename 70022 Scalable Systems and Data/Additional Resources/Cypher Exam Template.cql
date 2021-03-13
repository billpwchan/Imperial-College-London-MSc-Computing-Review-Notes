// EXAMINATION QUETSIONS PLACEHOLDER


// Match on relationship type and use a variable
MATCH (wallstreet { title: 'Wall Street' })<-[r:ACTED_IN]-(actor)
RETURN r.role

// [:TYPE*minHops..maxHops]→. minHops and maxHops are optional and 
// default to 1 and infinity respectively
MATCH (charlie { name: 'Charlie Sheen' })-[:ACTED_IN*1..3]-(movie:Movie)
RETURN movie.title

// Returns the movie itself as well as actors and directors one relationship away
MATCH (wallstreet:Movie { title: 'Wall Street' })-[*0..1]-(x)
RETURN x


// 19-20 Neo4j Questions
match (o:order {ID: 123}) - [:EMPLOYEE] -> () - [:EMPLOYEE_TERRITORRY] -> () - [:REGION] -> (r:Region)
return collect(distinct r.name)

match (o:order {ID: 123}) - [:CUSTOMER|SHIPPER] -> (p)
return distinct p.name

match (s:shipper) <- [:SHIPPER] - (o:order) - [:ORDER_DETAIL] -> (p:product) - [:SUPPLIER] -> (sup: supplier)
return s.name, count(p), collect(s.name)


// Names of all customers who work with an Employee named Mark but who have never
// ordered product from a supplier by the name of Jeff
MATCH (c:customer) 
 WHERE NOT (c:customer)<-[:CUSTOMER]-(o:order)-[:ORDER-DETAIL]-()-[:SUPPLIER]-(s:supplier {name: 'Jeff'})
 AND (c:customer)<-[:CUSTOMER]-(o:order)-[:EMPLOYEE]-(e:employee {name: 'Mark'})
 RETURN c.name

MATCH(c: Customer) - [:CUSTOMER] - () - [:EMPLOYEE] - (e: Employee {name: ‘Mark’}) 
WHERE NOT EXISTS { 
        MATCH(c: Customer) - [:CUSTOMER] - () - [:ORDER_DETAIL] - () - [:SUPPLIER] - (s: Supplier {name: ‘Jeff’}) 
} 
RETURN c.name 

// 18-19 Neo4j Questions
// Find out how many books each publisher has published by author
// and list all editors who have work on books written by each author
match (a)-[:wrote]->(b)-[:published_by]->(p), (e)-[:edits]->(b)  
return p.name, a.name, count(b), collect(e.name) 

// Names of all editors who work for publisher which published books that the reader
// Mark read but who have not edited Mark's books
MATCH (r:reader {name:'Mark'})-[:reads]->(b:book)-[:published_by]->(p:publisher)<-[:works_for]-(e:editor)
WHERE NOT EXISTS((r:reader)-[:reads]->(b:book)<-[:edits]-(e:editor))
RETURN distinct e.name

// 17-18 Neo4j Questions
// Find flights with one stop from Seattle to San Francisco
MATCH (seattle)<-[:Origin]-(f1)-[:Destination]->(s)<-[:Origin]-(f2)-[:Destination]->(sf) 
WHERE seattle.name = “Seattle” AND sf.name = “San Francisco” 
AND ((f1.time < f2.time AND f1.date = f2.date) OR f1.date < f2.date)
AND f1.number = f2.number
RETURN distinct f1, f2; 

// # FLIGHTS PER AIRLINE ARE ORIGINATING FROM EACH CITY
MATCH (a:Airport)<-[:Origin]-(f:Flight)
RETURN DISTINCT a.name, count(DISTINCT f.airline)

// All airports that can be reached from Seattle through between 2 - 5 stops
MATCH (seattle)<-[:Origin]-(f1)-[:Destination]->(s1), (s1)<-[:Origin]-(f2)-[:Destination]->(s2) 
OPTIONAL MATCH  (s2)<-[:Origin]-(f3)-[:Destination]->(s3) 
OPTIONAL MATCH  (s3)<-[:Origin]-(f4)-[:Destination]->(s4) 
OPTIONAL MATCH  (s4)<-[:Origin]-(f5)-[:Destination]->(s5) 
WHERE seattle.name = “Seattle” 
RETURN s2, s3, s4, s5; 

// 16-17 Neo4j Questions
// Count the different categories from which a customer with the name C has ordered
// Returned the count and the name of the category
MATCH (c:Customer {name:'C'})-[:PURCHASED]->()-[:ORDERS]->()-[:PART_OF]->(cat:category)
RETURN DISTINCT cat.name, count(cat)

// Find all products, orders as well as suppliers that are related to category C. Use a query with one relationship only
MATCH (c)<-[:PART_OF|SUPPLIES|ORDERS*1..2]-(o) 
WHERE c.name = C 
RETURN DISTINCT o; 

// 15-16 Neo4j Questions
// Find the venue where the biggest number of matches will be played
MATCH (m)-[:played_at]->(v) 
RETURN v, count(m) 
ORDER BY count(m) DESC 
LIMIT 1; 

// Find all the matches India has played along with the venues where they have been
// played as well as the unpires. 
MATCH (o)<-[:played|played_at|umpired_in*]-(t) 
WHERE t.name = “India” 
RETURN o; 

MATCH (O)<-[:*1..2]-(T:Teams {name:'India'})
return O
