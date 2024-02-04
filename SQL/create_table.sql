drop table IF EXISTS RaceResults;
drop table IF EXISTS Qualifying;
drop table IF EXISTS SprintRaces;
drop table IF EXISTS PitStops;
drop table IF EXISTS Circuits;
drop table IF EXISTS Constructors;
drop table IF EXISTS Drivers;
drop table IF EXISTS Status;
drop table IF EXISTS Races;

create table Circuits (
       circuitID 	       INTEGER NOT NULL, -- 1
       name		       VARCHAR(100), -- Yarowsky Circuit
       location		VARCHAR(100), -- Maryland
       country		VARCHAR(100), -- USA
       PRIMARY KEY (circuitID) 
);


create table Constructors (
       constructorID 	INTEGER NOT NULL, -- 1
       name		       VARCHAR(100), -- Yarowsky Team
       nationality		VARCHAR(100), -- American
       PRIMARY KEY (constructorID)
);

create table Drivers (
       driverID 	       INTEGER NOT NULL, -- 1
       fName		       VARCHAR(100), -- David
       lName		       VARCHAR(100), -- Yarowsky
       dob                  DATE, -- 1982-10-01
       nationality          VARCHAR(100), -- American
       PRIMARY KEY (driverID)
);

create table Status (
       statusID 	       INTEGER NOT NULL, -- 1
       description		VARCHAR(100), -- Finished
       PRIMARY KEY (statusID)
);

create table Races (
       raceID 	       INTEGER NOT NULL, -- 1
       year		       INTEGER, -- 2022
       round                INTEGER, -- 1
       circuitID            INTEGER, -- 1
       date                 DATE, -- 2022-12-17
       PRIMARY KEY (raceID)
);

create table RaceResults (
       raceID 	       INTEGER NOT NULL, -- 1
       driverID		INTEGER NOT NULL, -- 1
       constructorID		INTEGER NOT NULL, -- 1
       startPosition        INTEGER, -- 1
       finalPosition        INTEGER, -- 1
       points               INTEGER, -- 22
       fastestLapTime       TIME, -- 01:34.2
       statusID             INTEGER NOT NULL, -- 1
       FOREIGN KEY (raceID) REFERENCES Races(raceID),
       FOREIGN KEY (driverID) REFERENCES Drivers(driverID),
       FOREIGN KEY (constructorID) REFERENCES Constructors(constructorID),
       FOREIGN KEY (statusID) REFERENCES Status(statusID)
);

create table Qualifying (
       raceID 	       INTEGER NOT NULL, -- 1
       driverID		INTEGER NOT NULL, -- 1
       constructorID		INTEGER NOT NULL, -- 1
       finalPosition        INTEGER, -- 1
       FOREIGN KEY (raceID) REFERENCES Races(raceID),
       FOREIGN KEY (driverID) REFERENCES Drivers(driverID),
       FOREIGN KEY (constructorID) REFERENCES Constructors(constructorID)
);

create table SprintRaces (
       raceID 	       INTEGER NOT NULL, -- 1
       driverID		INTEGER NOT NULL, -- 1
       constructorID		INTEGER NOT NULL, -- 1
       startPosition        INTEGER, -- 1
       finalPosition        INTEGER, -- 1
       points               INTEGER, -- 3
       statusID             INTEGER, -- 1
       FOREIGN KEY (raceID) REFERENCES Races(raceID),
       FOREIGN KEY (driverID) REFERENCES Drivers(driverID),
       FOREIGN KEY (constructorID) REFERENCES Constructors(constructorID)

);

create table PitStops (
       raceID 	       INTEGER NOT NULL, -- 1
       driverID		INTEGER NOT NULL, -- 1
       numPitStops  INTEGER, -- 0
       FOREIGN KEY (raceID) REFERENCES Races(raceID),
       FOREIGN KEY (driverID) REFERENCES Drivers(driverID)
);
