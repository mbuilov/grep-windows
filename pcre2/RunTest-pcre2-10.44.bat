@echo off
@rem
@rem MS Windows batch file to run pcre2test on testfiles with the correct
@rem options. This file must use CRLF linebreaks to function properly,
@rem and requires both pcre2test and pcre2grep.
@rem
@rem ------------------------ HISTORY ----------------------------------
@rem This file was originally contributed to PCRE1 by Ralf Junker, and touched
@rem up by Daniel Richard G. Tests 10-12 added by Philip H.
@rem Philip H also changed test 3 to use "wintest" files.
@rem
@rem Updated by Tom Fortmann to support explicit test numbers on the command
@rem line. Added argument validation and added error reporting.
@rem
@rem Sheri Pierce added logic to skip feature dependent tests
@rem tests 4 5 7 10 12 14 19 and 22 require Unicode support
@rem 8 requires Unicode and link size 2
@rem 16 requires absence of jit support
@rem 17 requires presence of jit support
@rem Sheri P also added override tests for study and jit testing
@rem Zoltan Herczeg added libpcre16 support
@rem Zoltan Herczeg added libpcre32 support
@rem -------------------------------------------------------------------
@rem
@rem The file was converted for PCRE2 by PH, February 2015.
@rem Updated for new test 14 (moving others up a number), August 2015.
@rem Tidied and updated for new tests 21, 22, 23 by PH, October 2015.
@rem PH added missing "set type" for test 22, April 2016.
@rem PH added copy command for new testbtables file, November 2020


setlocal enabledelayedexpansion
if [%srcdir%]==[] (
if exist testdata\ set srcdir=.)
if [%srcdir%]==[] (
if exist ..\testdata\ set srcdir=..)
if [%srcdir%]==[] (
if exist ..\..\testdata\ set srcdir=..\..)
if NOT exist %srcdir%\testdata\ (
Error: echo distribution testdata folder not found!
call :conferror
exit /b 1
goto :eof
)

if [%pcre2test%]==[] set pcre2test=.\pcre2test.exe

echo source dir is %srcdir%
echo pcre2test=%pcre2test%

if NOT exist %pcre2test% (
echo Error: %pcre2test% not found!
echo.
call :conferror
exit /b 1
)

%pcre2test% -C linksize >NUL
set link_size=%ERRORLEVEL%
%pcre2test% -C pcre2-8 >NUL
set support8=%ERRORLEVEL%
%pcre2test% -C pcre2-16 >NUL
set support16=%ERRORLEVEL%
%pcre2test% -C pcre2-32 >NUL
set support32=%ERRORLEVEL%
%pcre2test% -C unicode >NUL
set unicode=%ERRORLEVEL%
%pcre2test% -C jit >NUL
set jit=%ERRORLEVEL%
%pcre2test% -C backslash-C >NUL
set supportBSC=%ERRORLEVEL%

if %support8% EQU 1 (
if not exist testout8 md testout8
if not exist testoutjit8 md testoutjit8
)

if %support16% EQU 1 (
if not exist testout16 md testout16
if not exist testoutjit16 md testoutjit16
)

if %support16% EQU 1 (
if not exist testout32 md testout32
if not exist testoutjit32 md testoutjit32
)

set do1=no
set do2=no
set do3=no
set do4=no
set do5=no
set do6=no
set do7=no
set do8=no
set do9=no
set do10=no
set do11=no
set do12=no
set do13=no
set do14=no
set do15=no
set do16=no
set do17=no
set do18=no
set do19=no
set do20=no
set do21=no
set do22=no
set do23=no
set do24=no
set do25=no
set do26=no
set all=yes

for %%a in (%*) do (
  set valid=no
  for %%v in (1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26) do if %%v == %%a set valid=yes
  if "!valid!" == "yes" (
    set do%%a=yes
    set all=no
) else (
    echo Invalid test number - %%a!
        echo Usage %0 [ test_number ] ...
        echo Where test_number is one or more optional test numbers 1 through 23, default is all tests.
        exit /b 1
)
)
set failed="no"

