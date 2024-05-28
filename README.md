# Miscellaneous scripts
This is a collection of various scripts that I've created for my own specific purposes. I decided to share them with the community as examples of various tasks.

## locate_dolbyvision.sh

Used to find media where [Dolby Vision](https://en.wikipedia.org/wiki/Dolby_Vision) is the only HDR format. Useful when you are unable to play media encoded with Dolby Vision and there is no fallback format. It's somewhat common for DV encoded media to not be playable on various devices.

### Required applications:
-  mediainfo
*  pv

### Installation:
Download `find_dolby_vision.sh` and make the script executable with

    chmod +x find_dolby_vision.sh
### Run the script with optional switches:

> -d /path/to/media to specify the directory to search in.
>  
> -l /path/to/logfile.log to specify the log file where results should be saved. If not specified, it defaults to the current directory.
> 
> -p to enable the progress bar.

Example usage:
````
./find_dolby_vision.sh -d /path/to/movies -l /path/to/logfile.log -p
````
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 
# organize.ps1

This is a Powershell script that will read files from a directory and will move them to folders based on the first letter of the filename.

### Required applications:

- PowerShell 7

### Installation:
Download `organize.ps1`

### Run the script with required switches:

> -sourceDirectory "C:\path\to\your\source\directory"
> 
> -targetDirectory "C:\path\to\your\target\directory"

Example usage:
````
.\organize.ps1 -sourceDirectory "C:\path\to\your\source\directory" -targetDirectory "C:\path\to\your\target\directory"
````
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 
# archive-bins.ps1

This is a Powershell script that looks in rar archives with 7zip that include .bin files. It can create a CSV file with details of the .bin files and/or extract rar archives based on the included .bin files. Designed for use on Windows, Linux, MacOS systems with Powershell isntalled.

### Required applications:

- PowerShell 7
- 7zip
  
### Installation:
Download `archive-bins.ps1`
Install 7zip.exe, 7zip-full for Linux systems, brew install p7zip for MacOS

Example usage:
````
    pwsh -File .\archive-bins.ps1 -ExtractWithBinCount 4 -WhatIf
    Shows what would happen if you extract all .rar files with 4 .bin files without actually extracting them.

.EXAMPLE
    pwsh -File .\archive-bins.ps1 -ShowCounts -CreateCsv -CsvPath "C:\Temp\bins-in-rar.csv"
    Displays the counts of .rar files grouped by the number of .bin files and creates a CSV file named "bins-in-rar.csv" in the "C:\Temp" directory.

.EXAMPLE
    pwsh -File .\archive-bins.ps1 -ExtractAll -WorkingDirectory "C:\Temp\Working" -FinalDestination "C:\Temp\Final"
    Extracts all .rar files to the "C:\Temp\Working" directory and then moves the extracted files to the "C:\Temp\Final" directory.
````
