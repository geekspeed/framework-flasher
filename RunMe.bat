@ECHO OFF
setlocal enabledelayedexpansion

SET version=1.2
SET editfile=Nada
SET header=No
SET logfile=%~dp0LogSimple.txt

COLOR 07

TITLE Framework Flasher %version% - Wes Foster (wesf90)

IF (%1) == (0) goto ladeda

REM going to resources so we can write to the log
echo. >> LogProcess.txt
echo --------------------------------------------------------------------- >> LogProcess.txt
echo --------------------------------------------------------------------- >> %logfile%
echo ^|  Log - %date% -- %time%  ^| >> %logfile% >> LogProcess.txt
echo ^|  Log - %date% -- %time%  ^| >> %logfile% >> %logfile%
echo --------------------------------------------------------------------- >> LogProcess.txt
echo --------------------------------------------------------------------- >> %logfile%
echo THE LOG BELOW IS FOR YOUR MOST RECENT PROCESS ONLY. >> LogProcess.txt
echo. >> LogProcess.txt
echo. >> LogProcess.txt

RunMe_original 0 2>> LogProcess.txt


:ladeda
	mode con:cols=85 lines=40
	SET usrc=9
	SET heapn=64
	java -version 
	IF errorlevel 1 goto errjava
	CLS
	
	
:restart
	COLOR 07
	CD %~dp0
	SET choice=NADA

	CALL:_header
	
	IF %editfile% == Nada (GOTO selectfile)
	
	echo  Main Options  --  [Current file: %editfile%]
	echo  -----------------------------------------------------
	echo   (1)    Decompile an APK
	echo   (2)    Compile an APK
	echo   (3)    Sign an APK
	echo   (4)    Create update.zip from APK(s) for flashing
	echo   (5)    Great News^^! ^(when your finished creating the zip^)
	echo.
	echo.
	echo  Other Options
	echo  --------------
	echo   (10)   Set Compression Level for APK's
	echo   (11)   Set Max Memory Size (if you get stuck when decompiling/compiling)
	echo   (12)   Choose another file to work with
	echo   (13)   Remove unnecessary files/folders
	echo   (14)   Help (ReadME.txt)
	echo.
	echo   (99)   Exit
	echo -------------------------------------------------------------------------------------
	echo.
	
	SET /P choice=Choose the number corresponding to the option:
	IF %choice%==1 (goto decompile)
	IF %choice%==2 (goto compile)
	IF %choice%==3 (goto sign)
	IF %choice%==4 (goto crzip)
	IF %choice%==5 (goto greatnews)

	IF %choice%==10 (goto usrcomp)
	IF %choice%==11 (goto heap)
	IF %choice%==12 (goto selectfile)
	IF %choice%==13 (goto remff)
	IF %choice%==14 (
		notepad ReadME.txt
		
		GOTO about
	)
	IF %choice%==99 (goto exit)


:WHAT
	echo.
	echo You must enter the number of the operation you would like the script to perform.
	echo For example, to Decompile an APK, type in "1" (without the quotes) and press enter.
	PAUSE
	goto restart
	
	
:about
	CALL:_header
	echo If notepad did not automatically pop-up with the Help / About file, simply
	echo open and read "ReadME.txt", which is located in the same directory as this script.
	echo.
	PAUSE
	
	goto restart
	
	
:heap
	CALL:_header
	SET /P INPUT=Enter max size for java heap space in megabytes (eg 512) : %=%
	SET heapn=%INPUT%
	
	CALL:_logmark "Set HEAP Size to %heapn%"
	goto restart
	
	
:usrcomp
	CALL:_header
	SET /P INPUT=Enter Compression Level (0-9) : %=%
	SET usrc=%INPUT%
	
	CALL:_logmark "Set Compression Size to %usrc%"
	goto restart
	
	
:remff
	CALL:_header
	echo This will remove any edits, logs, and changes you have made since first
	echo unzipping Framework Flasher.
	echo.
	SET /P INPUT=Type YES to continue: 
	SET yn=%INPUT%
	
	IF %yn% == YES (
		echo.
		echo (removing directories and files...)
		RD /Q /S %~dp0files-to-edit
		RD /Q /S %~dp0temp-files
		RD /Q /S %~dp0final-zip-file
		RD /Q /S %~dp0resources\struct\system
		RD /Q /S %~dp0place-apk-to-edit-here\system
		
		echo.
		echo (removing logs...)
		DEL /Q %logfile%
		
		SET editfile=Nada
		
		echo.
		echo All Done^^!
		echo.
		PAUSE
	)
	goto restart
	
	
