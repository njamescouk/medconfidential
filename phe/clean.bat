@echo off
goto recreateCsv
for %%t in (PHE14-15 PHE15-16 PHE16-17 PHE17-18) do sed "s/ *(NEW) *//" %%t.csv > %%t.cleaned.csv
for %%t in (PHE14-15 PHE15-16 PHE16-17 PHE17-18) do move %%t.cleaned.csv %%t.csv

for %%t in (PHE14-15 PHE15-16 PHE16-17 PHE17-18) do sed "s/\(DRR[0-9]*\) */\1/" %%t.csv > %%t.cleaned.csv
for %%t in (PHE14-15 PHE15-16 PHE16-17 PHE17-18) do move %%t.cleaned.csv %%t.csv

for %%t in (PHE14-15 PHE15-16 PHE16-17 PHE17-18) do sed "s/\(DRR[0-9]*\) */\1/" %%t.csv > %%t.cleaned.csv
for %%t in (PHE14-15 PHE15-16 PHE16-17 PHE17-18) do move %%t.cleaned.csv %%t.csv

:recreateCsv
grep -v -h "Row ID" PHE14-15.csv PHE15-16.csv PHE16-17.csv PHE17-18.csv > PHEBare.csv

sed "s#CQC Registered Health or/and Social Care Provider#CQC Registered Health or/and Social Care provider#" PHEBare.csv > pheTemp
move pheTemp PHEBare.csv

sed "s#Regulation 5 (S251)#Regulation 5 (s251)#" PHEBare.csv > pheTemp
move pheTemp PHEBare.csv

sed "s/\x22DRR/LINENO_GOES_HERE,\x22DRR/" PHEBare.csv > pheTemp
move pheTemp PHEBare.csv

numberLines LINENO_GOES_HERE PHEBare.csv > pheTemp
move pheTemp PHEBare.csv

:recreateDB
echo "Key", "RowID","ODRReference","DataRecipient","OrganisationType","Purpose","DataSource","DataTypeProvidedTo","LegalBasisForRelease","DateOfRelease" > PHE.csv
type PHEBare.csv | sed "s/\(-[0-9][0-9]\),$/\1/" >> PHE.csv

if exist PHE.db del PHE.db
sqliteimport PHE.db PHE.csv

sqlite3 PHE.db < createViews.sql
