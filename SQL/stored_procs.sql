DELIMITER //

-- Views
CREATE OR REPLACE VIEW RacePointsView AS
SELECT RR.driverID, RR.constructorID, R.circuitID, year, RR.points
FROM Races AS R, RaceResults AS RR
WHERE R.raceID = RR.raceID; //

CREATE OR REPLACE VIEW AccidentsView AS
SELECT A.name, A.location, A.accidents, COUNT(R.circuitID) AS numRaces
FROM (
    SELECT C.circuitID, C.name, C.location, COUNT(C.circuitID) AS accidents
    FROM Circuits AS C, Races AS R, RaceResults AS RR
    WHERE C.circuitID = R.circuitID AND
        R.raceID = RR.raceID AND
        (RR.statusID = 3 OR RR.statusID = 4) 
    GROUP BY C.circuitID
) AS A, Races AS R
WHERE A.circuitID = R.circuitID
GROUP BY R.circuitID; //

CREATE OR REPLACE VIEW RaceWinnersView AS
SELECT RR.raceID, RR.driverID, R.circuitID
FROM Races AS R, RaceResults AS RR
WHERE R.raceID = RR.raceID AND
    RR.finalPosition = 1; //



--DRIVERS 
CREATE OR REPLACE PROCEDURE D1()
BEGIN
    SELECT DISTINCT D.fname AS firstName, D.lname AS lastName
    FROM Drivers AS D, Qualifying AS Q
    WHERE D.driverID = Q.driverID AND Q.finalPosition = 1
    ORDER BY D.lname ASC;
END; //


CREATE OR REPLACE PROCEDURE D2()
BEGIN
    SELECT 
        D.nationality,
        COUNT(DISTINCT D.driverID) AS numDrivers,
        SUM(RR.points) / COUNT(DISTINCT R.year) AS AveragePointsPerSeason
    FROM Drivers D
    JOIN RaceResults RR ON D.driverID = RR.driverID
    JOIN Races R ON RR.raceID = R.raceID
    GROUP BY D.nationality
    ORDER BY 
        COUNT(DISTINCT D.driverID) DESC;
END; //


CREATE OR REPLACE PROCEDURE D3()
BEGIN
    SELECT 
        D.nationality AS DriverNationality,
        COUNT(DISTINCT R.raceID) AS TotalRaces,
        SUM(RR.points) AS TotalPoints,
        AVG(RR.points) AS AveragePointsPerRace
    FROM Drivers D
    JOIN RaceResults RR ON D.driverID = RR.driverID
    JOIN Races R ON RR.raceID = R.raceID
    WHERE R.year >= (SELECT MAX(year) - 5 FROM Races)
    GROUP BY D.nationality
    ORDER BY AveragePointsPerRace DESC;
END; //


CREATE OR REPLACE PROCEDURE D4()
BEGIN
    SELECT 
        CONCAT(D.fName, ' ', D.lName) AS DriverName,
        D.nationality AS DriverNationality,
        C.name AS ConstructorName,
        R.year AS RaceYear,
        -- R.round AS RaceRound,
        R.raceID AS Race,
        RR.FinalPosition AS RacePosition,
        RR.points AS PointsEarned
    FROM RaceResults RR
    JOIN Drivers D ON RR.driverID = D.driverID
    JOIN Constructors C ON RR.constructorID = C.constructorID
    JOIN Races R ON RR.raceID = R.raceID
    ORDER BY R.year DESC, R.round DESC, RR.FinalPosition ASC;
END; //


