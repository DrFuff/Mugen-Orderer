@echo off
Title Manual Ranker for Stuff by Dr.Fuff v0.4
Color 1e
:: version date = 28/07/2019  ;DD/MM/YYYY
:: command for ranking chars using select.def
:: made for games with tons of chars or people wishing to rank a collection

:: This is an large edit of the RANDOM-BATTLE command by Inktrebuchet and uses segments of code
:: Credit to Inktrebuchet for the original RANDOM-BATTLE command
:: [website link here]
::--------------------------------------------------------------------------------------------------------

:: USER VARIABLES

:: your select.def file path (usually data/select.def)
SET select=.\brokenSELECT.def

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

:: Stage for ranking (include ".def" at the end, "randomselect" if you want random stages)
SET stage=randomselect

::--------------------------------------------------------------------------------------------------------

:: check if stage is "randomselect"
if NOT "%stage%"=="randomselect" goto skip-random-stage

::counts number of stages in "stages" folder.
cd stages
for /f %%a in ('dir /b *.def^|find /c /v "" ') do set scount=%%a
cd ..

::print all stage names in stages.txt
echo RANDOM-BATTLE STAGES LIST >stages.txt
cd stages
dir /b *.def >> ../stages.txt
cd ..

:skip-random-stage

set charcount=0
::Ask the user if they want the allchars.txt file updated
set /p updatetxt=type (y) if you wish to update allchars.txt 
if NOT "%updatetxt%"=="y" goto :skip-char-read

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

:skip-char-read
for /f "skip=4 tokens=*" %%E in (allchars.txt) do (set /A charcount = charcount + 1)
Echo Total Characters = %charcount%

::looks for a random character
:get-char
set /a targetchar=%RANDOM% %%charcount +1
echo %targetchar%
set /a skip= targetchar - 1

::get the random character's file path
for /f "skip=%skip% delims=, tokens=1" %%I in (allchars.txt) do (
    set char1=%%I
    goto :char1-result
)
:char1-result
set char1=%char1:*:=%

::get the random character's rank
for /f "skip=%skip% delims=, tokens=3" %%I in (allchars.txt) do (
    set rank1=%%I
    goto :rank1-result
)
:rank1-result
set rank1=%rank1:*:=%

echo rand char: %char1%  %rank1%

timeout 5
echo you can stop the music now :)

pause
