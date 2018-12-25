# grep-windows
Instructions for building [Gnu Grep](https://www.gnu.org/software/grep) as a native windows application

All patches under the same license as sources of [Gnu Grep](https://www.gnu.org/software/grep): [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html) or later

Author of the patches: Michael M. Builov (mbuilov@gmail.com)

## Known bugs of this build:
- support for Perl regular expressions is not compiled in
- search in sub-directories is not working (grep -r produces "warning: xxx: recursive directory loop")
- output is colorized via ANSI escape sequences, but standard Windows console (at least on Win7) does not understand them

## Pre-built executables:
- [`grep-3.3-x64.exe`](/grep-3.3-x64.exe) - grep 3.3 built for windows7 x64

## Instructions how to create build patch
- [`grep-3.3-build-patch-howto.txt`](/grep-3.3-build-patch-howto.txt)

## Prepared build patches
For x64/Windows7/VS17:
- [`grep-3.3-build-VS17-x64.txt`](/grep-3.3-build-VS17-x64.txt) - instructions how to apply the patch to compile grep using native tools only
- [`grep-3.3-build-VS17-x64.patch`](/grep-3.3-build-VS17-x64.patch)
