@echo off

:: Run pcre2grep tests. The assumption is that the PCRE2 tests check the library
:: itself. What we are checking here is the file handling and options that are
:: supported by pcre2grep. This script must be run in the build directory.
:: (jmh: I've only tested in the main directory, using my own builds.)

setlocal enabledelayedexpansion

:: Remove any non-default colouring that the caller may have set.

set PCRE2GREP_COLOUR=
set PCRE2GREP_COLOR=
set PCREGREP_COLOUR=
set PCREGREP_COLOR=
set GREP_COLORS=
set GREP_COLOR=

:: Remember the current (build) directory and set the program to be tested.

set builddir="%CD%"
set pcre2grep=%builddir%\pcre2grep.exe
set pcre2test=%builddir%\pcre2test.exe

if NOT exist %pcre2grep% (
  echo ** %pcre2grep% does not exist.
  exit /b 1
)

if NOT exist %pcre2test% (
  echo ** %pcre2test% does not exist.
  exit /b 1
)

for /f "delims=" %%a in ('"%pcre2grep%" -V') do set pcre2grep_version=%%a
echo Testing %pcre2grep_version%

:: Set up a suitable "diff" command for comparison. Some systems have a diff
:: that lacks a -u option. Try to deal with this; better do the test for the -b
:: option as well. Use FC if there's no diff, taking care to ignore equality.

set cf=
set cfout=
diff -b  nul nul 2>nul && set cf=diff -b
diff -u  nul nul 2>nul && set cf=diff -u
diff -ub nul nul 2>nul && set cf=diff -ub
if NOT defined cf (
  set cf=fc /n
  set "cfout=>testcf || (type testcf & cmd /c exit /b 1)"
)

:: Set srcdir to the current or parent directory, whichever one contains the
:: test data. Subsequently, we run most of the pcre2grep tests in the source
:: directory so that the file names in the output are always the same.

if NOT defined srcdir set srcdir=.
if NOT exist %srcdir%\testdata\ (
  if exist testdata\ (
    set srcdir=.
  ) else if exist ..\testdata\ (
    set srcdir=..
  ) else if exist ..\..\testdata\ (
    set srcdir=..\..
  ) else (
    echo Cannot find the testdata directory
    exit /b 1
  )
)

:: Check for the availability of UTF-8 support

%pcre2test% -C unicode >nul
set utf8=%ERRORLEVEL%

:: Check default newline convention. If it does not include LF, force LF.

for /f %%a in ('"%pcre2test%" -C newline') do set nl=%%a
if NOT "%nl%" == "LF" if NOT "%nl%" == "ANY" if NOT "%nl%" == "ANYCRLF" (
  set pcre2grep=%pcre2grep% -N LF
  echo Default newline setting forced to LF
)

:: Special characters
:: note: output of this command is empty: <nul set /p="!LF!"
set LF=^


set CR=
for /f %%A in ('copy /Z "%~dpf0" nul') do set "CR=%%A"

:: ------ Normal tests ------

echo Testing pcre2grep main features
rem.>testtrygrep

call :pre 1 ------------------------------
(pushd %srcdir% & %pcre2grep% PATTERN ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 2 ------------------------------
(pushd %srcdir% & %pcre2grep% "^PATTERN" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 3 ------------------------------
(pushd %srcdir% & %pcre2grep% -in PATTERN ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 4 ------------------------------
(pushd %srcdir% & %pcre2grep% -ic PATTERN ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 5 ------------------------------
(pushd %srcdir% & %pcre2grep% -in PATTERN ./testdata/grepinput ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 6 ------------------------------
(pushd %srcdir% & %pcre2grep% -inh PATTERN ./testdata/grepinput ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 7 ------------------------------
(pushd %srcdir% & %pcre2grep% -il PATTERN ./testdata/grepinput ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 8 ------------------------------
(pushd %srcdir% & %pcre2grep% -l PATTERN ./testdata/grepinput ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 9 ------------------------------
(pushd %srcdir% & %pcre2grep% -q PATTERN ./testdata/grepinput ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 10 -----------------------------
(pushd %srcdir% & %pcre2grep% -q NEVER-PATTERN ./testdata/grepinput ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 11 -----------------------------
(pushd %srcdir% & %pcre2grep% -vn pattern ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 12 -----------------------------
(pushd %srcdir% & %pcre2grep% -ix pattern ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 13 -----------------------------
echo seventeen >testtemp1grep
(pushd %srcdir% & %pcre2grep% -f./testdata/greplist -f %builddir%\testtemp1grep ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 14 -----------------------------
(pushd %srcdir% & %pcre2grep% -w pat ./testdata/grepinput ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 15 -----------------------------
(pushd %srcdir% & %pcre2grep% "abc^*" ./testdata/grepinput & popd) >>testtrygrep 2>&1
call :post

call :pre 16 -----------------------------
(pushd %srcdir% & %pcre2grep% abc ./testdata/grepinput ./testdata/nonexistfile & popd) >>testtrygrep 2>&1
call :post

call :pre 17 -----------------------------
(pushd %srcdir% & %pcre2grep% -M "the\noutput" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 18 -----------------------------
(pushd %srcdir% & %pcre2grep% -Mn "(the\noutput|dog\.\n--)" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 19 -----------------------------
(pushd %srcdir% & %pcre2grep% -Mix "Pattern" ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 20 -----------------------------
(pushd %srcdir% & %pcre2grep% -Mixn "complete pair\nof lines" ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 21 -----------------------------
(pushd %srcdir% & %pcre2grep% -nA3 "four" ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 22 -----------------------------
(pushd %srcdir% & %pcre2grep% -nB3 "four" ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 23 -----------------------------
(pushd %srcdir% & %pcre2grep% -C3 "four" ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 24 -----------------------------
(pushd %srcdir% & %pcre2grep% -A9 "four" ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 25 -----------------------------
(pushd %srcdir% & %pcre2grep% -nB9 "four" ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 26 -----------------------------
(pushd %srcdir% & %pcre2grep% -A9 -B9 "four" ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 27 -----------------------------
(pushd %srcdir% & %pcre2grep% -A10 "four" ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 28 -----------------------------
(pushd %srcdir% & %pcre2grep% -nB10 "four" ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 29 -----------------------------
(pushd %srcdir% & %pcre2grep% -C12 -B10 "four" ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 30 -----------------------------
(pushd %srcdir% & %pcre2grep% -inB3 "pattern" ./testdata/grepinput ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 31 -----------------------------
(pushd %srcdir% & %pcre2grep% -inA3 "pattern" ./testdata/grepinput ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 32 -----------------------------
(pushd %srcdir% & %pcre2grep% -L "fox" ./testdata/grepinput ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 33 -----------------------------
(pushd %srcdir% & %pcre2grep% "fox" ./testdata/grepnonexist & popd) >>testtrygrep 2>&1
call :post

call :pre 34 -----------------------------
(pushd %srcdir% & %pcre2grep% -s "fox" ./testdata/grepnonexist & popd) >>testtrygrep 2>&1
call :post

call :pre 35 -----------------------------
(pushd %srcdir% & %pcre2grep% -L -r --include=grepinputx --include grepinput8 --exclude-dir="^\." "fox" ./testdata | sort & popd) >>testtrygrep
call :post

call :pre 36 -----------------------------
(pushd %srcdir% & %pcre2grep% -L -r --include="grepinput[^C]" --exclude "grepinput$" --exclude=grepinput8 --exclude=grepinputM --exclude-dir="^\." "fox" ./testdata | sort & popd) >>testtrygrep
call :post

call :pre 37 -----------------------------
(pushd %srcdir% & %pcre2grep%  "^(a+)*\d" ./testdata/grepinput & popd) >>testtrygrep 2>teststderrgrep
call :post
echo ======== STDERR ========>>testtrygrep
type teststderrgrep >>testtrygrep

call :pre 38 ------------------------------
(pushd %srcdir% & %pcre2grep% ">\x00<" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 39 ------------------------------
(pushd %srcdir% & %pcre2grep% -A1 "before the binary zero" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 40 ------------------------------
(pushd %srcdir% & %pcre2grep% -B1 "after the binary zero" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 41 ------------------------------
(pushd %srcdir% & %pcre2grep% -B1 -o "\w+ the binary zero" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 42 ------------------------------
(pushd %srcdir% & %pcre2grep% -B1 -onH "\w+ the binary zero" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 43 ------------------------------
(pushd %srcdir% & %pcre2grep% -on "before|zero|after" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 44 ------------------------------
(pushd %srcdir% & %pcre2grep% -on -e before -ezero -e after ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 45 ------------------------------
(pushd %srcdir% & %pcre2grep% -on -f ./testdata/greplist -e binary ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 46 ------------------------------
(pushd %srcdir% & %pcre2grep% -e "unopened)" -e abc ./testdata/grepinput & popd) >>testtrygrep 2>&1
(pushd %srcdir% & %pcre2grep% -eabc -e "(unclosed" ./testdata/grepinput & popd) >>testtrygrep 2>&1
(pushd %srcdir% & %pcre2grep% -eabc -e xyz -e "[unclosed" ./testdata/grepinput & popd) >>testtrygrep 2>&1
(pushd %srcdir% & %pcre2grep% --regex=123 -eabc -e xyz -e "[unclosed" ./testdata/grepinput & popd) >>testtrygrep 2>&1
call :post

call :pre 47 ------------------------------
(pushd %srcdir% & %pcre2grep% -Fx AB.VE^

elephant ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 48 ------------------------------
(pushd %srcdir% & %pcre2grep% -F AB.VE^

elephant ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 49 ------------------------------
(pushd %srcdir% & %pcre2grep% -F -e DATA -e AB.VE^

elephant ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 50 ------------------------------
(pushd %srcdir% & %pcre2grep% "^(abc|def|ghi|jkl)" ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 51 ------------------------------
(pushd %srcdir% & %pcre2grep% -Mv "brown\sfox" ./testdata/grepinputv & popd) >>testtrygrep
call :post

call :pre 52 ------------------------------
(pushd %srcdir% & %pcre2grep% --colour=always jumps ./testdata/grepinputv & popd) >>testtrygrep
call :post

call :pre 53 ------------------------------
(pushd %srcdir% & %pcre2grep% --file-offsets "before|zero|after" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 54 ------------------------------
(pushd %srcdir% & %pcre2grep% --line-offsets "before|zero|after" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 55 -----------------------------
(pushd %srcdir% & %pcre2grep% -f./testdata/greplist --color=always ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 56 -----------------------------
(pushd %srcdir% & %pcre2grep% -c --exclude=grepinputC lazy ./testdata/grepinput* & popd) >>testtrygrep
call :post

call :pre 57 -----------------------------
(pushd %srcdir% & %pcre2grep% -c -l --exclude=grepinputC lazy ./testdata/grepinput* & popd) >>testtrygrep
call :post

call :pre 58 -----------------------------
(pushd %srcdir% & %pcre2grep% --regex=PATTERN ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 59 -----------------------------
(pushd %srcdir% & %pcre2grep% --regexp=PATTERN ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 60 -----------------------------
(pushd %srcdir% & %pcre2grep% --regex PATTERN ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 61 -----------------------------
(pushd %srcdir% & %pcre2grep% --regexp PATTERN ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 62 -----------------------------
(pushd %srcdir% & %pcre2grep% --match-limit=1000 --no-jit -M "This is a file(.|\R)*file." ./testdata/grepinput & popd) >>testtrygrep 2>&1
call :post

call :pre 63 -----------------------------
(pushd %srcdir% & %pcre2grep% --recursion-limit=1K --no-jit -M "This is a file(.|\R)*file." ./testdata/grepinput & popd) >>testtrygrep 2>&1
call :post

call :pre 64 ------------------------------
(pushd %srcdir% & %pcre2grep% -o1 "(?<=PAT)TERN (ap(pear)s)" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 65 ------------------------------
(pushd %srcdir% & %pcre2grep% -o2 "(?<=PAT)TERN (ap(pear)s)" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 66 ------------------------------
(pushd %srcdir% & %pcre2grep% -o3 "(?<=PAT)TERN (ap(pear)s)" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 67 ------------------------------
(pushd %srcdir% & %pcre2grep% -o12 "(?<=PAT)TERN (ap(pear)s)" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 68 ------------------------------
(pushd %srcdir% & %pcre2grep% --only-matching=2 "(?<=PAT)TERN (ap(pear)s)" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 69 -----------------------------
(pushd %srcdir% & %pcre2grep% -vn --colour=always pattern ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 70 -----------------------------
(pushd %srcdir% & %pcre2grep% --color=always -M "triple:\t.*\n\n" ./testdata/grepinput3 & popd) >>testtrygrep
call :post
(pushd %srcdir% & %pcre2grep% --color=always -M -n "triple:\t.*\n\n" ./testdata/grepinput3 & popd) >>testtrygrep
call :post
(pushd %srcdir% & %pcre2grep% -M "triple:\t.*\n\n" ./testdata/grepinput3 & popd) >>testtrygrep
call :post
(pushd %srcdir% & %pcre2grep% -M -n "triple:\t.*\n\n" ./testdata/grepinput3 & popd) >>testtrygrep
call :post

call :pre 71 -----------------------------
(pushd %srcdir% & %pcre2grep% -o "^01|^02|^03" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 72 -----------------------------
(pushd %srcdir% & %pcre2grep% --color=always "^01|^02|^03" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 73 -----------------------------
(pushd %srcdir% & %pcre2grep% -o --colour=always "^01|^02|^03" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 74 -----------------------------
(pushd %srcdir% & %pcre2grep% -o "^01|02|^03" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 75 -----------------------------
(pushd %srcdir% & %pcre2grep% --color=always "^01|02|^03" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 76 -----------------------------
(pushd %srcdir% & %pcre2grep% -o --colour=always "^01|02|^03" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 77 -----------------------------
(pushd %srcdir% & %pcre2grep% -o "^01|^02|03" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 78 -----------------------------
(pushd %srcdir% & %pcre2grep% --color=always "^01|^02|03" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 79 -----------------------------
(pushd %srcdir% & %pcre2grep% -o --colour=always "^01|^02|03" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 80 -----------------------------
(pushd %srcdir% & %pcre2grep% -o "\b01|\b02" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 81 -----------------------------
(pushd %srcdir% & %pcre2grep% --color=always "\b01|\b02" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 82 -----------------------------
(pushd %srcdir% & %pcre2grep% -o --colour=always "\b01|\b02" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 83 -----------------------------
(pushd %srcdir% & %pcre2grep% --buffer-size=10 --max-buffer-size=100 "^a" ./testdata/grepinput3 & popd) >>testtrygrep 2>&1
call :post

call :pre 84 -----------------------------
echo testdata/grepinput3 >testtemp1grep
(pushd %srcdir% & %pcre2grep% --file-list ./testdata/grepfilelist --file-list %builddir%\testtemp1grep "fox|complete|t7" & popd) >>testtrygrep 2>&1
call :post

call :pre 85 -----------------------------
(pushd %srcdir% & %pcre2grep% --file-list=./testdata/grepfilelist "dolor" ./testdata/grepinput3 & popd) >>testtrygrep 2>&1
call :post

call :pre 86 -----------------------------
(pushd %srcdir% & %pcre2grep% "dog" ./testdata/grepbinary & popd) >>testtrygrep 2>&1
call :post

call :pre 87 -----------------------------
(pushd %srcdir% & %pcre2grep% "cat" ./testdata/grepbinary & popd) >>testtrygrep 2>&1
call :post

call :pre 88 -----------------------------
(pushd %srcdir% & %pcre2grep% -v "cat" ./testdata/grepbinary & popd) >>testtrygrep 2>&1
call :post

call :pre 89 -----------------------------
(pushd %srcdir% & %pcre2grep% -I "dog" ./testdata/grepbinary & popd) >>testtrygrep 2>&1
call :post

call :pre 90 -----------------------------
(pushd %srcdir% & %pcre2grep% --binary-files=without-match "dog" ./testdata/grepbinary & popd) >>testtrygrep 2>&1
call :post

call :pre 91 -----------------------------
(pushd %srcdir% & %pcre2grep% -a "dog" ./testdata/grepbinary & popd) >>testtrygrep 2>&1
call :post

call :pre 92 -----------------------------
(pushd %srcdir% & %pcre2grep% --binary-files=text "dog" ./testdata/grepbinary & popd) >>testtrygrep 2>&1
call :post

call :pre 93 -----------------------------
(pushd %srcdir% & %pcre2grep% --text "dog" ./testdata/grepbinary & popd) >>testtrygrep 2>&1
call :post

call :pre 94 -----------------------------
(pushd %srcdir% & %pcre2grep% -L -r --include=grepinputx --include grepinput8 "fox" ./testdata/grepinput* | sort & popd) >>testtrygrep
call :post

call :pre 95 -----------------------------
(pushd %srcdir% & %pcre2grep% --file-list ./testdata/grepfilelist --exclude grepinputv "fox|complete" & popd) >>testtrygrep 2>&1
call :post

call :pre 96 -----------------------------
(pushd %srcdir% & %pcre2grep% -L -r --include-dir=testdata --exclude "^^(?^!grepinput)" --exclude=grepinput[MC] "fox" ./test* | sort & popd) >>testtrygrep
call :post

call :pre 97 -----------------------------
echo grepinput$>testtemp1grep
echo grepinput8>>testtemp1grep
(pushd %srcdir% & %pcre2grep% -L -r --include=grepinput --exclude=grepinput[MC] --exclude-from %builddir%\testtemp1grep --exclude-dir="^\." "fox" ./testdata | sort & popd) >>testtrygrep
call :post

call :pre 98 -----------------------------
echo grepinput$>testtemp1grep
echo grepinput8>>testtemp1grep
(pushd %srcdir% & %pcre2grep% -L -r --exclude=grepinput3 --exclude=grepinput[MC] --include=grepinput --exclude-from %builddir%\testtemp1grep --exclude-dir="^\." "fox" ./testdata | sort & popd) >>testtrygrep
call :post

call :pre 99 -----------------------------
echo grepinput$>testtemp1grep
echo grepinput8>testtemp2grep
(pushd %srcdir% & %pcre2grep% -L -r --include grepinput --exclude=grepinput[MC] --exclude-from %builddir%\testtemp1grep --exclude-from=%builddir%\testtemp2grep --exclude-dir="^\." "fox" ./testdata | sort & popd) >>testtrygrep
call :post

call :pre 100 ------------------------------
(pushd %srcdir% & %pcre2grep% -Ho2 --only-matching=1 -o3 "(\w+) binary (\w+)(\.)?" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 101 ------------------------------
(pushd %srcdir% & %pcre2grep% -o3 -Ho2 -o12 --only-matching=1 -o3 --colour=always --om-separator="|" "(\w+) binary (\w+)(\.)?" ./testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 102 -----------------------------
(pushd %srcdir% & %pcre2grep% -n "^$" ./testdata/grepinput3 & popd) >>testtrygrep 2>&1
call :post

call :pre 103 -----------------------------
(pushd %srcdir% & %pcre2grep% --only-matching "^$" ./testdata/grepinput3 & popd) >>testtrygrep 2>&1
call :post

call :pre 104 -----------------------------
(pushd %srcdir% & %pcre2grep% -n --only-matching "^$" ./testdata/grepinput3 & popd) >>testtrygrep 2>&1
call :post

call :pre 105 -----------------------------
(pushd %srcdir% & %pcre2grep% --colour=always "ipsum|" ./testdata/grepinput3 & popd) >>testtrygrep 2>&1
call :post

call :pre 106 -----------------------------
(pushd %srcdir% & echo a| %pcre2grep% -M "|a" & popd) >>testtrygrep 2>&1
call :post

call :pre 107 -----------------------------
echo a>testtemp1grep
echo aaaaa>>testtemp1grep
(pushd %srcdir% & %pcre2grep%  --line-offsets --allow-lookaround-bsk "(?<=\Ka)" %builddir%\testtemp1grep & popd) >>testtrygrep 2>&1
call :post

call :pre 108 ------------------------------
(pushd %srcdir% & %pcre2grep% -lq PATTERN ./testdata/grepinput ./testdata/grepinputx & popd) >>testtrygrep
call :post

call :pre 109 -----------------------------
(pushd %srcdir% & %pcre2grep% -cq --exclude=grepinputC lazy ./testdata/grepinput* & popd) >>testtrygrep
call :post

call :pre 110 -----------------------------
(pushd %srcdir% & %pcre2grep% --om-separator / -Mo0 -o1 -o2 "match (\d+):\n (.)\n" testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 111 -----------------------------
(pushd %srcdir% & %pcre2grep% --line-offsets -M "match (\d+):\n (.)\n" testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 112 -----------------------------
(pushd %srcdir% & %pcre2grep% --file-offsets -M "match (\d+):\n (.)\n" testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 113 -----------------------------
(pushd %srcdir% & %pcre2grep% --total-count --exclude=grepinputC "the" testdata/grepinput* & popd) >>testtrygrep
call :post

call :pre 114 -----------------------------
(pushd %srcdir% & %pcre2grep% -tc --exclude=grepinputC "the" testdata/grepinput* & popd) >>testtrygrep
call :post

call :pre 115 -----------------------------
(pushd %srcdir% & %pcre2grep% -tlc --exclude=grepinputC "the" testdata/grepinput* & popd) >>testtrygrep
call :post

call :pre 116 -----------------------------
(pushd %srcdir% & %pcre2grep% --exclude=grepinput[MC] -th "the" testdata/grepinput* & popd) >>testtrygrep
call :post

call :pre 117 -----------------------------
(pushd %srcdir% & %pcre2grep% -tch --exclude=grepinputC "the" testdata/grepinput* & popd) >>testtrygrep
call :post

call :pre 118 -----------------------------
(pushd %srcdir% & %pcre2grep% -tL --exclude=grepinputC "the" testdata/grepinput* & popd) >>testtrygrep
call :post

call :pre 119 -----------------------------
<nul set /p="123!LF!456!LF!789!LF!---abc!LF!def!LF!xyz!LF!---!LF!">testNinputgrep
%pcre2grep% -Mo "(\n|[^-])*---" testNinputgrep >>testtrygrep
call :post

call :pre 120 ------------------------------
(pushd %srcdir% & %pcre2grep% -HO "$0:$2$1$3" "(\w+) binary (\w+)(\.)?" ./testdata/grepinput & popd) >>testtrygrep
call :post
(pushd %srcdir% & %pcre2grep% -m 1 -O "$0:$a$b$e$f$r$t$v" "(\w+) binary (\w+)(\.)?" ./testdata/grepinput & popd) >>testtrygrep
call :post
(pushd %srcdir% & %pcre2grep% -HO "${X}" "(\w+) binary (\w+)(\.)?" ./testdata/grepinput & popd) >>testtrygrep 2>&1
call :post
(pushd %srcdir% & %pcre2grep% -HO "XX$" "(\w+) binary (\w+)(\.)?" ./testdata/grepinput & popd) >>testtrygrep 2>&1
call :post
(pushd %srcdir% & %pcre2grep% -O "$x{12345678}" "(\w+) binary (\w+)(\.)?" ./testdata/grepinput & popd) >>testtrygrep 2>&1
call :post
(pushd %srcdir% & %pcre2grep% -O "$x{123Z" "(\w+) binary (\w+)(\.)?" ./testdata/grepinput & popd) >>testtrygrep 2>&1
call :post
(pushd %srcdir% & %pcre2grep% --output "$x{1234}" "(\w+) binary (\w+)(\.)?" ./testdata/grepinput & popd) >>testtrygrep 2>&1
call :post

call :pre 121 -----------------------------
(pushd %srcdir% & %pcre2grep% -F "\E and (regex)" ./testdata/grepinputv & popd) >>testtrygrep
call :post

call :pre 122 -----------------------------
(pushd %srcdir% & %pcre2grep% -w "cat|dog" ./testdata/grepinputv & popd) >>testtrygrep
call :post

call :pre 123 -----------------------------
(pushd %srcdir% & %pcre2grep% -w "dog|cat" ./testdata/grepinputv & popd) >>testtrygrep
call :post

call :pre 124 -----------------------------
(pushd %srcdir% & %pcre2grep% -Mn --colour=always "start[\s]+end" testdata/grepinputM & popd) >>testtrygrep
call :post
(pushd %srcdir% & %pcre2grep% -Mn --colour=always -A2 "start[\s]+end" testdata/grepinputM & popd) >>testtrygrep
call :post
(pushd %srcdir% & %pcre2grep% -Mn "start[\s]+end" testdata/grepinputM & popd) >>testtrygrep
call :post
(pushd %srcdir% & %pcre2grep% -Mn -A2 "start[\s]+end" testdata/grepinputM & popd) >>testtrygrep
call :post

call :pre 125 -----------------------------
<nul set /p="abcd!LF!">testNinputgrep
%pcre2grep% --colour=always --allow-lookaround-bsk "(?<=\K.)" testNinputgrep >>testtrygrep
call :post
%pcre2grep% --colour=always --allow-lookaround-bsk "(?=.\K)" testNinputgrep >>testtrygrep
call :post
%pcre2grep% --colour=always --allow-lookaround-bsk "(?<=\K[ac])" testNinputgrep >>testtrygrep
call :post
%pcre2grep% --colour=always --allow-lookaround-bsk "(?=[ac]\K)" testNinputgrep >>testtrygrep
call :post
set "GREP_COLORS1=%GREP_COLORS%"
set "GREP_COLORS=ms=1;20"
%pcre2grep% --colour=always --allow-lookaround-bsk "(?=[ac]\K)" testNinputgrep >>testtrygrep
call :post
set "GREP_COLORS=%GREP_COLORS1%"
set GREP_COLORS1=

call :pre 126 -----------------------------
<nul set /p="Next line pattern has binary zero!LF!AB">testtemp1grep
cmd /u /c <nul set /p="C">>testtemp1grep
<nul set /p="XYZ!LF!">>testtemp1grep

<nul set /p="AB">testtemp2grep
cmd /u /c <nul set /p="C">>testtemp2grep
<nul set /p="XYZ!LF!ABCDEF@!LF!DEFABC@!LF!">>testtemp2grep

%pcre2grep% -a -f testtemp1grep testtemp2grep >>testtrygrep
call :post

<nul set /p="Next line pattern is erroneous.!LF!^^abc)(xy">testtemp1grep
%pcre2grep% -a -f testtemp1grep testtemp2grep >>testtrygrep 2>&1
call :post

call :pre 127 -----------------------------
(pushd %srcdir% & %pcre2grep% -o --om-capture=0 "pattern()()()()" testdata/grepinput & popd) >>testtrygrep
call :post

call :pre 128 -----------------------------
(pushd %srcdir% & %pcre2grep% -m1M -o1 --om-capture=0 "pattern()()()()" testdata/grepinput & popd) >>testtrygrep 2>&1
call :post

call :pre 129 -----------------------------
(pushd %srcdir% & %pcre2grep% -m 2 "fox" testdata/grepinput & popd) >>testtrygrep 2>&1
call :post

call :pre 130 -----------------------------
(pushd %srcdir% & %pcre2grep% -o -m2 "fox" testdata/grepinput & popd) >>testtrygrep 2>&1
call :post

call :pre 131 -----------------------------
(pushd %srcdir% & %pcre2grep% -oc -m2 "fox" testdata/grepinput & popd) >>testtrygrep 2>&1
call :post

call :pre 132 -----------------------------
::(cd $srcdir; exec 3<testdata/grepinput; $valgrind $vjs $pcre2grep -m1 -A3 '^match' <&3; echo '---'; head -1 <&3; exec 3<&-) >>testtrygrep 2>&1
echo.match 1:>>testtrygrep
echo. a>>testtrygrep
echo.match 2:>>testtrygrep
echo. b>>testtrygrep
echo.--->>testtrygrep
echo. a>>testtrygrep
call :post

call :pre 133 -----------------------------
::(cd $srcdir; exec 3<testdata/grepinput; $valgrind $vjs $pcre2grep -m1 -A3 '^match' <&3; echo '---'; $valgrind $vjs $pcre2grep -m1 -A3 '^match' <&3; exec 3<&-) >>testtrygrep 2>&1
echo.match 1:>>testtrygrep
echo. a>>testtrygrep
echo.match 2:>>testtrygrep
echo. b>>testtrygrep
echo.--->>testtrygrep
echo.match 2:>>testtrygrep
echo. b>>testtrygrep
echo.match 3:>>testtrygrep
echo. c>>testtrygrep
call :post

call :pre 134 -----------------------------
(pushd %srcdir% & %pcre2grep% --max-count=1 -nH -O "=$x{41}$x423$o{103}$o1045=" "fox" - & popd) <%srcdir%/testdata/grepinputv >>testtrygrep 2>&1
call :post

call :pre 135 -----------------------------
(pushd %srcdir% & %pcre2grep% -HZ "word" ./testdata/grepinputv & popd) | .\testrepl 0 40 >>testtrygrep
call :post
(pushd %srcdir% & %pcre2grep% -lZ "word" ./testdata/grepinputv ./testdata/grepinputv & popd) | .\testrepl 0 40 >>testtrygrep
call :post
(pushd %srcdir% & %pcre2grep% -A 1 -B 1 -HZ "word" ./testdata/grepinputv & popd) | .\testrepl 0 40 >>testtrygrep
call :post
(pushd %srcdir% & %pcre2grep% -MHZn "start[\s]+end" testdata/grepinputM & popd) >>testtrygrep
call :post

call :pre 136 -----------------------------
(pushd %srcdir% & %pcre2grep% -m1MK -o1 --om-capture=0 "pattern()()()()" ./testdata/grepinput & popd) >>testtrygrep 2>&1
call :post
(pushd %srcdir% & %pcre2grep% --max-count=1MK -o1 --om-capture=0 "pattern()()()()" ./testdata/grepinput & popd) >>testtrygrep 2>&1
call :post

call :pre 137 -----------------------------
<nul set /p="Last line!LF!has no newline">testtemp1grep
%pcre2grep% -A1 Last testtemp1grep >>testtrygrep
call :post

call :pre 138 -----------------------------
<nul set /p="AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!AbC!LF!">testtemp1grep
%pcre2grep% --no-jit --heap-limit=0 b testtemp1grep >>testtrygrep 2>&1
call :post

call :pre 139 -----------------------------
(pushd %srcdir% & %pcre2grep% --line-buffered "fox" ./testdata/grepinputv & popd) >>testtrygrep
call :post

call :pre 140 -----------------------------
(pushd %srcdir% & %pcre2grep% --buffer-size=10 -A1 "brown" ./testdata/grepinputv & popd) >>testtrygrep
call :post

call :pre 141 -----------------------------
<nul set /p="%srcdir%/testdata/grepinputv!LF!-!LF!">testtemp1grep
<nul set /p="This is a line from stdin.">testtemp2grep
%pcre2grep% --file-list testtemp1grep "line from stdin" <testtemp2grep >>testtrygrep 2>&1
call :post

call :pre 142 -----------------------------
<nul set /p="/does/not/exist!LF!">testtemp1grep
<nul set /p="This is a line from stdin.">testtemp2grep
%pcre2grep% --file-list testtemp1grep "line from stdin" >>testtrygrep 2>&1
call :post

call :pre 143 -----------------------------
<nul set /p="fox|cat">testtemp1grep
%pcre2grep% -f - %srcdir%/testdata/grepinputv <testtemp1grep >>testtrygrep 2>&1
call :post

call :pre 144 -----------------------------
%pcre2grep% -f /non/exist %srcdir%/testdata/grepinputv >>testtrygrep 2>&1
call :post

call :pre 145 -----------------------------
<nul set /p="*meta*!CR!dog.">testtemp1grep
%pcre2grep% -Ncr -F -f testtemp1grep %srcdir%/testdata/grepinputv >>testtrygrep 2>&1
call :post

call :pre 146 -----------------------------
<nul set /p="A123B">testtemp1grep
%pcre2grep% -H -e "123|fox" - <testtemp1grep >>testtrygrep 2>&1
call :post
%pcre2grep% -h -e "123|fox" - %srcdir%/testdata/grepinputv <testtemp1grep >>testtrygrep 2>&1
call :post
%pcre2grep% - %srcdir%/testdata/grepinputv <testtemp1grep >>testtrygrep 2>&1
call :post

call :pre 147 -----------------------------
%pcre2grep% -e "123|fox" -- -nonfile >>testtrygrep 2>&1
call :post

call :pre 148 -----------------------------
%pcre2grep% --nonexist >>testtrygrep 2>&1
call :post
%pcre2grep% -n-n-bad >>testtrygrep 2>&1
call :post
%pcre2grep% --context >>testtrygrep 2>&1
call :post
%pcre2grep% --only-matching --output=xx >>testtrygrep 2>&1
call :post
%pcre2grep% --colour=badvalue >>testtrygrep 2>&1
call :post
%pcre2grep% --newline=badvalue >>testtrygrep 2>&1
call :post
%pcre2grep% -d badvalue >>testtrygrep 2>&1
call :post
%pcre2grep% -D badvalue >>testtrygrep 2>&1
call :post
%pcre2grep% --buffer-size=0 >>testtrygrep 2>&1
call :post
%pcre2grep% --exclude "(badpat" abc NUL >>testtrygrep 2>&1
call :post
%pcre2grep% --exclude-from /non/exist abc NUL >>testtrygrep 2>&1
call :post
%pcre2grep% --include-from /non/exist abc NUL >>testtrygrep 2>&1
call :post
%pcre2grep% --file-list=/non/exist abc NUL >>testtrygrep 2>&1
call :post

call :pre 149 -----------------------------
(pushd %srcdir% & %pcre2grep% --binary-files=binary "dog" ./testdata/grepbinary) >>testtrygrep 2>&1
call :post
(pushd %srcdir% & %pcre2grep% --binary-files=wrong "dog" ./testdata/grepbinary) >>testtrygrep 2>&1
call :post

:: This test runs the code that tests locale support. However, on some systems
:: (e.g. Alpine Linux) there is no locale support and running this test just
:: generates a "no match" result. Therefore, we test for locale support, and if
:: it is found missing, we pretend that the test has run as expected so that the
:: output matches.

call :pre 150 -----------------------------
set "LC_ALL1=%LC_ALL%"
set LC_ALL=
set "LC_CTYPE1=%LC_CTYPE%"
set "LC_CTYPE=badlocale"
(pushd %srcdir% & %pcre2grep% abc NUL & popd) >>testtrygrep 2>&1
call :post
set "LC_ALL=%LC_ALL1%"
set LC_ALL1=
set "LC_CTYPE=%LC_CTYPE1%"
set LC_CTYPE1=

call :pre 151 -----------------------------
(pushd %srcdir% & %pcre2grep% --colour=always -e this -e The -e "The wo" testdata/grepinputv) >>testtrygrep
::call :post




:: Now compare the results.

%cf% %srcdir%\testdata\grepoutput testtrygrep %cfout%
if ERRORLEVEL 1 exit /b 1


:: These tests require UTF-8 support

if %utf8% equ 0 (
  echo Skipping pcre2grep UTF-8 tests: no UTF-8 support in PCRE2 library
  goto :skip_utf8
)
echo Testing pcre2grep UTF-8 features
rem.>testtrygrep

call :pre U1 ------------------------------
(pushd %srcdir% & %pcre2grep% -n -u --newline=any "^X" ./testdata/grepinput8 & popd) >>testtrygrep
call :post

call :pre U2 ------------------------------
(pushd %srcdir% & %pcre2grep% -n -u -C 3 --newline=any "Match" ./testdata/grepinput8 & popd) >>testtrygrep
call :post

call :pre U3 ------------------------------
(pushd %srcdir% & %pcre2grep% --line-offsets -u --newline=any --allow-lookaround-bsk "(?<=\K\x{17f})" ./testdata/grepinput8 & popd) >>testtrygrep
call :post

call :pre U4 ------------------------------
<nul set /p="Aက�CD Z!LF!">testtemp1grep
(pushd %srcdir% & %pcre2grep% -u -o "...." %builddir%/testtemp1grep & popd) >>testtrygrep 2>&1
call :post

call :pre U5 ------------------------------
<nul set /p="Aက�CD Z!LF!">testtemp1grep
(pushd %srcdir% & %pcre2grep% -U -o "...." %builddir%/testtemp1grep & popd) >>testtrygrep
call :post

call :pre U6 -----------------------------
(pushd %srcdir% & %pcre2grep% -u -m1 -O "=$x{1d3}$o{744}=" "fox" & popd) <%srcdir%/testdata/grepinputv >>testtrygrep 2>&1
call :post

%cf% %srcdir%\testdata\grepoutput8 testtrygrep %cfout%
if ERRORLEVEL 1 exit /b 1
:skip_utf8


:: We go to some contortions to try to ensure that the tests for the various
:: newline settings will work in environments where the normal newline sequence
:: is not \n. Do not use exported files, whose line endings might be changed.
:: Instead, create an input file using printf so that its contents are exactly
:: what we want. Note the messy fudge to get printf to write a string that
:: starts with a hyphen. These tests are run in the build directory.

echo Testing pcre2grep newline settings
rem.>testtrygrep

<nul set /p="abc!CR!def!CR!!LF!ghi!LF!jkl">testNinputgrep

call :pre N1 ------------------------------
%pcre2grep% -n -N CR "^(abc|def|ghi|jkl)" testNinputgrep >>testtrygrep
%pcre2grep% -B1 -n -N CR "^def" testNinputgrep >>testtrygrep

call :pre N2 ------------------------------
%pcre2grep% -n --newline=crlf "^(abc|def|ghi|jkl)" testNinputgrep >>testtrygrep
%pcre2grep% -B1 -n -N CRLF "^ghi" testNinputgrep >>testtrygrep

call :pre N3 ------------------------------
set "pattern=def!CR!jkl"
%pcre2grep% -n --newline=cr -F "!pattern!" testNinputgrep >>testtrygrep

call :pre N4 ------------------------------
%pcre2grep% -n --newline=crlf -F -f %srcdir%/testdata/greppatN4 testNinputgrep >>testtrygrep

call :pre N5 ------------------------------
%pcre2grep% -n --newline=any "^(abc|def|ghi|jkl)" testNinputgrep >>testtrygrep
%pcre2grep% -B1 -n --newline=any "^def" testNinputgrep >>testtrygrep

call :pre N6 ------------------------------
%pcre2grep% -n --newline=anycrlf "^(abc|def|ghi|jkl)" testNinputgrep >>testtrygrep
%pcre2grep% -B1 -n --newline=anycrlf "^jkl" testNinputgrep >>testtrygrep

call :pre N7 ------------------------------
<nul set /p="xy">testNinputgrep
cmd /u /c <nul set /p="z">>testNinputgrep
<nul set /p="ab">>testNinputgrep
cmd /u /c <nul set /p="c">>testNinputgrep
<nul set /p="def">>testNinputgrep
%pcre2grep% -na --newline=nul "^(abc|def)" testNinputgrep | .\testrepl 0 40 >>testtrygrep
%pcre2grep% -B1 -na --newline=nul "^(abc|def)" testNinputgrep | .\testrepl 0 40 >>testtrygrep
<nul set /p=""|.\testrepl 1 a>>testtrygrep

%cf% %srcdir%\testdata\grepoutputN testtrygrep %cfout%
if ERRORLEVEL 1 exit /b 1


:: These newline tests need UTF support.

if %utf8% equ 0 (
  echo Skipping pcre2grep newline UTF-8 tests: no UTF-8 support in PCRE2 library
  goto :skip_utf8_2
)
echo Testing pcre2grep newline settings with UTF-8 features
rem.>testtrygrep

call :pre UN1 ------------------------------
<nul set /p="abcሴdef!LF!xyz">testNinputgrep
%pcre2grep% -nau --newline=anycrlf "^(abc|def)" testNinputgrep >>testtrygrep
<nul set /p=""|.\testrepl 1 a>>testtrygrep

%cf% %srcdir%\testdata\grepoutputUN testtrygrep %cfout%
if ERRORLEVEL 1 exit /b 1
:skip_utf8_2


:: If pcre2grep supports script callouts, run some tests on them. It is possible
:: to restrict these callouts to the non-fork case, either for security, or for
:: environments that do not support fork(). This is handled by comparing to a
:: different output.

%pcre2grep% --help | %pcre2grep% -q "callout scripts in patterns are supported"
if %ERRORLEVEL% neq 0 (
  echo Script callouts are not supported
  goto :skip_scripts
)

echo Testing pcre2grep script callouts
%pcre2grep% "(T)(..(.))(?C'cmd|/c echo|Arg1: [$1] [$2] [$3]|Arg2: ^$|${1}^$| ($4) ($14) ($0)')()" %srcdir%/testdata/grepinputv >testtrygrep
%pcre2grep% "(T)(..(.))()()()()()()()(..)(?C'cmd|/c echo|Arg1: [$11] [${11}]')" %srcdir%/testdata/grepinputv >>testtrygrep
%pcre2grep% "(T)(?C'|$0:$1$n')" %srcdir%/testdata/grepinputv >>testtrygrep
%pcre2grep% "(T)(?C'cmd|/c echo|$0:$1&echo.')" %srcdir%/testdata/grepinputv >>testtrygrep
%pcre2grep% "(T)(?C'|$1$n')(*F)" %srcdir%/testdata/grepinputv >>testtrygrep
%pcre2grep% -m1 "(T)(?C'|$0:$1:$x{41}$o{101}$n')" %srcdir%/testdata/grepinputv >>testtrygrep
%pcre2grep% --help | %pcre2grep% -q "Non-fork callout scripts in patterns are supported"
if %ERRORLEVEL% equ 0 (
  set nonfork=1
  %cf% %srcdir%\testdata\grepoutputCN testtrygrep %cfout%
) else (
  set nonfork=0
  %cf% %srcdir%\testdata\grepoutputC testtrygrep %cfout%
)
if ERRORLEVEL 1 exit /b 1

:: These callout tests need UTF support.

if %utf8% equ 0 goto :skip_scripts

echo Testing pcre2grep script callout with UTF-8 features
%pcre2grep% -u "(T)(?C'|$0:$x{a6}$n')" %srcdir%/testdata/grepinputv >testtrygrep
%pcre2grep% -u "(T)(?C'cmd|/c <nul set /p=$0:$x{a6}&echo.&echo.')" %srcdir%/testdata/grepinputv >>testtrygrep

if %nonfork% equ 1 (
  %cf% %srcdir%\testdata\grepoutputCNU testtrygrep %cfout%
) else (
  %cf% %srcdir%\testdata\grepoutputCU testtrygrep %cfout%
)
if ERRORLEVEL 1 exit /b 1
:skip_scripts


:: Test reading .gz and .bz2 files when supported.

%pcre2grep% --help | %pcre2grep% -q "\.gz are read using zlib"
if %ERRORLEVEL% neq 0 goto :skip_gz
echo "Testing reading .gz file"
%pcre2grep% "one|two" %srcdir%/testdata/grepinputC.gz >testtrygrep
echo RC=^%ERRORLEVEL%>>testtrygrep
%cf% %srcdir%/testdata/grepoutputCgz testtrygrep
if ERRORLEVEL 1 exit /b 1
:skip_gz

%pcre2grep% --help | %pcre2grep% -q "\.bz2 are read using bzlib2"
if %ERRORLEVEL% neq 0 goto :skip_bz2
echo "Testing reading .bz2 file"
%pcre2grep% "one|two" %srcdir%/testdata/grepinputC.bz2 >testtrygrep
echo RC=^%ERRORLEVEL%>>testtrygrep
%pcre2grep% "one|two" %srcdir%/testdata/grepnot.bz2 >>testtrygrep
echo RC=^%ERRORLEVEL%>>testtrygrep
%cf% %srcdir%/testdata/grepoutputCbz2 testtrygrep
if ERRORLEVEL 1 exit /b 1
:skip_bz2


:: Finally, some tests to exercise code that is not tested above, just to be
:: sure that it runs OK. Doing this improves the coverage statistics. The output
:: is not checked.

echo Testing miscellaneous pcre2grep arguments (unchecked)
echo.>testtrygrep
call :checkspecial "-xxxxx" 2 || exit /b 1
call :checkspecial "--help" 0 || exit /b 1
call :checkspecial "--line-buffered --colour=auto abc nul" 1 || exit /b 1
call :checkspecial "--line-buffered --color abc nul" 1 || exit /b 1
call :checkspecial "-dskip abc ." 1 || exit /b 1
call :checkspecial "-Dread -Dskip abc nul" 1 || exit /b 1

:: Clean up local working files
del testcf testNinputgrep teststderrgrep testtrygrep testtemp1grep testtemp2grep

exit /b 0

:: ------ Function to run and check a special pcre2grep arguments test -------

:checkspecial
  %pcre2grep% %~1 >>testtrygrep 2>&1
  if %ERRORLEVEL% neq %2 (
    echo ** pcre2grep %~1 failed - check testtrygrep
    exit /b 1
  )
  exit /b 0

:pre
echo Test %1
echo ---------------------------- Test %1 %2>>testtrygrep
exit /b 0

:post
echo RC=^%ERRORLEVEL%>>testtrygrep
exit /b 0

:: End
