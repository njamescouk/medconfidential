DROP TABLE IF EXISTS subSections;
DROP TABLE IF EXISTS sections;

CREATE TABLE sections
(
    id TEXT PRIMARY KEY NOT NULL,
    title TEXT NOT NULL,
    blurb TEXT NOT NULL,
    sql TEXT NOT NULL,
    seq INTEGER NOT NULL
);

CREATE TABLE subSections
(
    parentId TEXT REFERENCES sections(id),
    id TEXT NOT NULL,
    title TEXT NOT NULL,
    blurb TEXT NOT NULL,
    sql TEXT NOT NULL,
    PRIMARY KEY(parentId,id) ON CONFLICT ABORT
);

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


INSERT INTO sections (id,seq,title,blurb,sql)
SELECT 
'orgCheck'
,1
,'Possible discrepancy in organisations'
,'<p>apparent conflict of organisation names when joined on `purposes.RefNumber=releases.NICNumber`
for purposes NHS SHROPSHIRE CCG vs release NHS LANCASHIRE NORTH CCG</p>'
,'SELECT DISTINCT 
releases."RowID" AS releaseID
, releases.NICNumber
, purposes.RefNumber
, releases.OrganisationName as releaseOrganisation
, purposes.Organisation AS purposeOrganisation
FROM purposes JOIN releases ON purposes.RefNumber=releases.NICNumber
WHERE releases.OrganisationName=''NHS LANCASHIRE NORTH CCG''
AND purposes.Organisation=''NHS SHROPSHIRE CCG''
ORDER BY releases.NICNumber;'
;

INSERT INTO subSections (parentId,id,title,blurb,sql)
SELECT 
'orgCheck'
,'info'
,'NHS SHROPSHIRE CCG vs release NHS LANCASHIRE NORTH CCG'
,'<p>Info for NHS SHROPSHIRE CCG / release NHS LANCASHIRE NORTH CCG</p>'
,'SELECT DISTINCT 
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
WHERE releases.OrganisationName=''NHS LANCASHIRE NORTH CCG''
AND purposes.Organisation=''NHS SHROPSHIRE CCG''
ORDER BY releases.OrganisationName 
;'
;

INSERT INTO sections (id,seq,title,blurb,sql)
SELECT 
'allOrgs'
,2
,'All organisations'
,'<p>some highly probable duplicates in here</p>'
,'SELECT DISTINCT OrganisationName AS Organisation
FROM releases
UNION
SELECT DISTINCT Organisation
FROM purposes
ORDER BY Organisation;'
;

INSERT INTO subSections (parentId,id,title,blurb,sql)
SELECT 
'allOrgs'
,'councilOrgs'
,'Councils'
,'<p>Local councils</p>'
,'SELECT Organisation FROM allOrgs
WHERE REGEXP(''COUNCIL$|LONDON BOROUGH OF|BOROUGH COUNCIL \(UNITARY\)$'', Organisation)=1
ORDER BY Organisation;'
;

INSERT INTO subSections (parentId,id,title,blurb,sql)
SELECT 
'allOrgs'
,'ccgOrgs'
,'CCGs'
,'<p>CCGs</p>'
,'SELECT Organisation FROM allOrgs
WHERE REGEXP(''CCG$'', Organisation)=1
ORDER BY Organisation;'
;

INSERT INTO subSections (parentId,id,title,blurb,sql)
SELECT 
'allOrgs'
,'hospitalOrgs'
,'Hospitals'
,'<p>Hospitals</p>'
,'SELECT Organisation FROM allOrgs
WHERE REGEXP(''HOSPITAL||NHS FOUNDATION TRUST'', Organisation)=1
OR Organisation=''SOUTHAMPTON GENERAL HOSPTIAL'' -- duh
ORDER BY Organisation;'
;

INSERT INTO subSections (parentId,id,title,blurb,sql)
SELECT 
'allOrgs'
,'universityOrgs'
,'Universities'
,'<p>Universities.</p>'
,'SELECT Organisation FROM allOrgs
WHERE Organisation NOT IN 
(SELECT Organisation FROM "allOrgs-hospitalOrgs")
AND REGEXP(''UNIVERSITY'', Organisation)=1
ORDER BY Organisation;'
;

INSERT INTO subSections (parentId,id,title,blurb,sql)
SELECT 
'allOrgs'
,'otherOrgs'
,'Others'
,'<p>Others</p>'
,'SELECT Organisation FROM allOrgs

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
'
;

INSERT INTO sections (id,seq,title,blurb,sql)
SELECT 
'otherOrgsInfo'
,3
,'Other organisations purposes and releases'
,'<p>Other organisations purposes and releases</p>'
,'SELECT DISTINCT 
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
;'
;

/*
     +++++++++ This pans out as 60MB of html ! +++++++++ 

INSERT INTO sections (id,seq,title,blurb,sql)
SELECT 
'linkyMatchyBridgy'
,'Organisations linking matching or bridging'
,'<p>Info where `Objective`, `ProcessingActivities` or `ExpectedOutput` look like "link" "match" or " bridg".
This catches terms like "not linked", "not matched" etc etc.</p>'
,4
,'SELECT DISTINCT 
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
WHERE REGEXP(''link|match| bridg'', lower(Objective))=1
OR REGEXP(''link|match| bridg'', lower(ProcessingActivities))=1
OR REGEXP(''link|match| bridg'', lower(ExpectedOutput))=1
ORDER BY releases.OrganisationName 
;'
;
*/


/*
future pages?

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