if "%all%" == "yes" (
  set do1=yes
  set do2=yes
  set do3=yes
  set do4=yes
  set do5=yes
  set do6=yes
  set do7=yes
  set do8=yes
  set do9=yes
  set do10=no
  set do11=yes
  set do12=no
  set do13=yes
  set do14=yes
  set do15=yes
  set do16=yes
  set do17=yes
  set do18=yes
  set do19=yes
  set do20=yes
  set do21=yes
  set do22=yes
  set do23=yes
  set do24=yes
  set do25=yes
  set do26=yes
)

@echo RunTest.bat's pcre2test output is written to newly created subfolders
@echo named testout{8,16,32} and testoutjit{8,16,32}.
@echo.

set mode=
set bits=8

:nextMode
if "%mode%" == "" (
  if %support8% EQU 0 goto modeSkip
  echo.
  echo ---- Testing 8-bit library ----
  echo.
)
if "%mode%" == "-16" (
  if %support16% EQU 0 goto modeSkip
  echo.
  echo ---- Testing 16-bit library ----
  echo.
)
if "%mode%" == "-32" (
  if %support32% EQU 0 goto modeSkip
  echo.
  echo ---- Testing 32-bit library ----
  echo.
)
if "%do1%" == "yes" call :do1
if "%do2%" == "yes" call :do2
if "%do3%" == "yes" call :do3
if "%do4%" == "yes" call :do4
if "%do5%" == "yes" call :do5
if "%do6%" == "yes" call :do6
if "%do7%" == "yes" call :do7
if "%do8%" == "yes" call :do8
if "%do9%" == "yes" call :do9
if "%do10%" == "yes" call :do10
if "%do11%" == "yes" call :do11
if "%do12%" == "yes" call :do12
if "%do13%" == "yes" call :do13
if "%do14%" == "yes" call :do14
if "%do15%" == "yes" call :do15
if "%do16%" == "yes" call :do16
if "%do17%" == "yes" call :do17
if "%do18%" == "yes" call :do18
if "%do19%" == "yes" call :do19
if "%do20%" == "yes" call :do20
if "%do21%" == "yes" call :do21
if "%do22%" == "yes" call :do22
if "%do23%" == "yes" call :do23
if "%do24%" == "yes" call :do24
if "%do25%" == "yes" call :do25
if "%do26%" == "yes" call :do26
:modeSkip
if "%mode%" == "" (
  set mode=-16
  set bits=16
  goto nextMode
)
if "%mode%" == "-16" (
  set mode=-32
  set bits=32
  goto nextMode
)

@rem If mode is -32, testing is finished
if %failed% == "yes" (
echo In above output, one or more of the various tests failed!
exit /b 1
)
echo All OK
goto :eof

:runsub
@rem Function to execute pcre2test and compare the output
@rem Arguments are as follows:
@rem
@rem       1 = test number
@rem       2 = outputdir
@rem       3 = test name use double quotes
@rem   4 - 9 = pcre2test options

if [%1] == [] (
  echo Missing test number argument!
  exit /b 1
)

if [%2] == [] (
  echo Missing outputdir!
  exit /b 1
)

if [%3] == [] (
  echo Missing test name argument!
  exit /b 1
)

if %1 == 8 (
  set outnum=8-%bits%-%link_size%
) else (
  set outnum=%1
)
set testinput=testinput%1
set testoutput=testoutput%outnum%
if exist %srcdir%\testdata\win%testinput% (
  set testinput=wintestinput%1
  set testoutput=wintestoutput%outnum%
)