:noeditfolder
	echo.
	echo ------++ Before you can compile the APK, you must first DE-compile it ^(Step 1^) ++------
	echo.
	PAUSE
	goto restart
	
	
:decompile
	CALL:_logmark DECOMPILING START
	
	COLOR 02
	CD resources
	
	echo.
	echo (removing old files...)
	IF EXIST "../place-apk-to-edit-here/signed_%editfile%"		(DEL /Q "../place-apk-to-edit-here/signed_%editfile%")
	IF EXIST "../place-apk-to-edit-here/compiled_%editfile%"	(DEL /Q "../place-apk-to-edit-here/compiled_%editfile%")

	echo (removing old files-to-edit...)
	IF EXIST "../files-to-edit/%editfile%" (RMDIR /S /Q "../files-to-edit/%editfile%")
	
	echo.
	echo ===============++ Decompiling the APK. Please, please be patient :) ++===============
	
	java -Xmx%heapn%m -jar apktool.jar d "%~dp0place-apk-to-edit-here/%editfile%" "%~dp0files-to-edit/%editfile%" >> %logfile%
	
	IF errorlevel 1 (
		echo There was an error when compiling... >> %logfile%
		GOTO error
	) ELSE (
		echo Success! >> %logfile%
	)
	
	CALL:_header
	echo.
	echo.
	echo ------------------------------------------------------------------------------------
	echo The APK has been decompiled successfully.
	echo ------------------------------------------------------------------------------------
	echo.
	echo You may now edit the files located inside the 'files-to-edit' folder. Once you
	echo have made all your modifications, continue onto the next step ^(Compile APK^).
	echo.
	echo Note: You may close this script and come back to it later. Just be sure to choose
	echo the "Compile" option next time around.
	echo.
	
	echo -----[DECOMPILING END -- %time%]----- >> %logfile%
	goto endoffunction
	
	
:compile
	COLOR 02
	IF NOT EXIST "%~dp0files-to-edit\%editfile%" GOTO noeditfolder
	CD resources
	
	echo -----[COMPILING START -- %time%]----- >> %logfile%
	
	echo.
	echo ===============++ Building APK. Hold your horses^^! ++===============
	
	echo (removing old files...)
	IF EXIST "%~dp0place-apk-to-edit-here\compiled_%editfile%" (DEL /Q "%~dp0place-apk-to-edit-here\compiled_%editfile%")
	
	echo (preserving the original file...)
	XCOPY %~dp0place-apk-to-edit-here\%editfile% %~dp0original-apk-backup\original_%editfile%
	
	echo (compiling edited files...)
	java -Xmx%heapn%m -jar apktool.jar b "../files-to-edit/%editfile%" "%~dp0place-apk-to-edit-here\compiled_%editfile%" >> %logfile%
	echo. >> %logfile%
	
	IF errorlevel 1 (
		echo There was an error when compiling >> %logfile%
		GOTO error
	) ELSE (
		echo Success! >> %logfile%
	)
	
	COLOR 07
	
	REM Remove the original file
	DEL %~dp0place-apk-to-edit-here\%editfile%
	
	echo.
	echo ===============++ APK has been re-built^^! ++===============
	
	CALL:_header
	echo.
	echo.
	echo ------------------------------------------------------------------------------------
	echo The APK [%editfile%] has been compiled successfully^^!
	echo Now, the next step is to choose option 3 and sign the APK.
	echo ------------------------------------------------------------------------------------
	echo.
	
	echo -----[COMPILING END -- %time%]----- >> %logfile%
	
	goto endoffunction
	
	