CREATE OR REPLACE PROCEDURE D5()
BEGIN
    SELECT 
        CASE 
            WHEN TIMESTAMPDIFF(YEAR, D.dob, R.date) < 25 THEN 'Under 25'
            WHEN TIMESTAMPDIFF(YEAR, D.dob, R.date) BETWEEN 25 AND 34 THEN '25 to 34'
            WHEN TIMESTAMPDIFF(YEAR, D.dob, R.date) BETWEEN 35 AND 44 THEN '35 to 44'
            ELSE '45 and above'
        END AS AgeBracket,
        COUNT(DISTINCT D.driverID) AS NumberOfDrivers,
        AVG(RR.finalPosition) AS AverageFinishPosition
    FROM Drivers D
    JOIN RaceResults RR ON D.driverID = RR.driverID
    JOIN Races R ON RR.raceID = R.raceID
    GROUP BY 
        CASE 
            WHEN TIMESTAMPDIFF(YEAR, D.dob, R.date) < 25 THEN 'Under 25'
            WHEN TIMESTAMPDIFF(YEAR, D.dob, R.date) BETWEEN 25 AND 34 THEN '25 to 34'
            WHEN TIMESTAMPDIFF(YEAR, D.dob, R.date) BETWEEN 35 AND 44 THEN '35 to 44'
            ELSE '45 and above'
        END
    ORDER BY AVG(TIMESTAMPDIFF(YEAR, D.dob, R.date));
END; //



-- CIRCUIT
CREATE OR REPLACE PROCEDURE C1()
BEGIN
    SELECT country, COUNT(circuitID) as numCircuits
    FROM Circuits
    GROUP BY country
    ORDER BY COUNT(country) DESC;
END; //

-- INPUT
CREATE OR REPLACE PROCEDURE C2(IN mycircuitID VARCHAR(100))
BEGIN
    SELECT CS.name AS ConstructorName, AVG(R.points) As AveragePoints
    FROM (
        SELECT P.constructorID, P.points
        FROM RacePointsView AS P
        WHERE P.circuitID = mycircuitID
    ) AS R, Constructors AS CS
    WHERE CS.constructorID = R.constructorID 
    GROUP BY R.constructorID
    ORDER BY AVG(R.points) DESC;
END; //

-- INPUT
CREATE OR REPLACE PROCEDURE C3(IN mycircuitID VARCHAR(100))
BEGIN
    SELECT 
        D.fname, 
        D.lname, 
        R.numWins,
        MIN(RR.fastestLapTime) AS FastestLapTime
    FROM (
        SELECT 
            W.driverID, 
            COUNT(W.raceID) AS numWins
        FROM RaceWinnersView AS W
        WHERE W.circuitID = mycircuitID
        GROUP BY W.driverID
    ) AS R
    JOIN Drivers AS D ON D.driverID = R.driverID
    JOIN RaceResults RR ON D.driverID = RR.driverID
    JOIN Races Ra ON RR.raceID = Ra.raceID AND Ra.circuitID = mycircuitID
    WHERE RR.FastestLapTime IS NOT NULL
    GROUP BY D.fname, D.lname, R.numWins
    ORDER BY R.numWins DESC, FastestLapTime;
END; //

-- RACES
CREATE OR REPLACE PROCEDURE R1()
BEGIN
    SELECT 
        CONCAT(D.fName, ' ', D.lName) AS DriverName,
        AVG(SR.finalPosition) AS AverageSprintRacePosition,
        AVG(RR.finalPosition) AS AverageRegularRacePosition
    FROM Drivers D
    JOIN SprintRaces SR ON D.driverID = SR.driverID
    JOIN RaceResults RR ON D.driverID = RR.driverID
    GROUP BY D.driverID;
END; //

-- INPUT
CREATE OR REPLACE PROCEDURE R2(IN myyear VARCHAR(100))
BEGIN
    SELECT 
        CONCAT(D.fName, ' ', D.lName) AS DriverName,
        COUNT(RR.raceID) AS TotalRaces,
        COUNT(CASE WHEN RR.FinalPosition = 1 THEN 1 ELSE NULL END) AS TotalWins,
        AVG(RR.FinalPosition) AS AverageFinishPosition,
        SUM(RR.points) AS TotalPoints    
    FROM Drivers D
    JOIN RaceResults RR ON D.driverID = RR.driverID
    JOIN Races R ON RR.raceID = R.raceID
    WHERE R.year = myyear
    GROUP BY D.driverID
    ORDER BY TotalPoints DESC, AverageFinishPosition DESC, TotalWins DESC;