echo Test %1: %3
%pcre2test% %mode% %4 %5 %6 %7 %8 %9 %srcdir%\testdata\%testinput% >%2%bits%\%testoutput%
if errorlevel 1 (
  echo.          failed executing command-line:
  echo.            %pcre2test% %mode% %4 %5 %6 %7 %8 %9 %srcdir%\testdata\%testinput% ^>%2%bits%\%testoutput%
  set failed="yes"
  goto :eof
) else if [%1]==[2] (
  %pcre2test% %mode% %4 %5 %6 %7 %8 %9 -error -70,-62,-2,-1,0,100,101,191,300 >>%2%bits%\%testoutput%
)

@rem test etalon data is good for 64-bit pcre2test executable but it is wrong for 32-bit pcre2test
@rem - due to smaller inner structures (pointers are 32-bit, size_t is also 34-bit)
@rem don't touch test etalon data, but fix test output instead (increase reported sizes)
if %1 == 8 (
  find "Memory allocation - compiled block : 119" %2%bits%\%testoutput% >NUL && (
 <%2%bits%\%testoutput% .\testrepl.exe +590 35 ^
 | .\testrepl.exe +591 33 ^
 | .\testrepl.exe +894 36 ^
 | .\testrepl.exe +895 31 ^
 | .\testrepl.exe +1245 35 ^
 | .\testrepl.exe +1246 39 ^
 | .\testrepl.exe +1594 37 ^
 | .\testrepl.exe +1595 37 ^
 | .\testrepl.exe +1882 34 ^
 | .\testrepl.exe +1883 33 ^
 | .\testrepl.exe +2236 34 ^
 | .\testrepl.exe +2237 35 ^
 | .\testrepl.exe +2598 34 ^
 | .\testrepl.exe +2599 35 ^
 | .\testrepl.exe +2867 34 ^
 | .\testrepl.exe +2868 35 ^
 | .\testrepl.exe +3140 34 ^
 | .\testrepl.exe +3141 39 ^
 | .\testrepl.exe +3426 35 ^
 | .\testrepl.exe +3427 34 ^
 | .\testrepl.exe +3779 35 ^
 | .\testrepl.exe +3780 36 ^
 | .\testrepl.exe +4764 36 ^
 | .\testrepl.exe +4765 32 ^
 | .\testrepl.exe +5975 35 ^
 | .\testrepl.exe +5976 32 ^
 | .\testrepl.exe +6663 35 ^
 | .\testrepl.exe +6664 38 ^
 | .\testrepl.exe +6990 36 ^
 | .\testrepl.exe +6991 34 ^
 | .\testrepl.exe +7370 32 ^
 | .\testrepl.exe +7371 30 ^
 | .\testrepl.exe +7372 30 ^
 | .\testrepl.exe +7771 39 ^
 | .\testrepl.exe +7772 33 ^
 | .\testrepl.exe +8198 37 ^
 | .\testrepl.exe +8199 34 ^
 | .\testrepl.exe +8592 36 ^
 | .\testrepl.exe +8593 37 ^
 | .\testrepl.exe +8945 38 ^
 | .\testrepl.exe +8946 39 ^
 | .\testrepl.exe +9404 34 ^
 | .\testrepl.exe +9405 36 ^
 | .\testrepl.exe +9686 34 ^
 | .\testrepl.exe +9687 37 ^
 | .\testrepl.exe +9970 34 ^
 | .\testrepl.exe +9971 38 ^
 | .\testrepl.exe +10256 34 ^
 | .\testrepl.exe +10257 38 ^
 | .\testrepl.exe +10543 34 ^
 | .\testrepl.exe +10544 38 ^
 | .\testrepl.exe +10932 34 ^
 | .\testrepl.exe +10933 36 ^
 | .\testrepl.exe +11214 34 ^
 | .\testrepl.exe +11215 36 ^
 | .\testrepl.exe +11492 34 ^
 | .\testrepl.exe +11493 36 ^
 | .\testrepl.exe +11769 34 ^
 | .\testrepl.exe +11770 36 ^
 | .\testrepl.exe +12076 35 ^
 | .\testrepl.exe +12077 34 ^
 | .\testrepl.exe +12497 35 ^
 | .\testrepl.exe +12498 35 ^
 | .\testrepl.exe +12927 35 ^
 | .\testrepl.exe +12928 35 ^
 | .\testrepl.exe +13340 34 ^
 | .\testrepl.exe +13341 36 ^
 | .\testrepl.exe +13624 38 ^
 | .\testrepl.exe +13625 33 ^
 | .\testrepl.exe +13925 35 ^
 | .\testrepl.exe +13926 34 ^
 | .\testrepl.exe +14235 35 ^
 | .\testrepl.exe +14236 34 ^
 | .\testrepl.exe +14629 35 ^
 | .\testrepl.exe +14630 31 ^
 | .\testrepl.exe +14908 35 ^
 | .\testrepl.exe +14909 31 ^
 | .\testrepl.exe +15186 35 ^
 | .\testrepl.exe +15187 31 ^
 | .\testrepl.exe +15465 35 ^
 | .\testrepl.exe +15466 31 ^
 | .\testrepl.exe +15757 38 ^
 | .\testrepl.exe +15758 36 ^
 | .\testrepl.exe +16049 35 ^
 | .\testrepl.exe +16050 31 ^
 | .\testrepl.exe +16335 38 ^
 | .\testrepl.exe +16336 34 ^
 | .\testrepl.exe +16650 36 ^
 | .\testrepl.exe +16651 31 ^
 | .\testrepl.exe +16983 36 ^
 | .\testrepl.exe +16984 31 ^
 | .\testrepl.exe +17302 35 ^
 | .\testrepl.exe +17303 33 ^
 | .\testrepl.exe +17603 37 ^
 | .\testrepl.exe +17604 34 ^
 | .\testrepl.exe +18014 36 ^
 | .\testrepl.exe +18015 36 ^
 | .\testrepl.exe +18384 34 ^
 | .\testrepl.exe +18385 35 ^
 | .\testrepl.exe +18654 34 ^
 | .\testrepl.exe +18655 35 ^
 | .\testrepl.exe +18924 34 ^
 | .\testrepl.exe +18925 35 ^
 | .\testrepl.exe +19202 34 ^
 | .\testrepl.exe +19203 36 ^
 | .\testrepl.exe +19476 34 ^
 | .\testrepl.exe +19477 35 ^
 | .\testrepl.exe +19750 34 ^
 | .\testrepl.exe +19751 35 ^
 | .\testrepl.exe +20024 34 ^
 | .\testrepl.exe +20025 35 ^
 | .\testrepl.exe +20306 34 ^
 | .\testrepl.exe +20307 36 ^
 >%2%bits%\%testoutput%.x
  del /q %2%bits%\%testoutput%
  ren %2%bits%\%testoutput%.x %testoutput%
  )
)

