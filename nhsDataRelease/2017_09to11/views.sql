/*
DROP TABLE IF EXISTS subSections;
DROP TABLE IF EXISTS sections;

CREATE TABLE "sections"
(
    id TEXT PRIMARY KEY NOT NULL,
    title TEXT NOT NULL,
    blurb TEXT NOT NULL
);

CREATE TABLE subSections
(
    parentId TEXT REFERENCES sections(id),
    id TEXT NOT NULL,
    title TEXT NOT NULL,
    blurb TEXT NOT NULL,
    PRIMARY KEY(parentId,id) ON CONFLICT ABORT
);
*/

DROP VIEW IF EXISTS sectionMarkdown;

CREATE VIEW sectionMarkdown AS
SELECT id
, '### ' || title || '

' || blurb || '

<iframe width="90%" src="' || id || '.html"></iframe>

[table](' || id || '.html)
' AS markdown
FROM sections;

DROP VIEW IF EXISTS subSectionMarkdown;

CREATE VIEW subSectionMarkdown AS
SELECT parentId
, id
, '#### ' || title || '

' || blurb || '

<iframe width="90%" src="' || parentId || '-' || id || '.html"></iframe>

[table](' || parentId || '-' || id || '.html)
' AS markdown
FROM subSections;

/*
join everything

SELECT DISTINCT 
releases."RowID" AS releaseID
, purposes."Key" AS purposeID
, releases.NICNumber
, releases.MRNumber
, releases.OrganisationName 
, releases.us 
, releases.DataProvided 
, releases.Sensitive 
, releases.LegalBasisForProvision 
, releases.Purpose 
, releases.OneOff 
, releases.PatientOptOutsApplied 
, purposes.Organisation
, purposes.Objective
, purposes.ProcessingActivities
, purposes.ExpectedOutput
, purposes.ExpectedBenefits
FROM purposes JOIN releases ON purposes.RefNumber=releases.NICNumber

*/

DROP VIEW IF EXISTS orgCheck;

CREATE VIEW orgCheck AS
SELECT DISTINCT 
releases."RowID" AS releaseID
, releases.NICNumber
, purposes.RefNumber
, releases.OrganisationName as releaseOrganisation
, purposes.Organisation AS purposeOrganisation
FROM purposes JOIN releases ON purposes.RefNumber=releases.NICNumber
WHERE releases.OrganisationName='NHS LANCASHIRE NORTH CCG'
AND purposes.Organisation='NHS SHROPSHIRE CCG'
ORDER BY releases.NICNumber;


DROP VIEW IF EXISTS "orgCheck-info";

CREATE VIEW "orgCheck-info" AS
SELECT DISTINCT 
releases.OrganisationName 
, purposes.Organisation
, releases.us 
, releases.DataProvided 
, releases.Sensitive 
, releases.LegalBasisForProvision 
--, releases.Purpose 
, releases.OneOff 
, releases.PatientOptOutsApplied 
, purposes.Objective
, purposes.ProcessingActivities
, purposes.ExpectedOutput
, purposes.ExpectedBenefits
FROM purposes JOIN releases
WHERE releases.OrganisationName='NHS LANCASHIRE NORTH CCG'
AND purposes.Organisation='NHS SHROPSHIRE CCG'
ORDER BY releases.OrganisationName 
;

DROP VIEW IF EXISTS allOrgs;

CREATE VIEW allOrgs AS
SELECT DISTINCT OrganisationName AS Organisation
FROM releases
UNION
SELECT DISTINCT Organisation
FROM purposes
ORDER BY Organisation;

DROP VIEW IF EXISTS "allOrgs-councilOrgs";

CREATE VIEW "allOrgs-councilOrgs" AS
SELECT Organisation FROM allOrgs
WHERE REGEXP('COUNCIL$', Organisation)=1
OR REGEXP('LONDON BOROUGH OF', Organisation)=1
OR REGEXP('BOROUGH COUNCIL \(UNITARY\)$', Organisation)=1
ORDER BY Organisation;

DROP VIEW IF EXISTS "allOrgs-ccgOrgs";

CREATE VIEW "allOrgs-ccgOrgs" AS
SELECT Organisation FROM allOrgs
WHERE REGEXP('CCG$', Organisation)=1
ORDER BY Organisation;

