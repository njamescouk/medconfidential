@echo off
for %%t in (duplicateRowIds dataTypeProvided dataRecipients legalBasisForTheRelease orgType dataSources personalDataReleases legalBasesReqd outlyingOrganisationalTypes legalBasesReqd2 linkDetails organisationsWithOtherLegal organisationsWithNoLegal commercialOrganisationsDetails) do sqlite3 -csv -header PHE.db "SELECT * FROM %%t;" | csvrewrite -css summaries.css -s > summaries\%%t.html

pandoc -s -t html5 -o summaries\commentary.html summaries\commentary.md