set type=
if [%1]==[11] (
  set type=-%bits%
)
if [%1]==[12] (
  set type=-%bits%
)
if [%1]==[14] (
  set type=-%bits%
)
if [%1]==[22] (
  set type=-%bits%
)

fc /n %srcdir%\testdata\%testoutput%%type% %2%bits%\%testoutput% >NUL

if errorlevel 1 (
  echo.          failed comparison: fc /n %srcdir%\testdata\%testoutput% %2%bits%\%testoutput%
  if [%1]==[3] (
    echo.
    echo ** Test 3 failure usually means french locale is not
    echo ** available on the system, rather than a bug or problem with PCRE2.
    echo.
    goto :eof
)

  set failed="yes"
  goto :eof
)

echo.          Passed.
goto :eof

:do1
call :runsub 1 testout "Main non-UTF, non-UCP functionality (Compatible with Perl >= 5.10)" -q
if %jit% EQU 1 call :runsub 1 testoutjit "Test with JIT Override" -q -jit
goto :eof

:do2
  copy /y %srcdir%\testdata\testbtables testbtables 
  call :runsub 2 testout "API, errors, internals, and non-Perl stuff" -q
  if %jit% EQU 1 call :runsub 2 testoutjit "Test with JIT Override" -q -jit
goto :eof