DROP VIEW IF EXISTS "allOrgs-hospitalOrgs";

CREATE VIEW "allOrgs-hospitalOrgs" AS
SELECT Organisation FROM allOrgs
WHERE REGEXP('HOSPITAL', Organisation)=1
OR REGEXP('NHS FOUNDATION TRUST', Organisation)=1
OR Organisation='SOUTHAMPTON GENERAL HOSPTIAL' -- duh
ORDER BY Organisation;

DROP VIEW IF EXISTS "allOrgs-universityOrgs";

CREATE VIEW "allOrgs-universityOrgs" AS
SELECT Organisation FROM allOrgs
WHERE Organisation NOT IN 
(SELECT Organisation FROM "allOrgs-hospitalOrgs")
AND REGEXP('UNIVERSITY', Organisation)=1
ORDER BY Organisation;

DROP VIEW IF EXISTS "allOrgs-otherOrgs";

CREATE VIEW "allOrgs-otherOrgs" AS
SELECT Organisation FROM allOrgs

EXCEPT

SELECT Organisation FROM
(
SELECT Organisation FROM "allOrgs-councilOrgs"

UNION

SELECT Organisation FROM "allOrgs-ccgOrgs"

UNION

SELECT Organisation FROM "allOrgs-hospitalOrgs"

UNION

SELECT Organisation FROM "allOrgs-universityOrgs"
) AS Organisation
ORDER BY Organisation;

DROP VIEW IF EXISTS "otherOrgsInfo";

CREATE VIEW "otherOrgsInfo" AS
SELECT DISTINCT 
releases.OrganisationName 
, purposes.Organisation
, releases.us 
, releases.DataProvided 
, releases.Sensitive 
, releases.LegalBasisForProvision 
--, releases.Purpose 
, releases.OneOff 
, releases.PatientOptOutsApplied 
, purposes.Objective
, purposes.ProcessingActivities
, purposes.ExpectedOutput
, purposes.ExpectedBenefits
FROM purposes JOIN releases ON purposes.RefNumber=releases.NICNumber
WHERE releases.OrganisationName IN 
(SELECT Organisation FROM "allOrgs-otherOrgs")
ORDER BY releases.OrganisationName 
;

/*
DROP VIEW IF EXISTS "linkyMatchyBridgy";

CREATE VIEW "linkyMatchyBridgy" AS
SELECT DISTINCT 
releases.OrganisationName 
, purposes.Organisation
, releases.us 
, releases.DataProvided 
, releases.Sensitive 
, releases.LegalBasisForProvision 
--, releases.Purpose 
, releases.OneOff 
, releases.PatientOptOutsApplied 
, purposes.Objective
, purposes.ProcessingActivities
, purposes.ExpectedOutput
, purposes.ExpectedBenefits
FROM purposes JOIN releases ON purposes.RefNumber=releases.NICNumber
WHERE REGEXP('link|match| bridg', lower(Objective))=1
OR REGEXP('link|match| bridg', lower(ProcessingActivities))=1
OR REGEXP('link|match| bridg', lower(ExpectedOutput))=1
ORDER BY releases.OrganisationName 
;
*/
/*
SELECT 
PatientOptOutsApplied
,COUNT("PatientOptOutsApplied") AS "Count"
FROM releases
GROUP BY PatientOptOutsApplied;

SELECT 
OneOff
,COUNT("OneOff") AS "Count"
FROM releases
GROUP BY OneOff;

SELECT 
LegalBasisForProvision
,COUNT("LegalBasisForProvision") AS "Count"
FROM releases
GROUP BY LegalBasisForProvision
ORDER BY "Count" DESC;

SELECT
DataProvided
,COUNT("DataProvided") AS "Count"
FROM releases
GROUP BY DataProvided
ORDER BY "Count" DESC;

SELECT
us
,COUNT("us") AS "Count"
FROM releases
GROUP BY us
ORDER BY "Count" DESC;



SELECT DISTINCT 
Objective
,COUNT("Objective") AS "Count"
FROM purposes
GROUP BY Objective
ORDER BY "Count" DESC

SELECT DISTINCT 
ProcessingActivities
,COUNT("ProcessingActivities") AS "Count"
FROM purposes
GROUP BY ProcessingActivities
ORDER BY "Count" DESC


'frequent flyers'
*/