END; //



-- ACCIDENTS & UNFINISHED STATUS
CREATE OR REPLACE PROCEDURE A1(IN myraceID VARCHAR(100))
BEGIN
    SELECT 
        R.raceID AS Race,
        R.year AS RaceYear,
        CONCAT(D.fName, ' ', D.lName) AS DriverName,
        RR.finalPosition,
        S.description AS IncidentDescription,
        RR.fastestLapTime
    FROM Races R
    JOIN RaceResults RR ON R.raceID = RR.raceID
    JOIN Drivers D ON RR.driverID = D.driverID
    JOIN Status S ON RR.statusID = S.statusID
    WHERE R.raceID = myraceID AND S.description LIKE '%accident%'
    ORDER BY RR.finalPosition;
END; //

-- INPUT YEAR
CREATE OR REPLACE PROCEDURE A2(IN myyear VARCHAR(100))
BEGIN
    SELECT 
        CONCAT(D.fName, ' ', D.lName) AS DriverName,
        SUM(CASE WHEN S.description LIKE '%accident%' THEN 1 ELSE 0 END) AS AccidentCount,
        COUNT(R.raceID) AS TotalRaces,
        ROUND((SUM(CASE WHEN S.description LIKE '%accident%' THEN 1 ELSE 0 END) * 100.0 / COUNT(R.raceID)), 2) AS AccidentPercentage
    FROM Races R
    JOIN RaceResults RR ON R.raceID = RR.raceID
    JOIN Drivers D ON RR.driverID = D.driverID
    JOIN Status S ON RR.statusID = S.statusID
    WHERE R.year = myyear 
    GROUP BY DriverName
    HAVING AccidentCount > 0
    ORDER BY AccidentPercentage DESC;
END; //


CREATE OR REPLACE PROCEDURE A3()
BEGIN
    SELECT 
        S.description AS Status,
        COUNT(RR.statusID) AS Frequency
    FROM RaceResults RR
    JOIN Status S ON RR.statusID = S.statusID
    WHERE S.description NOT LIKE 'Finished'
    GROUP BY S.description
    ORDER BY Frequency DESC;
END; //


CREATE OR REPLACE PROCEDURE A4()
BEGIN
    SELECT 
        CONCAT (D.fName, ' ', D.lName) AS DriverName,
        S.description AS IncidentType,
        COUNT(RR.statusID) AS IncidentCount
    FROM RaceResults RR
    JOIN Drivers D ON RR.driverID = D.driverID
    JOIN Status S ON RR.statusID = S.statusID
    WHERE S.description IN ('Accident', 'Engine', 'Gearbox', 'Mechanical', 'Electrical') 
    GROUP BY DriverName, IncidentType
    HAVING IncidentCount > 15
    ORDER BY IncidentCount DESC;
END; //

CREATE OR REPLACE PROCEDURE A5()
BEGIN
    SELECT 
        C.name AS CircuitName,
        C.location AS Location,
        C.country AS Country,
        COUNT(DISTINCT R.raceID) AS TotalRaces,
        COUNT(DISTINCT CASE WHEN S.description LIKE '%accident%' THEN R.raceID ELSE NULL END) AS AccidentRaces,
        ROUND((COUNT(DISTINCT CASE WHEN S.description LIKE '%accident%' THEN R.raceID ELSE NULL END) * 100.0 / COUNT(DISTINCT R.raceID)), 2) AS AccidentPercentage
    FROM Circuits C
    JOIN Races R ON C.circuitID = R.circuitID
    JOIN RaceResults RR ON R.raceID = RR.raceID
    JOIN Status S ON RR.statusID = S.statusID
    GROUP BY C.circuitID
    HAVING COUNT(DISTINCT R.raceID) > 0
    ORDER BY AccidentPercentage DESC, Country DESC;
END; //