:do3
  call :runsub 3 testout "Locale-specific features" -q
  if %jit% EQU 1 call :runsub 3 testoutjit "Test with JIT Override" -q -jit
goto :eof

:do4
if %unicode% EQU 0 (
  echo Test 4 Skipped due to absence of Unicode support.
  goto :eof
)
  call :runsub 4 testout "UTF-%bits% and Unicode property support - (Compatible with Perl >= 5.10)" -q
  if %jit% EQU 1 call :runsub 4 testoutjit "Test with JIT Override" -q -jit
goto :eof

:do5
if %unicode% EQU 0 (
  echo Test 5 Skipped due to absence of Unicode support.
  goto :eof
)
  call :runsub 5 testout "API, internals, and non-Perl stuff for UTF-%bits% and UCP" -q
  if %jit% EQU 1 call :runsub 5 testoutjit "Test with JIT Override" -q -jit
goto :eof

:do6
  call :runsub 6 testout "DFA matching main non-UTF, non-UCP functionality" -q
goto :eof

:do7
if %unicode% EQU 0 (
  echo Test 7 Skipped due to absence of Unicode support.
  goto :eof
)
  call :runsub 7 testout "DFA matching with UTF-%bits% and Unicode property support" -q
  goto :eof

:do8
if NOT %link_size% EQU 2 (
  echo Test 8 Skipped because link size is not 2.
  goto :eof
)
if %unicode% EQU 0 (
  echo Test 8 Skipped due to absence of Unicode support.
  goto :eof
)
  call :runsub 8 testout "Internal offsets and code size tests" -q
goto :eof

:do9
if NOT %bits% EQU 8 (
  echo Test 9 Skipped when running 16/32-bit tests.
  goto :eof
)
  call :runsub 9 testout "Specials for the basic 8-bit library" -q
  if %jit% EQU 1 call :runsub 9 testoutjit "Test with JIT Override" -q -jit
goto :eof

:do10
if NOT %bits% EQU 8 (
  echo Test 10 Skipped when running 16/32-bit tests.
  goto :eof
)
if %unicode% EQU 0 (
  echo Test 10 Skipped due to absence of Unicode support.
  goto :eof
)
  call :runsub 10 testout "Specials for the 8-bit library with Unicode support" -q
  if %jit% EQU 1 call :runsub 10 testoutjit "Test with JIT Override" -q -jit
goto :eof

:do11
if %bits% EQU 8 (
  echo Test 11 Skipped when running 8-bit tests.
  goto :eof
)
  call :runsub 11 testout "Specials for the basic 16/32-bit library" -q
  if %jit% EQU 1 call :runsub 11 testoutjit "Test with JIT Override" -q -jit
goto :eof

:do12
if %bits% EQU 8 (
  echo Test 12 Skipped when running 8-bit tests.
  goto :eof
)
if %unicode% EQU 0 (
  echo Test 12 Skipped due to absence of Unicode support.
  goto :eof
)
  call :runsub 12 testout "Specials for the 16/32-bit library with Unicode support" -q
  if %jit% EQU 1 call :runsub 12 testoutjit "Test with JIT Override" -q -jit
goto :eof

:do13
if %bits% EQU 8 (
  echo Test 13 Skipped when running 8-bit tests.
  goto :eof
)
  call :runsub 13 testout "DFA specials for the basic 16/32-bit library" -q
goto :eof

:do14
if %unicode% EQU 0 (
  echo Test 14 Skipped due to absence of Unicode support.
  goto :eof
)
  call :runsub 14 testout "DFA specials for UTF and UCP support" -q
  goto :eof

:do15
call :runsub 15 testout "Non-JIT limits and other non_JIT tests" -q
goto :eof