:sign
	COLOR 02
	CD resources
	
	echo -----[SIGNING START -- %time%]----- >> %logfile%
	
	REM Prevent user error and remove "compiled_" from the beginning of the set file
	SET editfile=%editfile:compiled_=%
	
	echo.
	echo ===============++ Signing the Apk... don't be in such a hurry^^! ++===============
	
	java -Xmx%heapn%m -jar signapk.jar -w testkey.x509.pem testkey.pk8 ../place-apk-to-edit-here/compiled_%editfile% ../place-apk-to-edit-here/signed_%editfile% >> %logfile%
	echo. >> %logfile%

	
	IF %ErrorLevel% == 1 (
		echo.
		echo The file 'compiled_%editfile%' does not exist^^!
		echo The file 'compiled_%editfile%' does not exist^^! >> %logfile%

		GOTO error
	) ELSE (
		echo Success! >> %logfile%
		
		DEL /Q "../place-apk-to-edit-here/compiled_%editfile%"
		echo.
		echo.
		echo ===============++ Signing successful^^! ++===============
	)
	
	CALL:_header
	echo.
	echo.
	echo ------------------------------------------------------------------------------------
	echo The APK has been signed successfully.
	echo The next step is to create the .zip file. On the main screen, choose option 4^^!
	echo ------------------------------------------------------------------------------------
	echo.
	
	echo -----[SIGNING END -- %time%]----- >> %logfile%
	
	goto endoffunction
	
	
:crzip
	COLOR 02
	IF %i% == 1 (GOTO zipsingle)
	
	SET editfile=%editfile:signed_=%
	
	CALL:_header
	echo Since there is more than one APK in your edit folder, you have 2 options:
	echo.
	echo  (1)  Only zip the current file: %editfile%
	echo  (2)  Zip all files in the 'place-apk-to-edit-here'
	echo.
	SET /P zipopt=What would you like to do?:
	
	IF %zipopt%==1 (GOTO zipsingle)
	IF %zipopt%==2 (GOTO zipmulti)
	
	echo.
	echo You must either enter a 1 or 2 as they are the only options available.
	PAUSE
	goto crzip


:zipmulti
	CALL:_header
	CALL:_logmark "ZIPPING MULTIPLE"
	
	REM create the beginning system folder
	MD %~dp0place-apk-to-edit-here\system
	
	echo ---------------------------------------------------------
	echo ^^!^^! Attention ^^!^^!
	echo ---------------------------------------------------------
	echo Before you proceed, ensure that the files inside of 'place-apk-to-edit-here'
	echo are in their proper directory structure for zipping. For example, if you
	echo were zipping framework-res.apk and otherfile.apk, and they both were being
	echo flashed to the same directory on your phone, you would structure them like so:
	echo (The path MUST begin with /system)
	echo.
	echo /place-apk-to-edit-here/system/framework/framework-res.apk
	echo /place-apk-to-edit-here/system/framework/otherfile.apk
	echo.
	echo Once you have structured your files, you may continue.
	echo.
	PAUSE


	REM Move the dir and files to our struct folder
	echo (making the move... might take a while, do some exercises^^!)
	XCopy %~dp0place-apk-to-edit-here\system %~dp0resources\struct\system /D /E /C /R /I /K /Y >> %logfile%
	
	echo (checking the file structure...)
	FOR /R "%~dp0resources\struct\system" %%X IN (signed_*.apk) DO CALL:_process_ren_signed %%X >> %logfile%

	echo.
	echo (looks good to me^^!)
	
	GOTO copyandzip


:zipsingle	
	CALL:_header
	CALL:_logmark "ZIPPING SINGLE"
	
	CD resources
	
	echo -----[ZIPPING FILE START -- %time%]----- >> %logfile%
	
	SET editfile=%editfile:signed_=%
	
	IF NOT %editfile% == framework-res.apk (
		echo Please enter the path of where '%editfile%' should be installed.
		echo For example, if you were installing framework-res.apk, you would enter
		echo /system/framework
		echo.
		echo The path must begin with /system
		SET /P filedir=Path: 
	) ELSE (
		SET filedir=/system/framework
	)
	
	echo (removing old zips...)	
	IF EXIST "%~dp0final-zip-file/update.zip"	(DEL /Q "%~dp0final-zip-file/update.zip")
	
	REM change slash direction and parse user errors
		SET filedir=%filedir:/=\%
		SET filedir=%filedir:\\=\%
		SET firstL=%filedir:~0,1%
		SET lastL=%filedir:~-1%
	
		IF NOT %firstL% == \ (
			SET filedir=\!filedir!
		)
	
		IF NOT %lastL% == \ (
			SET filedir=!filedir!\
		)
	

	echo.
	echo (moving files around...)
	
	XCOPY %~dp0place-apk-to-edit-here\signed_%editfile% %~dp0resources\struct%filedir% /D /E /C /R /I /K /Y >> %logfile%
	REM this function will flow right into :zopyandzip
	
	REM Move up a DIR so the next function can move down a dir
	CD ../


