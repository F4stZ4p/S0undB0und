@echo off
color F0
set /P URI=< LastPlayed.ini
If "%URI%"=="" del -s -q LastPlayed.ini
If "%URI%"==" " del -s -q LastPlayed.ini
mode con cols=90 lines=20
title S0undB0und : An open-source YouTube music player!
echo -Last Action-----------------------------------------------------------------------------
echo # %time% %date% * Started S0undB0und
echo -----------------------------------------------------------------------------------------

:event_main.block
echo 1 - Stop playing music
echo 2 - Last played song
echo 3 - Play music from YouTube (URL)
echo 4 - Download song from any website (needs straight URL)
echo 5 - Replay song
echo 6 - Quit
set /p Action="Action: "
if %Action% lss 1 goto :event_client.error
if %Action% equ 1 goto :event_check.is.stopped
if %Action% equ 2 goto :event_check.substring.lastplayed
if %Action% equ 3 goto :event_enter.url
if %Action% equ 4 goto :event_download.song
if %Action% equ 5 goto :event_check.substring
if %Action% equ 6 goto :event_quit
if %Action% gtr 6 goto :event_client.error


:event_check.substring
set longString=%URI%
set tempStr=%longString:youtube=%
if "%longString%"=="%tempStr%" goto :event_substring.not.found
goto :event_replay.song


:event_check.substring.play.music
set longString=%URI%
set tempStr=%longString:youtube=%
if "%longString%"=="%tempStr%" goto :event_substring.not.found
goto :event_play.from.yt


:event_check.substring.lastplayed
set longString=%URI%
set tempStr=%longString:youtube=%
if "%longString%"=="%tempStr%" goto :event_substring.not.found
goto :event_last.played


:event_substring.not.found
cls
echo -Last Action-----------------------------------------------------------------------------
echo # %time% %date% * Invalid YouTube URL: %URI%
echo -----------------------------------------------------------------------------------------
goto :event_main.block


:event_replay.song
taskkill /f /im wscript.exe
taskkill /f /im iexplore.exe
cls
echo -Last Action-----------------------------------------------------------------------------
echo # %time% %date% * Started replaying %URI%
echo -----------------------------------------------------------------------------------------
if not exist LastPlayed.ini goto :event_file.not.exist.first
echo Visible = 0 > SoundEngine.vbs
echo Set objExplorer = WScript.CreateObject _ >> SoundEngine.vbs
echo ("InternetExplorer.Application", "IE_") >> SoundEngine.vbs
echo objExplorer.Navigate " %URI% " >> SoundEngine.vbs
echo objExplorer.Visible = 0 >> SoundEngine.vbs
echo Sub IE_onQuit() >> SoundEngine.vbs
echo Wscript.Quit >> SoundEngine.vbs
echo End Sub >> SoundEngine.vbs
start /min SoundEngine.vbs
goto :event_main.block


:event_last.played
if not exist LastPlayed.ini goto :event_file.not.exist.first
goto :event_check.iexplore


:event_file.not.exist.first
cls
echo -Last Action-----------------------------------------------------------------------------
echo # %time% %date% * LastPlayed.ini not found. Ignoring.
echo -----------------------------------------------------------------------------------------
goto :event_main.block


:event_download.song
cls
set /p DLURL="Download URL: "
set /p NAMEEXT="File name (with extension): "
echo Trying to get file from the Web...
powershell -command "(new-object System.Net.WebClient).DownloadFile('%DLURL%', '%NAMEEXT%')"
cls
echo -Last Action-----------------------------------------------------------------------------
echo # %time% %date% * Downloaded! Saved as %NAMEEXT%    
echo -----------------------------------------------------------------------------------------
goto :event_main.block


:event_client.error
cls
echo -Last Action-----------------------------------------------------------------------------
echo # %time% %date% * Invalid action!
echo -----------------------------------------------------------------------------------------
goto :event_main.block


:event_enter.url
cls
set /p URI="YouTube Video URL: "
goto :event_check.iexplore.second


:event_check.iexplore
@tasklist | find "iexplore.exe"
if errorlevel 1 goto :event_play.from.yt
if errorlevel 0 goto :event_iexplore.already.running

:event_check.iexplore.second
@tasklist | find "iexplore.exe"
if errorlevel 1 goto :event_check.substring.play.music
if errorlevel 0 goto :event_iexplore.already.running

:event_iexplore.already.running
cls
echo -Last Action-----------------------------------------------------------------------------
echo # %time% %date% * You can't start 2 players at one time.
echo -----------------------------------------------------------------------------------------
goto :event_main.block


:event_play.from.yt
cls
echo %URI% > LastPlayed.ini
echo -Last Action-----------------------------------------------------------------------------
echo # %time% %date% * Started playing %URI%
echo -----------------------------------------------------------------------------------------
echo Visible = 0 > SoundEngine.vbs
echo Set objExplorer = WScript.CreateObject _ >> SoundEngine.vbs
echo ("InternetExplorer.Application", "IE_") >> SoundEngine.vbs
echo objExplorer.Navigate " %URI% " >> SoundEngine.vbs
echo objExplorer.Visible = 0 >> SoundEngine.vbs
echo Sub IE_onQuit() >> SoundEngine.vbs
echo Wscript.Quit >> SoundEngine.vbs
echo End Sub >> SoundEngine.vbs
start /min SoundEngine.vbs
goto :event_main.block


:event_check.is.stopped
@tasklist | find "iexplore.exe"
cls
if errorlevel 1 goto :event_nothing.is.playing
if errorlevel 0 goto :event_stop.playing

:event_nothing.is.playing
echo -Last Action-----------------------------------------------------------------------------
echo # %time% %date% * Nothing is playing.
echo -----------------------------------------------------------------------------------------
goto :event_main.block


:event_stop.playing
taskkill /f /im iexplore.exe
cls
echo -Last Action-----------------------------------------------------------------------------
echo # %time% %date% * Stopped playing %URI%
echo -----------------------------------------------------------------------------------------
goto :event_main.block


:event_quit
taskkill /f /im iexplore.exe
taskkill /f /im wscript.exe
exit