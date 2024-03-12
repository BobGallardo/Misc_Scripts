# Miscellaneous Scripts

## locate_dolbyvision.sh

Used to find media where [Dolby Vision](https://en.wikipedia.org/wiki/Dolby_Vision) is the only HDR format. Useful when you are unable to play media encoded with Dolby Vision and there is no fallback format. It's common for DV encoded media to not be playable on various devices.

### required applications

> mediainfo, pv

#### Installation
download `find_dolby_vision.sh` and make the script executable with

    chmod +x find_dolby_vision.sh
#### Run the script with optional switches:
```
-d /path/to/media to specify the directory to search in.
-l /path/to/logfile.log to specify the log file where results should be saved. If not specified, it defaults to the current directory.
-p to enable the progress bar.
```
Example usage:

    ./find_dolby_vision.sh -d /path/to/movies -l /path/to/logfile.log -p




## organize.ps1

This is a powershell script that will read files from a directory and will move them to folders based on the first letter of the filename..

### required applications

> PowerShell 7

#### Installation
download `organize.ps1`

#### Run the script with required switches:
```
-sourceDirectory "C:\path\to\your\source\directory"
-targetDirectory "C:\path\to\your\target\directory"
```
Example usage:

    .\organize.ps1 -sourceDirectory "C:\path\to\your\source\directory" -targetDirectory "C:\path\to\your\target\directory"

