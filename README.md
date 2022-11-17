# grep-windows
Instructions for building [Gnu Grep](https://www.gnu.org/software/grep) and [pcre2grep](https://github.com/PCRE2Project/pcre2) as a native windows application

All patches under the same license as sources of [Gnu Grep](https://www.gnu.org/software/grep): [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html) or later

Author of the patches: Michael M. Builov (mbuilov@yandex.ru)

## Known bugs of this build of Gnu grep
- search in sub-directories is not working (grep -r produces "warning: xxx: recursive directory loop")

## Changes since windows build of Gnu grep-3.3
- fixed support for colorizing output of grep in Windows console (enabled via '--color' option; tip: use "color" command to reset console colors)

## Changes since windows build of Gnu grep-3.7
- now support for Perl regular expressions is statically complied in the grep executable

## Pre-built executables:
- [`grep-3.8-x64.exe`](/grep-3.8-x64.exe) - grep 3.8 built for Windows10 x64
- [`grep-3.8-x86.exe`](/grep-3.8-x86.exe) - grep 3.8 built for WindowsXP x86
- [`pcre2grep-10.40-x64.exe`](/pcre2grep-10.40-x64.exe) - pcre2grep 10.40 built for Windows10 x64
- [`pcre2grep-10.40-x86.exe`](/pcre2grep-10.40-x86.exe) - pcre2grep 10.40 built for WindowsXP x86

## Instructions how to create build patch
- [`grep-3.8-build-patch-howto.txt`](/grep-3.8-build-patch-howto.txt)

## Instructions how to apply build patch to compile grep using native tools only
- [`grep-3.8-build.txt`](/grep-3.8-build.txt)

## Prepared build patches
For x64/Windows10/VS22:
- [`grep-3.8-build-VS22-x64.patch`](/grep-3.8-build-VS22-x64.patch)

For x86/WindowsXP/VS22:
- [`grep-3.8-build-VS22-x86.patch`](/grep-3.8-build-VS22-x86.patch)
