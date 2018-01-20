CREATE VIEW duplicateRowIds AS
SELECT Key,
RowID,
ODRReference,
DataRecipient,
OrganisationType
FROM PHE
WHERE RowId IN
(SELECT rowid
FROM PHE
GROUP BY RowId
HAVING COUNT(RowId)>1
);

CREATE VIEW dataTypeProvided AS 
SELECT DataTypeProvidedTo, 
COUNT(DataTypeProvidedTo) AS "count" 
FROM PHE 
GROUP BY DataTypeProvidedTo 
ORDER BY "count" DESC;

------------------------------------

CREATE VIEW dataRecipients AS
SELECT dataRecipient, 
COUNT(dataRecipient) AS "count" 
FROM PHE 
GROUP BY dataRecipient 
ORDER BY "count" DESC;

------------------------------------

CREATE VIEW legalBasisForTheRelease AS
SELECT LegalBasisForRelease, 
COUNT(LegalBasisForRelease) AS "count" 
FROM PHE 
GROUP BY LegalBasisForRelease 
ORDER BY "count" DESC;

------------------------------------

CREATE VIEW orgType AS
SELECT OrganisationType, 
COUNT(OrganisationType) AS "count" 
FROM PHE 
GROUP BY OrganisationType 
ORDER BY "count" DESC;

------------------------------------

CREATE VIEW outlyingOrganisationalTypes AS
SELECT OrganisationType, group_concat(DataRecipient, '
') AS recipients,
COUNT(OrganisationType) AS "count" 
FROM phe 
GROUP BY OrganisationType 
HAVING COUNT(OrganisationType) < 10 
ORDER BY "count" DESC;

------------------------------------

CREATE VIEW dataSources AS 
SELECT DataSource, COUNT(DataSource) AS "count" 
FROM PHE 
GROUP BY DataSource 
ORDER BY "count" DESC;

------------------------------------

CREATE VIEW personalDataReleases AS
SELECT DataTypeProvidedTo, 
COUNT(DataTypeProvidedTo) AS "count" 
FROM PHE 
WHERE DataTypeProvidedTo = 'Personally identifiable' 
GROUP BY DataTypeProvidedTo 

UNION 

SELECT 'not immediately identifiable', 
COUNT(DataTypeProvidedTo) AS "count" 
FROM PHE 
WHERE dataTypeProvidedTo != 'Personally identifiable' 
ORDER BY "count" desc;

------------------------------------
-- pick out legal bases
CREATE VIEW noLegalReqdKeys AS
SELECT "Key" 
FROM PHE
WHERE LegalBasisForRelease = 'No legal gateway required';

CREATE VIEW s251ReqdKeys AS
SELECT "Key"
FROM PHE
WHERE LegalBasisForRelease LIKE '%s251%';

CREATE VIEW otherLegalBasesKeys AS
SELECT "Key"
FROM PHE 
WHERE NOT "Key" IN
(
    SELECT "Key" FROM noLegalReqdKeys
    
    UNION
    
    SELECT "Key" FROM s251ReqdKeys
)
;

-- counts of no legal / s251 / the rest
CREATE VIEW legalBasesReqd2 AS
SELECT 'No legal gateway required' AS LegalBasisForRelease
,COUNT(Key) AS "count" 
FROM noLegalReqdKeys

UNION

SELECT 's251 required' AS LegalBasisForRelease
,COUNT(Key) AS "count" 
FROM s251ReqdKeys

UNION

SELECT 'Other legal required' AS LegalBasisForRelease
,COUNT(Key) AS "count" 
FROM otherLegalBasesKeys

ORDER BY "count" DESC;

------------------------------------

CREATE VIEW legalBasesReqd AS
SELECT LegalBasisForRelease, 
COUNT(LegalBasisForRelease) AS "count" 
FROM PHE 
WHERE LegalBasisForRelease = 'No legal gateway required' 
GROUP BY LegalBasisForRelease 

UNION 

SELECT 'legal basis required', 
COUNT(LegalBasisForRelease) AS "count" 
FROM PHE 
WHERE LegalBasisForRelease != 'No legal gateway required' 
ORDER BY "count" desc;

------------------------------------

CREATE VIEW linkDetails AS
SELECT * FROM PHE
WHERE purpose LIKE '%link%'
ORDER BY DataTypeProvidedTo,
LegalBasisForRelease;

------------------------------------

CREATE VIEW organisationsWithOtherLegal AS 
SELECT DISTINCT DataRecipient
, OrganisationType
, DataTypeProvidedTo
, LegalBasisForRelease
FROM PHE 
WHERE "Key" IN
( SELECT "Key" 
    FROM otherLegalBasesKeys
)
ORDER BY DataRecipient;

------------------------------------

CREATE VIEW organisationsWithNoLegal AS 
SELECT DISTINCT DataRecipient
, OrganisationType
, DataTypeProvidedTo
, LegalBasisForRelease
FROM PHE 
WHERE "Key" IN
( SELECT "Key" 
    FROM noLegalReqdKeys
)
ORDER BY DataRecipient;

------------------------------------

CREATE VIEW commercialOrganisationsDetails AS 
SELECT Key  
, RowID   
, ODRReference    
, DataRecipient   
, OrganisationType    
, substr(Purpose,1,100) || '...' AS shortPurpose
, DataSource  
, DataTypeProvidedTo  
, LegalBasisForRelease    
, DateOfRelease
FROM PHE 
WHERE OrganisationType='Commercial'
ORDER BY DataRecipient, DateOfRelease;

------------------------------------