:do16
if %jit% EQU 1 (
  echo Test 16 Skipped due to presence of JIT support.
  goto :eof
)
  call :runsub 16 testout "JIT-specific features when JIT is not available" -q
goto :eof

:do17
if %jit% EQU 0 (
  echo Test 17 Skipped due to absence of JIT support.
  goto :eof
)
  call :runsub 17 testout "JIT-specific features when JIT is available" -q
goto :eof

:do18
if %bits% EQU 16 (
  echo Test 18 Skipped when running 16-bit tests.
  goto :eof
)
if %bits% EQU 32 (
  echo Test 18 Skipped when running 32-bit tests.
  goto :eof
)
  call :runsub 18 testout "POSIX interface, excluding UTF-8 and UCP" -q
goto :eof

:do19
if %bits% EQU 16 (
  echo Test 19 Skipped when running 16-bit tests.
  goto :eof
)
if %bits% EQU 32 (
  echo Test 19 Skipped when running 32-bit tests.
  goto :eof
)
if %unicode% EQU 0 (
  echo Test 19 Skipped due to absence of Unicode support.
  goto :eof
)
  call :runsub 19 testout "POSIX interface with UTF-8 and UCP" -q
goto :eof

:do20
call :runsub 20 testout "Serialization tests" -q
goto :eof

:do21
if %supportBSC% EQU 0 (
  echo Test 21 Skipped due to absence of backslash-C support.
  goto :eof
)
  call :runsub 21 testout "Backslash-C tests without UTF" -q
  call :runsub 21 testout "Backslash-C tests without UTF (DFA)" -q -dfa
  if %jit% EQU 1 call :runsub 21 testoutjit "Test with JIT Override" -q -jit
goto :eof

:do22
if %supportBSC% EQU 0 (
  echo Test 22 Skipped due to absence of backslash-C support.
  goto :eof
)
if %unicode% EQU 0 (
  echo Test 22 Skipped due to absence of Unicode support.
  goto :eof
)
  call :runsub 22 testout "Backslash-C tests with UTF" -q
  if %jit% EQU 1 call :runsub 22 testoutjit "Test with JIT Override" -q -jit
goto :eof

:do23
if %supportBSC% EQU 1 (
  echo Test 23 Skipped due to presence of backslash-C support.
  goto :eof
)
  call :runsub 23 testout "Backslash-C disabled test" -q
goto :eof

:do24
  call :runsub 24 testout "Non-UTF pattern conversion tests" -q
goto :eof

:do25
if %unicode% EQU 0 (
  echo Test 25 Skipped due to absence of Unicode support.
  goto :eof
)
  call :runsub 25 testout "UTF pattern conversion tests" -q
goto :eof

:do26
if %unicode% EQU 0 (
  echo Test 26 Skipped due to absence of Unicode support.
  goto :eof
)
  call :runsub 26 testout "Auto-generated unicode property tests" -q
  if %jit% EQU 1 call :runsub 26 testoutjit "Test with JIT Override" -q -jit
goto :eof

:conferror
@echo.
@echo Either your build is incomplete or you have a configuration error.
@echo.
@echo If configured with cmake and executed via "make test" or the MSVC "RUN_TESTS"
@echo project, pcre2_test.bat defines variables and automatically calls RunTest.bat.
@echo For manual testing of all available features, after configuring with cmake
@echo and building, you can run the built pcre2_test.bat. For best results with
@echo cmake builds and tests avoid directories with full path names that include
@echo spaces for source or build.
@echo.
@echo Otherwise, if the build dir is in a subdir of the source dir, testdata needed
@echo for input and verification should be found automatically when (from the
@echo location of the the built exes) you call RunTest.bat. By default RunTest.bat
@echo runs all tests compatible with the linked pcre2 library but it can be given
@echo a test number as an argument.
@echo.
@echo If the build dir is not under the source dir you can either copy your exes
@echo to the source folder or copy RunTest.bat and the testdata folder to the
@echo location of your built exes and then run RunTest.bat.
@echo.
goto :eof