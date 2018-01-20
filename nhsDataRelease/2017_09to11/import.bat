@echo off

rem manually add key field to purposes ssheet

if exist release2017_09-11.db del release2017_09-11.db

echo "RowID","OrganisationName","us","DataProvided","Sensitive","LegalBasisForProvision","Purpose","OneOff","NICNumber","MRNumber","PatientOptOutsApplied"> releases.csv
sed -n -e 3,$p dataReleases2017_09-11.csv >> releases.csv

echo "Key","RefNumber","Organisation","Objective","ProcessingActivities","ExpectedOutput","ExpectedBenefits"> purposes.csv
sed -n -e 2,$p dataPurposes2017_09-11.csv >> purposes.csv

rem sort out extraneous whitespace as far as poss

sed -e "s/\x22NHS BLACKPOOL CCG \x22/\x22NHS BLACKPOOL CCG\x22/" releases.csv > DR0911Temp
move DR0911Temp releases.csv

sed -e "s/\xHealth and Social Care Act 2012 \x22/\x22Health and Social Care Actx22/" releases.csv > DR0911Temp
move DR0911Temp releases.csv


sed -e "s/\x22NHS REDBRIDGE CCG \x22/\x22NHS REDBRIDGE CCG\x22/" purposes.csv > DR0911Temp
move DR0911Temp purposes.csv

sed -e "s/\x22KENT COUNTY COUNCIL \x22/\x22KENT COUNTY COUNCIL\x22/" purposes.csv > DR0911Temp
move DR0911Temp purposes.csv

sed -e "s/\x22KENT COUNTY COUNCIL \x22/\x22KENT COUNTY COUNCIL\x22/" releases.csv > DR0911Temp
move DR0911Temp releases.csv

rem can't resolve weird white space issue
rem sed -e "s/\x22NHS *NEWBURY *AND *DISTRICT *CCG *\x22/\x22NHS NEWBURY AND DISTRICT CCG\x22/g" purposes.csv > DR0911Temp
rem move DR0911Temp purposes.csv
rem 
rem sed -e "s/\x22NHS *NEWBURY *AND *DISTRICT *CCG *\x22/\x22NHS NEWBURY AND DISTRICT CCG\x22/g" releases.csv > DR0911Temp
rem move DR0911Temp releases.csv

sed -e "s/\x22NHS OXFORDSHIRE  CCG\x22/\x22NHS OXFORDSHIRE CCG\x22/" purposes.csv > DR0911Temp
move DR0911Temp purposes.csv

sed -e "s/\x22NHS ISLINGTON  CCG \x22/\x22NHS ISLINGTON CCG\x22/" purposes.csv > DR0911Temp
move DR0911Temp purposes.csv

sed -e "s/\x22NHS TOWER HAMLETS CCG \x22/\x22NHS TOWER HAMLETS CCG\x22/" purposes.csv > DR0911Temp
move DR0911Temp purposes.csv

sqliteimport release2017_09-11.db purposes.csv
sqliteimport release2017_09-11.db releases.csv

sqlite3 release2017_09-11.db "CREATE UNIQUE INDEX uniq_purp ON purposes(Key);"
sqlite3 release2017_09-11.db "CREATE UNIQUE INDEX uniq_rel ON releases(RowID);"

rem release2017_09-11.db
