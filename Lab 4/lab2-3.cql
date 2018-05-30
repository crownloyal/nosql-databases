// Query 1:
MATCH (c:Course {courseNr:"1"})-[:TAKESPLACEIN]-(r:Room)
RETURN c,r

// Query 2:
MATCH (s:Student {studentID:"1"})-[w:WORKSON]-(p:Project)
RETURN s.firstName,s.lastName,p.projectName,w.hours

// Query 3:
MATCH (p:Project {projectNr:"24"})-[w:WORKSON]-(s:Student)
RETURN p,s.lastName,w.hours

// Query 4:
MATCH (p:Project {projectNr:"24"})-[w:WORKSON]-(s:Student)
RETURN s.lastName,w.hours,p.projectName
ORDER BY s.lastName DESC
LIMIT 4

// Query 5:
MATCH (p:Project)-[w:WORKSON]-(s:Student)
WITH s, p, count(p) AS projectCount
WHERE projectCount >= 1
RETURN s.lastName, count(p)
ORDER BY count(p) DESC

// Query 6:
MATCH (p:Project)-[w:WORKSON]-(s:Student), (p2:Project)-[w2:WORKSON]-(s2:Student)
WHERE s.lastName = s2.lastName AND p = p2
RETURN p.projectNr, p.projectName, s.firstName, s2.firstName