@echo off
Title Manual Ranker for Stuff by Dr.Fuff v0.5
Color 1e
:: version date = 30/07/2020  ;DD/MM/YYYY
:: command for ranking chars using select.def
:: made for games with tons of chars or people wishing to rank a collection

:: This is an large edit of the RANDOM-BATTLE command by Inktrebuchet and uses segments of code
:: Credit to Inktrebuchet for the original RANDOM-BATTLE command
:: [website link here]
::--------------------------------------------------------------------------------------------------------

:: USER VARIABLES

:: your system.def file path
SET system=bM1point0/brokenMUGEN/def/systemEDIT.def

:: your select.def file path (usually data/select.def)
SET select=./data/bM1point0/brokenSELECT.def

:: set character you wish to rank
SET rankie=kfm

:: line number of first character for selection range
SET min=1

:: line number of last character for selection range
SET max=1

:: the characters (P1) ai (1=watch mode, 0=you're playing)
SET ai=1

:: number of rounds
SET rounds=3

:: loops with or without prompt (1=auto play, 0=waits for input after match finishes)
SET forever-mode=1

:: Stage for ranking (include ".def" at the end, "randomselect" if you want random stages)
SET stage=randomselect

::--------------------------------------------------------------------------------------------------------
::DO NOT EDIT PAST THIS POINT (or save a backup first :))

:: check if stage is "randomselect"
if NOT "%stage%"=="randomselect" goto skip-random-stage


::-------------- START GET STAGES ---------------
::counts number of stages in "stages" folder.
cd stages
for /f %%a in ('dir /b *.def^|find /c /v "" ') do set scount=%%a
cd ..

::print all stage names in stages.txt
echo RANDOM-BATTLE STAGES LIST >stages.txt
cd stages
dir /b *.def >> ../stages.txt
cd ..

set /a srand = %random% %%scount +1
for /f "skip=%srand% tokens=*" %%I in (stages.txt) do (
    set stage=%%I
    goto :stage-result
)
:stage-result
set stage=%stage:*:=%
::-------------- END GET STAGES -----------------


:skip-random-stage

set charcount=0

::Ask the user if they want the allchars.txt file updated
set /p updatetxt=type (y) if you wish to update allchars.txt 
if NOT "%updatetxt%"=="y" goto :skip-char-read


::------------ START SELECT CONVERSION ------------
if exist allchars.txt (del allchars.txt)

::adds all characters from select.def to allchars.txt
Echo BEGINNING FILE READ.  ENJOY MUSIC :)
start Elevator-music.mp3
for /f "skip=%min% eol=r tokens=*" %%I in (%select%) do (echo %%I>>newfile.txt)
for /f "eol=- tokens=*" %%A in (newfile.txt) do (echo %%A>>last.txt)
del newfile.txt
for /f "eol=s tokens=*" %%B in (last.txt) do (echo %%B>>newfile.txt)
del last.txt
Echo HALF WAY THERE I PROMISE ;)
for /f "eol=; tokens=*" %%C in (newfile.txt) do (echo %%C>>last.txt)
del newfile.txt
for /f "eol=[ tokens=*" %%D in (last.txt) do (echo %%D>>newfile.txt)
del last.txt
find /V "arcade.maxmatches" newfile.txt >> last.txt
del newfile.txt
find /V "team.maxmatches" last.txt >> almostdone.txt
del last.txt
for /f "skip=4 tokens=*" %%E in (almostdone.txt) do (echo %%E>>allchars.txt & set /A charcount = charcount + 1)
del almostdone.txt
goto :get-char
::------------- END SELECT CONVERSION ------------

::debug
:skip-char-read
for /f "tokens=*" %%E in (allchars.txt) do (set /A charcount = charcount + 1)
Echo Total Characters = %charcount%

::looks for a random character
:get-char
set /a targetchar=%RANDOM% %%charcount +1
echo %targetchar%
set /a skip= targetchar -1

::get the random character's file path
::echo at file
for /f "skip=%skip% delims=, tokens=1" %%I in (allchars.txt) do (
    set char1=%%I
    goto :char1-result
)
:char1-result
set char1=%char1:*:=%

::get the random character's catagory
::echo at catagory
set searchC=%skip%
:catagory1-repeat
if /i "%searchC%" EQU "-1" (
    set catagory1="ERROR: file ended"
    goto :skip-comments
    )
for /f "skip=%searchC% delims=, tokens=3" %%I in (allchars.txt) do (
    set catagory1=%%I
    goto :catagory1-result
) 
:catagory1-result
set catagorytemp=%catagory1:*€=%
set catagory1=%catagory1:*;=%
if "%catagory1%" == "%catagorytemp%" (
    set /a searchC= searchC -1
    goto :catagory1-repeat
)
::remove leading spaces
set catagory1=%catagory1%##
set catagory1=%catagory1:  ##=##%
set catagory1=%catagory1: ##=##%
set catagory1=%catagory1:##=%

::get the character's author
::echo at author
set searchA=%searchC%
:author1-repeat
if /i "%searchA%" EQU "-1" (
    set author1="ERROR: file ended"
    goto :skip-comments
    )
for /f "skip=%searchA% delims=, tokens=3" %%I in (allchars.txt) do (
    set author1=%%I
    goto :author1-result
) 
:author1-result
set authortemp=%author1:*€=%
set authortemp=%authortemp:*;=%
for /f "delims=/ tokens=1" %%I in ("%authortemp%") do (
    set author1=%%I
    goto :set-author1
)
:set-author1
set author1=%author1:*€=%
if "%author1%" == "%authortemp%" (
    set /a searchA= searchA -1
    goto :author1-repeat
)
::removes following spaces
set author1=%author1%##
set author1=%author1:  ##=##%
set author1=%author1: ##=##%
set author1=%author1:##=%

:skip-comments
::get the random character's rank
for /f "skip=%skip% delims=, tokens=3" %%I in (allchars.txt) do (
    set rank1=%%I
    goto :rank1-result
)
:rank1-result
set rank1=%rank1:*:=%
set rank1=%rank1:order=%
for /f %%a in ("%rank1%") do set rank1=%%a

::get the random character's real name (kinda)
for /f "delims=/ tokens=2" %%I in ("%char1%") do (
    set name1=%%I
    goto :get-name1
)
:get-name1
set name1=%name1:*:=%

set command=mugen -r %system% -rounds %rounds% -p1.ai %ai% "%char1%" -p2.ai 1 "%rankie%" -s %stage:.def=%

::what shows up before the game runs the command
CLS
echo.
echo. %name1% [%catagory1%] by %author1% [order%rank1%]
echo.                   -==V.S==-
echo. %rankie% 
echo.                   -=STAGE=-
echo.                   %stage:.def=%
echo.
echo the line number for the character was %targetchar%
echo game would start with:
::echo mugen -r %select% -rounds %rounds% -p1.ai %ai% %char1% -p2.ai 1 %rankie% -s stages/%stage%
echo %command%
echo.
%command%

::stops the madness or not depending on settings
if %forever-mode%==1 goto get-char
echo use ctrl+c to exit, or
pause

goto :get-char