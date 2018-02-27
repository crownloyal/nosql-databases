#------------------------------------------
#
# 1. We create the database and select it 
#
#------------------------------------------
CREATE DATABASE IF NOT EXISTS R00145447_MY_RENT_COMPANY;
USE R00145447_MY_RENT_COMPANY;
#
#------------------------------------------
#
# 2. We add the tables and its rows 
#
#------------------------------------------
#
#------------------------------------------
# 2.1. Table BRANCH
#------------------------------------------
#
CREATE TABLE BRANCH(
	branchNo  VARCHAR(4)    NOT NULL,
    street	VARCHAR(25),
    city	VARCHAR(20),
	postcode  VARCHAR(10),
PRIMARY KEY (branchNo)
);
#
INSERT INTO BRANCH VALUES('B005', '22 Deer Rd', 'London', 'SW1 4EH');
INSERT INTO BRANCH VALUES('B007', '16 Argyll St', 'Aberdeen', 'AB2 3SU');
INSERT INTO BRANCH VALUES('B003', '163 Main St', 'Glasgow', 'G11 9QX');
INSERT INTO BRANCH VALUES('B004', '32 Manse Rd', 'Bristol', 'BS99 1NZ');
INSERT INTO BRANCH VALUES('B002', '56 Clover Dr', 'London', 'NW10 6EU');
#
#------------------------------------------
# 2.2. Table STAFF
#------------------------------------------
#
CREATE TABLE STAFF(
    staffNo   VARCHAR(4)	NOT NULL,
	fName	VARCHAR(10),
	lName	VARCHAR(10),
    position	VARCHAR(12),
    gender	CHAR(1),           
    DOB	DATE,
    salary	INT,
    branchNo	VARCHAR(4),
PRIMARY KEY (staffNo),
FOREIGN KEY (branchNo) REFERENCES BRANCH(branchNo)
);
#
INSERT INTO STAFF VALUES('SL21', 'John', 'White', 'Manager','M', '1945-10-01', 30000,'B005');
INSERT INTO STAFF VALUES('SG37', 'Ann', 'Beech', 'Assistant','F', '1960-11-10', 12000,'B003');
INSERT INTO STAFF VALUES('SG14', 'David', 'Ford', 'Supervisor','M', '1958-03-24', 18000,'B003');
INSERT INTO STAFF VALUES('SA9', 'Mary', 'Howe', 'Assistant','F', '1970-02-19', 9000,'B007');
INSERT INTO STAFF VALUES('SG5', 'Susan', 'Brand', 'Manager','F', '1940-06-03', 24000,'B003');
INSERT INTO STAFF VALUES('SL41', 'Julie', 'Lee', 'Assistant','F', '1965-06-13', 9000,'B007');
#
#------------------------------------------
# 2.3. Table PRIVATE_OWNER
#------------------------------------------
#
CREATE TABLE PRIVATE_OWNER(
    ownerNo   VARCHAR(4)	NOT NULL,
	fName	VARCHAR(10),
	lName	VARCHAR(10),
    address	VARCHAR(30),
    telNo	VARCHAR(16),           
PRIMARY KEY (ownerNo)
);
#
INSERT INTO PRIVATE_OWNER VALUES('CO46', 'Joe', 'Keogh', '2 Fergus Dr, Aberdeen AB2 7SX','01224-861212');
INSERT INTO PRIVATE_OWNER VALUES('CO87', 'Carol', 'Farrel', '6 Achray St, Glasgow G32 9DX','0141-357-7419');
INSERT INTO PRIVATE_OWNER VALUES('CO40', 'Tina', 'Murphy', '63 Well St, Glasgow G42','0141-943-1728');
INSERT INTO PRIVATE_OWNER VALUES('CO93', 'Tony', 'Shaw', '12 Park Pl, Glasgow G4 0QR','0141-225-7025');
#
#------------------------------------------
# 2.4. Table PROPERTY_FOR_RENT	
#------------------------------------------
#
CREATE TABLE PROPERTY_FOR_RENT(
    propertyNo   VARCHAR(4)	NOT NULL,
	street	VARCHAR(25),
    city	VARCHAR(20),
	postcode  VARCHAR(10),
    type	VARCHAR(10),           
    rooms	INT,
    rent	INT,
	ownerNo   VARCHAR(4),
	staffNo   VARCHAR(4),	
    branchNo	VARCHAR(4),
PRIMARY KEY (propertyNo),
FOREIGN KEY (ownerNo) REFERENCES PRIVATE_OWNER(ownerNo),
FOREIGN KEY (staffNo) REFERENCES STAFF(staffNo),
FOREIGN KEY (branchNo) REFERENCES BRANCH(branchNo)
);
#
INSERT INTO PROPERTY_FOR_RENT VALUES('PA14', '16 Holhead', 'Aberdeen', 'AB7 5SU','House', 6, 650,'CO46', 'SA9','B007');
INSERT INTO PROPERTY_FOR_RENT VALUES('PL94', '6 Argyll St', 'London', 'NW2','Flat', 4, 400,'CO87', 'SL41','B005');
INSERT INTO PROPERTY_FOR_RENT VALUES('PG4', '6 Lawrence St', 'Glasgow', 'G11 9QX','Flat', 3, 350,'CO40', null,'B003');
INSERT INTO PROPERTY_FOR_RENT VALUES('PG36', '2 Manor Rd', 'Glasgow', 'G32 4QX','Flat', 3, 375,'CO93', 'SG37','B003');
INSERT INTO PROPERTY_FOR_RENT VALUES('PG21', '18 Dale Rd', 'Glasgow', 'G12','House', 5, 600,'CO87', 'SG37','B003');
INSERT INTO PROPERTY_FOR_RENT VALUES('PG16', '5 Novar Dr', 'Glasgow', 'G12 9AX','Flat', 4, 450,'CO93', 'SG14','B003');
#
#------------------------------------------
# 2.5. Table CLIENT	
#------------------------------------------
#
CREATE TABLE CLIENT(
    clientNo  VARCHAR(4)	NOT NULL,
	fName	VARCHAR(10),
	lName	VARCHAR(10),
    telNo	VARCHAR(16),
	prefType	VARCHAR(10),
	maxRent	INT,         
PRIMARY KEY (clientNo)
);
#
INSERT INTO CLIENT VALUES('CR76', 'John', 'Kay', '0207-774-5632','Flat', '425');
INSERT INTO CLIENT VALUES('CR56', 'Aline', 'Stewart', '0141-848-1825','Flat', '350');
INSERT INTO CLIENT VALUES('CR74', 'Mike', 'Ritchie', '01475-392178','House', '750');
INSERT INTO CLIENT VALUES('CR62', 'Mary', 'Tregear', '01224-196720','Flat', '600');
#
#------------------------------------------
# 2.6. Table VIEWING	
#------------------------------------------
#
CREATE TABLE VIEWING(
    clientNo  VARCHAR(4)	NOT NULL,
	propertyNo   VARCHAR(4)	NOT NULL,
	viewDate	DATE,
    comment	VARCHAR(20),     
PRIMARY KEY (clientNo,propertyNo),
FOREIGN KEY (clientNo) REFERENCES CLIENT(clientNo),
FOREIGN KEY (propertyNo) REFERENCES PROPERTY_FOR_RENT(propertyNo)
);
#
INSERT INTO VIEWING VALUES('CR56', 'PA14', '2016-01-24', 'too small');
INSERT INTO VIEWING VALUES('CR76', 'PG4', '2016-01-20', 'too remote');
INSERT INTO VIEWING VALUES('CR56', 'PG4', '2016-02-08', null);
INSERT INTO VIEWING VALUES('CR62', 'PA14', '2016-02-01', 'no dining room');
INSERT INTO VIEWING VALUES('CR56', 'PG36', '2016-01-16', Null);
#
#------------------------------------------
#
# 3. We COMMIT the actions performed 
#
#------------------------------------------
#
COMMIT;
#
select * from branch;