:copyandzip
	CD resources
	
	echo.
	echo ===============++ Zipping up the files... ++===============	
	7za a -tzip "%~dp0final-zip-file/update_unsigned.zip" "%~dp0resources\struct\*" -mx%usrc% >> %logfile%
	echo. >> %logfile%
	
	echo.
	echo ===============++ Signing the zip... ++===============	
	java -Xmx%heapn%m -jar signapk.jar -w testkey.x509.pem testkey.pk8 ../final-zip-file/update_unsigned.zip ../final-zip-file/update.zip >> %logfile%
	echo. >> %logfile%
	
	echo.
	echo ===============++ Removing the final bit of temp files... ++===============	
	DEL /Q %~dp0final-zip-file\update_unsigned.zip
	RD /Q /S %~dp0resources\struct\system
	
	echo.
	echo.
	echo.
	echo ====================++ ++=======================
	echo.
	echo ^|^|   All done^^! Your update.zip is located inside the 'final-zip-file' folder^^!
	echo ^|^|   Read the Help / About (option 14) if you are not sure of something.
	echo.
	echo ====================++ -- ++====================
	echo.
	echo.
	
	
	CALL:_header
	echo.
	echo.
	echo ------------------------------------------------------------------------------------
	echo That's it^^! You're done^^! The zip you created is located in /final-zip-file/update.zip
	echo Simply place that file on your sd card, flash, and reboot it to see your changes.
	echo.
	echo The help option (option 14) provides a little more information on this,
	echo if you want a little more detail on flashing the .zip.
	echo ------------------------------------------------------------------------------------
	echo.
	echo.
	echo.
	
	echo -----[ZIPPING FILE END -- %time%]----- >> %logfile%
	
	goto endoffunction
	
	
:greatnews
	IF EXIST "./final-zip-file/update.zip" (
		COLOR 0E
		cls
		echo.
		echo                                                         ,jf
		echo    _am,    ,_am,  ,_g_oam,    _am,   _g_ag,   _am,   koewkovg   _mm_
		echo  ,gF  @._-gF   @-"  jf   @  ,gF  @  ^ NX  #_,gF  @     jf      qK  "
		echo  8Y      8Y    d   j#   jF .8Y  ,d   dY     8Y   d    jf       *b,
		echo jK   ,  jK   ,N   jN   jF  :K  ,Z  ,jF     jK  ,Z"  ,jfk,       dN.
		echo  NbpP    NbpP    dP   dFk_o8NbpP"V^dF       NbpY"V^"dF "dYo-"*h,W"
		echo                          ,gF',@'
		echo                         :8K  j8
		echo                          "*w*"
		echo.
		echo                                .--------.
		echo                              .: : :  :___`.
		echo                            .'^^!^^!:::::  \\_\ `.
		echo                       : . /^%%O^^!^^!::::::::\\_\. \
		echo                      [""]/^%%^%%O^^!^^!:::::::::  : . \
		echo                      ^|  ^|^%%^%%OO^^!^^!::::::::::: : . ^|
		echo                      ^|  ^|^%%^%%OO^^!^^!:::::::::::::  :^|
		echo                      ^|  ^|^%%^%%OO^^!^^!^^!::::::::::::: :^|
		echo             :       .'--`.^%%^%%OO^^!^^!^^!:::::::::::: :^|
		echo           : .:     /`.__.'\^%%^%%OO^^!^^!^^!::::::::::::/
		echo          :    .   /        \^%%OO^^!^^!^^!^^!::::::::::/
		echo         ,-'``'-. ;          ;^%%^%%OO^^!^^!^^!^^!^^!^^!:::::'
		echo         ^|`-..-'^| ^|   ,--.   ^|`^%%^%%^%%OO^^!^^!^^!^^!^^!^^!:'
		echo         ^| .   :^| ^|_.','`.`._^|  `^%%^%%^%%OO^^!^%%^%%'
		echo         ^| . :  ^| ^|--'    `--^|    `^%%^%%^%%^%%'
		echo         ^|`-..-'^| ^|^|   ^| ^| ^| ^|     /__\`-.
		echo         \::::::/ ^|^|^)^|/^|^)^|^)^|\^|           /
		echo ---------`::::'--^|._ ~**~ _.^|----------^( -----------------------
		echo            ^)^(    ^|  `-..-'  ^|           \    ______
		echo            ^)^(    ^|          ^|,--.       ____/ /  /\\ ,-._.-'
		echo         ,-'^)^('-. ^|          ^|\`;/   .-^(^)___  :  ^|`.^^!,-'`'/`-._
		echo        ^(  '  `  ^)`-._    _.-'^|;,^|    `-,    \_\__\`,-'^>-.,-._
		echo         `-....-'     ````    `--'      `-._       ^(`- `-._`-. 
		echo ----------------------------------------------------------------
		echo.
		echo YOU ARE DONE^^! TIME TO FLASH^^!
		echo.
		echo ----------------------------------------------------------------
	) ELSE (
		echo Hey... you're supposed to wait until you're finished creating the update.zip.
		echo Come back later when it's created and you are done^^!
	)
	
	PAUSE
	goto restart


