@echo off
Title Manual Ranker for MUGEN by Dr.Fuff v0.6
Color 1e
:: version date = 18/08/2020  ;DD/MM/YYYY
:: command for ranking chars using select.def
:: made for games with tons of chars or people wishing to rank a collection

:: This is an large edit of the RANDOM-BATTLE command by Inktrebuchet and uses segments of code
:: Credit to Inktrebuchet for the original RANDOM-BATTLE command
:: Batch file and similar tools found here -->( https://mugenguild.com/forum/topics/inks-batch-files--176361.0.html )
:: I would recommend using the orginial RANDOM-BATTLE if you only intend to use this batch for the random battle functions

:: Please note:
:: This batch is made to only work with a specfic structure of select.def and is tested that way.  This is CERTAINLY
:: not going to work as intended, if at all, with any game.  In the future, if this project gets enough support I *might*
:: make something to contruct a select.def file in a way that gets it to work.

::--------------------------------------------------------------------------------------------------------

:: USER VARIABLES
:: these are made to be changed to meet your preferences

:: your system.def file path
SET system=bM1point0/brokenMUGEN/def/systemEDIT.def

:: your select.def file path (usually data/select.def)
SET select=./data/bM1point0/brokenSELECT.def

:: set character on the left ("randomselect" for random)
SET player1=randomselect

:: set character on the right ("randomselect" for random) 
SET player2=FoFFF

:: line number of first character for selection range
SET min=1

:: line number of last character for selection range
SET max=10000

:: the characters (P1) ai (1=watch mode, 0=you're playing)
SET ai=1

:: number of rounds (to win)
SET rounds=1

:: loops with or without prompt (1=auto play, 0=waits for input after match finishes)
SET forever-mode=1

:: Stage for ranking (include ".def" at the end, "randomselect" if you want random stages)
SET stage=StageZeroGreen.def

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
::This is horrible coding, please optimise
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
for /f "tokens=*" %%E in (allchars.txt) do ( set /A charcount = charcount + 1)
Echo Total Characters = %charcount%


::will transfer player 1 information to player 2 and repeat get-char
set set1=0
set set2=0
set wasRandom1=0
set wasRandom2=0
set wasChosen1=0
set wasChosen2=0

:randomselect-check1
if %wasRandom1%==1 goto :player1rand

if %wasChosen1%==1 goto :randomselect-check2

if %player1%==randomselect (
	:player1rand
	set set1=1
	set wasRandom1=1
	goto :get-char
)

::else/default
goto :find-char1

:randomselect-check2
if %wasRandom2%==1 goto :player2rand

if %wasChosen2%==1 goto :start-match

if %player2%==randomselect (
	:player2rand
	set set2=1
	set wasRandom2=1
	goto :get-char
)

::else/default
goto :find-char2

::gets a random char number for a random char or uses found char number
:get-char
set /a targetchar=%RANDOM% %%charcount +1
echo %targetchar%
::echo %targetchar%>>debugline.txt ::DEBUG::
:skip-get-char
set /a skip= targetchar -1

::get the random character's file path
::echo at file (DEBUG)
for /f "skip=%skip% delims=, tokens=1" %%I in (allchars.txt) do (
    set player=%%I
    goto :player-result
)
:player-result
set player=%player:*:=%

::get the random character's catagory
::echo at catagory (DEBUG)
set searchC=%skip%
:catagory-repeat
if /i "%searchC%" EQU "-1" (
    set catagory="ERROR: file ended"
    goto :skip-comments
    )
for /f "skip=%searchC% delims=, tokens=3" %%I in (allchars.txt) do (
    set catagory=%%I
    goto :catagory-result
) 
:catagory-result
set catagorytemp=%catagory:*€=%
set catagory=%catagory:*;=%
if "%catagory%" == "%catagorytemp%" (
    set /a searchC=searchC -1
    goto :catagory-repeat
)
::remove leading spaces
set catagory=%catagory%##
set catagory=%catagory:  ##=##%
set catagory=%catagory: ##=##%
set catagory=%catagory:##=%

::get the character's author
::echo at author (DEBUG)
set searchA=%searchC%
:author-repeat
if /i "%searchA%" EQU "-1" (
    set author="ERROR: file ended"
    goto :skip-comments
    )
for /f "skip=%searchA% delims=, tokens=3" %%I in (allchars.txt) do (
    set author=%%I
    goto :author-result
) 
:author-result
set authortemp=%author:*€=%
set authortemp=%authortemp:*;=%
for /f "delims=/ tokens=1" %%I in ("%authortemp%") do (
    set author=%%I
    goto :set-author
)
:set-author
set author=%author:*€=%
if "%author%" == "%authortemp%" (
    set /a searchA= searchA -1
    goto :author-repeat
)
::removes following spaces
set author=%author%##
set author=%author:  ##=##%
set author=%author: ##=##%
set author=%author:##=%

:skip-comments
::get the random character's rank
for /f "skip=%skip% delims=, tokens=3" %%I in (allchars.txt) do (
    set rank=%%I
    goto :rank-result
)
:rank-result
set rank=%rank:*:=%
set rank=%rank:order=%
for /f %%a in ("%rank%") do set rank=%%a

::get the random character's real name (kinda)
for /f "delims=/ tokens=2" %%I in ("%player%") do (
    set name=%%I
    goto :get-name
)
:get-name
set name=%name:*:=%

::add the information retreived at random to correct variables
if %set1%==1 goto :set-1

if %set2%==1 goto :set-2


:start-match
set command=mugen -r %system% -rounds %rounds% -p1.ai %ai% "%player1%" -p2.ai 1 "%player2%" -s %stage:.def=%

::what shows up before the game runs the command
CLS
echo.
echo. %name1% [%catagory1%] by %author1% [order%rank1%]
echo.                   -==V.S==-
echo. %name2% [%catagory2%] by %author2% [order%rank2%]
echo.                   -=STAGE=-
echo.                   %stage:.def=%
echo.
::echo the line number for the last character was %targetchar%
::echo game would start with:
::echo mugen -r %select% -rounds %rounds% -p1.ai %ai% %player1% -p2.ai 1 %rankie% -s stages/%stage%
::echo %command%
echo.
%command%

::stops the madness or not depending on settings
if %forever-mode%==1 goto :randomselect-check1
echo use ctrl+c to exit, or
pause

goto :randomselect-check1

::assigns the qualities to the correct character (????)
:set-1
set player1=%player%
set name1=%name%
set catagory1=%catagory%
set author1=%author%
set rank1=%rank%
set set1=0
goto :randomselect-check2

:set-2
set player2=%player%
set name2=%name%
set catagory2=%catagory%
set author2=%author%
set rank2=%rank%
set set2=0
goto :start-match

::finds the name given in the user variables
::infers that there is a 3 layered path (e.g. !Cluster1/boxer/boxer.def)
:find-char1
set lineNum=0
set set1=1
set findChar=%player1%
set wasChosen1=1
if "%set1%"=="0" (
	:find-char2
	set lineNum=0
	set set2=1
	::the next line will create an error if player2 contains 'round left bracket' or 'round right bracket'
	set findChar=%player2%
	set wasChosen2=1
)
::yeah, i'm being hella lazy with this one
find /n "%findChar%.def" allchars.txt > linenumber.txt
for /f "delims=[,] skip=2 eol= tokens=1" %%E in (linenumber.txt) do (set lineNum=%%E && goto :lineNum-result)
:lineNum-result
set lineNum=%lineNum:*:=%
set lineNum=%lineNum: =%
echo. %lineNum%
set targetchar=%lineNum%

del linenumber.txt
goto :skip-get-char
pause