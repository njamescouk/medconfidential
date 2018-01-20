@echo off
rem 
goto skip

create views corresponding to summaries
generate html of views
incorporate iframes of view pages in index

views are:
purposes - organisations
purposes - objectives containing %link% + org
purposes - processing activities containing %link% + org

as above  with %nhs number%

as above  with %shared%

check organisations appear in purposes and releases


:skip
rem ----------------------------------------


set REL0911_DBNAME=release2017_09-11.db
set REL0911_SQLITECMD=sqlite3 -init c:\bin\sqliterc

set REL0911_MARKDOWN=summary.md

rem install sections & subsections
%REL0911_SQLITECMD% %REL0911_DBNAME% < sections.sql
if not %ERRORLEVEL%==0 echo error line 32 & goto :eof

rem "list all orgs, subsections : ccg, hospital uni of etc"
%REL0911_SQLITECMD% %REL0911_DBNAME% -list -newline " " "SELECT id FROM sections ORDER BY seq;" > DR0911Temp
set /p REL0911_SECTIONS=<DR0911Temp

%REL0911_SQLITECMD% %REL0911_DBNAME% -list -newline " " "SELECT parentId || '-' || id FROM subSections;" > DR0911Temp
set /p REL0911_SUB_SECTIONS=<DR0911Temp

rem "install views"
%REL0911_SQLITECMD% %REL0911_DBNAME% < views.sql
if not %ERRORLEVEL%==0 echo error line 43 & goto :eof

rem rem "generate views"
rem rem extract sql from sect and ssect, run it
rem for %%t in (%REL0911_SECTIONS%) do call :makeSectionViews %%t
rem for %%t in (%REL0911_SUB_SECTIONS%) do call :makeSubSectionViews %%t

rem write html for section pages
del summaries\*.html
for %%t in (%REL0911_SECTIONS%) do %REL0911_SQLITECMD%  -csv -header %REL0911_DBNAME% "SELECT * FROM "%%t";" | csvrewrite -css summaries.css -s > summaries\%%t.html
if not %ERRORLEVEL%==0 echo error line 49 & goto :eof

rem write html for subsection pages (exactly as above but with REL0911_SUB_SECTIONS)
for %%t in (%REL0911_SUB_SECTIONS%) do %REL0911_SQLITECMD%  -csv -header %REL0911_DBNAME% "SELECT * FROM \"%%t\";" | csvrewrite -css summaries.css -s > summaries\%%t.html
if not %ERRORLEVEL%==0 echo error line 53 & goto :eof

rem write markdown
sdatetime | egrep -o [0-9]+-[0-9]+-[0-9]+ > DR0911Temp
set /p REL0911_DATE= < DR0911Temp
del DR0911Temp

rem heading
echo %% summary of [nhs digital release register](http://content.digital.nhs.uk/dataregister) for Sept to Nov 2017>%REL0911_MARKDOWN%
echo %% Nick James>>%REL0911_MARKDOWN%
echo %% %REL0911_DATE%>>%REL0911_MARKDOWN%
echo. >>%REL0911_MARKDOWN%
echo ---->>%REL0911_MARKDOWN%
echo. >>%REL0911_MARKDOWN%

echo Plenty to see here, amongst other gems, there is this from IMPERIAL COLLEGE LONDON: >>%REL0911_MARKDOWN%
echo. >>%REL0911_MARKDOWN%
echo #### 3)  Provision of a patient re-identification service for the NHS >>%REL0911_MARKDOWN%
echo. >>%REL0911_MARKDOWN%
echo ICL DFU provides a patient re-identification service for the NHS which allows NHS provider trusts to investigate issues around quality and safety of care within their organisation, which have arisen out of performance alerts arising out of ICL DFU analyses (e.g. mortality alerts), or arising from DFI performance tools using ICL DFU methods. Authorised individuals within Provider Trusts are able to identify their own patients indicated in the DFI healthcare performance tools.  >>%REL0911_MARKDOWN%

echo From April 2015 to April 2016, there were over 3,600 successful logins from 75 NHS provider organisations. 64 provider trusts have used it more than 12 times per year (once a month) and one trust has used the re-identification service 425 times within this period.  >>%REL0911_MARKDOWN%
echo. >>%REL0911_MARKDOWN%
echo --- >>%REL0911_MARKDOWN%
echo. >>%REL0911_MARKDOWN%


for %%t in (%REL0911_SECTIONS%) do call :makeSummaryMarkdown %%t

pandoc -c summaries.css -s -o summaries\index.html -t html5 %REL0911_MARKDOWN%

if not "%LOGONSERVER%"=="\\DESKTOPNEW2" goto skipGraph
%REL0911_SQLITECMD% %REL0911_DBNAME% ".schema" > create.sql
if not %ERRORLEVEL%==0 echo error line 73 & goto :eof
dbGraph create.sql > db.dot
dotpng db.dot
:skipGraph

set REL0911_SECTIONS=
set REL0911_SUB_SECTIONS=
set REL0911_MARKDOWN=
set REL0911_DATE=
set REL0911_DBNAME=
set REL0911_SQLITECMD=

goto :eof
rem ----------------------------------------

rem write section and subsections markdown
rem call with section.id
:makeSummaryMarkdown

rem write section markdown
%REL0911_SQLITECMD% %REL0911_DBNAME% "SELECT markdown FROM sectionMarkdown WHERE id='%1';">>%REL0911_MARKDOWN%
if not %ERRORLEVEL%==0 echo error line 94 & goto :eof
echo. >>%REL0911_MARKDOWN%

rem write sub section markdown
%REL0911_SQLITECMD% %REL0911_DBNAME% "SELECT markdown FROM subSectionMarkdown WHERE parentId='%1';">>%REL0911_MARKDOWN%
if not %ERRORLEVEL%==0 echo error line 99 & goto :eof
echo. >>%REL0911_MARKDOWN%

echo ---->>%REL0911_MARKDOWN%

goto :eof
rem ----------------------------------------



rem getting a bit too clever here
:makeSectionViews
echo on
%REL0911_SQLITECMD% %REL0911_DBNAME% "DROP VIEW IF EXISTS \"%1\";"
%REL0911_SQLITECMD% %REL0911_DBNAME% "SELECT 'CREATE VIEW \"%1\" AS ' || sql FROM sections WHERE id='%1';" | %REL0911_SQLITECMD% %REL0911_DBNAME% 
if not %ERRORLEVEL%==0 echo error line 112 & goto :eof
@echo off
goto :eof
rem ----------------------------------------

:makeSubSectionViews
echo on
%REL0911_SQLITECMD% %REL0911_DBNAME% "SELECT 'DROP VIEW IF EXISTS \"' ^|^| parentId ^|^| '-' ^|^| id ^|^| '\"; CREATE VIEW \"' ^|^| parentId ^|^| '-' ^|^| id ^|^| '\" AS ' || sql FROM subSections WHERE parentId || '-' || id ='%1';">DR0911Temp 
set /p REL0911_SQL=<DR0911Temp
%REL0911_SQLITECMD% %REL0911_DBNAME% < DR0911Temp
if not %ERRORLEVEL%==0 echo error line 119 & goto :eof
@echo off
set REL0911_SQL=
goto :eof
rem ----------------------------------------