:selectfile
	CALL:_header
	
	SET /A i=0
	
	IF NOT %editfile% == Nada (
		echo ^(0^) --Cancel and return to home--
	)
	
	FOR %%F IN (place-apk-to-edit-here/*.apk) DO (
		SET cf=%%F
		SET orig=!cf:~0,9!
		IF NOT !orig! == original_ (
			SET /A i+=1
			SET a!i!=%%F
			echo ^(!i!^)  %%F
		)
	)
	
	
	IF !i! == 0 (
		CALL:_header
		echo You have not placed any files inside of the 'place-apk-to-edit-here' folder.
		echo In order to modify an apk, it must be placed inside of this folder.
		echo.
		
		PAUSE
		GOTO exit
	)
	
	
	IF !i! == 1 (
		SET editfile=!a1!
		GOTO restart
	)
	
	echo.
	
	IF %editfile% == Nada (
		echo Before you're able to edit your file^(s^), you need to first select which
		echo file you'll be editing. Select which APK from the list above that you
		echo are currently editing. Enter it's number below:
	)
	
	
	SET /P INPUT=Number: %=%
	IF /I %INPUT% GTR !i! (GOTO errfileselect)
	IF /I %INPUT% EQU 0 (GOTO restart)
	IF /I %INPUT% LSS 1 (GOTO errfileselect)
	SET editfile=!a%INPUT%!
	
	GOTO restart


:errfileselect
	echo.
	echo That is an invalid number. Please try again.
	PAUSE
	GOTO selectfile
	
	
:errjava
	COLOR 0C
	CALL:_header
	
	echo --------------------/^^!\--------------------
	echo Java was not found, you will not be able to sign apks or use this script
	echo --------------------------------------------
	PAUSE
	goto restart
	
	
:endoffunction
	COLOR 0A
	PAUSE
	goto restart
	
	
:error
	COLOR 0C
	echo.
	echo --------------------/^^!\--------------------
	echo An error has occurred. Check the Logs.txt for more info.
	echo --------------------------------------------
	echo.
	PAUSE
	
	GOTO restart


:_header
	CLS
	echo.
	echo                    Framework Flasher %version% - by Wes Foster (wesf90)
	echo              Please read the "Help" section before using this script
	echo.
	echo ------------------------------------------------------------------------------------
	echo              Compression: %usrc%                          Heap Size: %heapn%mb
	echo ````````````````````````````````````````````````````````````````````````````````````
	echo.
	GOTO exit


:_logmark
	echo.
	echo -----[%~nx1 -- %time%]----- >> %logfile%
	echo.
	GOTO exit
	
	
:_process_ren_signed
	PUSHD %~dp1
	SET fn=%~nx1
	SET fn=%fn:signed_=%
	REN %~nx1 %fn%
	POPD
	GOTO exit
	
	
:exit
