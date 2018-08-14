@ECHO OFF
SETLOCAL EnableDelayedExpansion
SET sDATE=%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%
SET sMin=%TIME:~0,2%
SET sSec=%TIME:~3,2%
if %sMin% LSS 10 set sMin=0%sMin%
SET sTIME=%sMin%%sSec%

rem Trim Left
for /f "tokens=* delims= " %%a in ("%sTIME%") do set sTIME=%%a

SET FILENAME=Dropbox_%USERNAME%_%sDATE%_%sTIME%

ECHO Closing Dropbox...
taskkill /F /IM dropbox.exe 2>NUL

IF EXIST %FILENAME%  (
ECHO %FILENAME% 這個資料夾已經存在，請刪除它之後再繼續執行這個批次檔。
) ELSE (
mkdir %FILENAME% 
ECHO Exporting registry...
@REG EXPORT "HKEY_CURRENT_USER\SOFTWARE\Dropbox" "%FILENAME%\%FILENAME%.reg" /y 2>NUL
ECHO Creating zip file...
@7za a -r -mmt -bse0 -bso0 %FILENAME%\%FILENAME%_Local.7z "%LOCALAPPDATA%\Dropbox" 2>NUL
@7za a -r -mmt -bse0 -bso0 %FILENAME%\%FILENAME%_Roaming.7z "%APPDATA%\Dropbox" 2>NUL
)
 
(
echo @ECHO OFF
echo @SETLOCAL EnableDelayedExpansion
echo @IF "%%USERNAME%%" NEQ "%USERNAME%"  ^(
echo ECHO ^"%USERNAME%^" 使用者名稱不正確，或許這個備份不是這台電腦的。
echo @pause
echo ^) ELSE ^(
echo     @for %%%%i in ^(%FILENAME%_Local.7z %FILENAME%.reg %FILENAME%_Roaming.7z^) do if not exist %%%%i  goto skip 
echo     @taskkill /F /IM dropbox.exe
echo     @REG IMPORT "%FILENAME%.reg"
echo     @del %APPDATA%\Dropbox /Q /S 2>NUL
echo     @del %LOCALAPPDATA%\Dropbox /Q /S 2>NUL
echo     @..\7za x %FILENAME%_Local.7z -y -o%LOCALAPPDATA%\ 2>NUL
echo     @..\7za x %FILENAME%_Roaming.7z -y -o%APPDATA%\ 2>NUL
echo     @goto end
echo ^)
echo :skip
echo @ECHO 備份檔案有缺漏，程式不執行。
echo :END
echo @pause
)> %FILENAME%\restore_%FILENAME%.bat
ECHO Done!
)