-- PITSTOPS
-- INPUT
CREATE OR REPLACE PROCEDURE P1(IN mycircuitID VARCHAR(100))
BEGIN
    SELECT D.fname, D.lname, AVG(P.numPitStops) AS avgPits
        FROM (
            SELECT W.raceID, W.driverID
            FROM RaceWinnersView AS W
            WHERE W.circuitID = mycircuitID
        ) AS R, Drivers AS D, PitStops AS P
        WHERE D.driverID = R.driverID AND
            P.driverID = R.driverID AND
            P.raceID = R.raceID
        GROUP BY R.driverID
        ORDER BY AVG(P.numPitStops) ASC;
END; //

-- INPUT
CREATE OR REPLACE PROCEDURE P2(IN myraceID VARCHAR(100))
BEGIN
    SELECT 
        CONCAT (D.fName, ' ', D.lName) AS DriverName,
        R.raceID,
        RR.startPosition,
        RR.finalPosition,
        PS.numPitStops,
        (RR.startPosition - RR.finalPosition) AS PositionChange
    FROM 
        PitStops PS
    JOIN 
        Drivers D ON PS.driverID = D.driverID
    JOIN 
        RaceResults RR ON PS.raceID = RR.raceID AND PS.driverID = RR.driverID
    JOIN 
        Races R ON PS.raceID = R.raceID
    WHERE R.raceID = myraceID
    ORDER BY 
        R.raceID, PositionChange DESC;
END; //


-- GEOGRAPHIC LOCATION & PERFORMANCE
CREATE OR REPLACE PROCEDURE G1(IN myDriverName VARCHAR(100))
BEGIN
    SELECT 
        C.country AS CircuitCountry,
        CONCAT(D.fName, ' ', D.lName) AS DriverName,
        COUNT(RR.raceID) AS TotalRacesInCountry,
        AVG(RR.finalPosition) AS AverageFinishPosition,
        SUM(RR.points) AS TotalPoints
    FROM 
        Circuits C
    JOIN 
        Races R ON C.circuitID = R.circuitID
    JOIN 
        RaceResults RR ON R.raceID = RR.raceID
    JOIN 
        Drivers D ON RR.driverID = D.driverID
    WHERE 
        CONCAT(D.fName, ' ', D.lName) = myDriverName
    GROUP BY 
        C.country, D.driverID
    ORDER BY 
        C.country, AverageFinishPosition;
END; //

-- CONSTRUCTOR
CREATE OR REPLACE PROCEDURE CO1()
BEGIN
    SELECT 
        Co.nationality AS ConstructorNationality,
        COUNT(RR.raceID) AS TotalRaces,
        AVG(RR.finalPosition) AS AverageFinishPosition,
        SUM(RR.points) AS TotalPoints
    FROM Constructors Co
    JOIN RaceResults RR ON Co.constructorID = RR.constructorID
    JOIN Races R ON RR.raceID = R.raceID
    WHERE R.year >= YEAR(CURDATE()) - 5
    GROUP BY Co.nationality
    ORDER BY AverageFinishPosition, TotalPoints DESC;
END; //

CREATE OR REPLACE PROCEDURE CO2()
BEGIN
    SELECT 
        Co.name AS ConstructorName,
        COUNT(DISTINCT RR.raceID) AS TotalRaces,
        COUNT(DISTINCT CASE WHEN RR.finalPosition = 1 THEN RR.raceID ELSE NULL END) AS FirstPlaceFinishes,
        (COUNT(DISTINCT CASE WHEN RR.finalPosition = 1 THEN RR.raceID ELSE NULL END) * 100.0 / COUNT(DISTINCT RR.raceID)) AS FirstPlacePercentage
    FROM Constructors Co
    JOIN RaceResults RR ON Co.constructorID = RR.constructorID
    JOIN Races R ON RR.raceID = R.raceID
    WHERE R.year >= YEAR(CURDATE()) - 5
    GROUP BY Co.name
    ORDER BY FirstPlaceFinishes DESC;
END; //