<#
.SYNOPSIS
    Organizes files into directories based on the first character of their filenames.

.DESCRIPTION
    This script reads files from a specified source directory and organizes them into subdirectories within a specified destination directory based on the first character of each file's name. Letters result in alphabetical subdirectories, while numbers and special characters are grouped under '0-9_Special'.

.PARAMETER SourceDirectory
    The path to the source directory from which files will be read.

.PARAMETER TargetDirectory
    The path to the target directory where files will be organized into subdirectories.

.EXAMPLE
    .\Organize-Files.ps1 -SourceDirectory "C:\MyFiles" -TargetDirectory "C:\OrganizedFiles"
    Organizes files from "C:\MyFiles" into subdirectories within "C:\OrganizedFiles" based on the first character of each file's name.

.NOTES
    Version:        1.0
    Author:         Bob Gallardo
    Creation Date:  2024-03-11
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$SourceDirectory,

    [Parameter(Mandatory=$true)]
    [string]$TargetDirectory
)

# Ensure the source directory exists
if (-not (Test-Path -Path $SourceDirectory)) {
    Write-Error "Source directory does not exist: $SourceDirectory"
    exit
}

# Ensure the target directory exists
if (-not (Test-Path -Path $TargetDirectory)) {
    Write-Error "Target directory does not exist: $TargetDirectory"
    exit
}

# Get all files in the source directory
$files = Get-ChildItem -Path $SourceDirectory -File

# Use ForEach-Object for processing files
$files | ForEach-Object {
    # Determine the folder name based on the first character of the filename
    $firstChar = $_.Name.Substring(0,1)
    if ($firstChar -match "[A-Za-z]") {
        $folderName = $firstChar.ToUpper()
    } else {
        $folderName = "0-9_Special"
    }

    # Define the destination folder path
    $destinationFolder = Join-Path -Path $TargetDirectory -ChildPath $folderName

    # Check and create the destination folder if it doesn't exist
    if (-not (Test-Path -Path $destinationFolder)) {
        New-Item -Path $destinationFolder -ItemType Directory | Out-Null
    }

    # Move the file to the destination folder
    $destinationFile = Join-Path -Path $destinationFolder -ChildPath $_.Name
    Move-Item -Path $_.FullName -Destination $destinationFile -ErrorAction SilentlyContinue
}

Write-Host "Files have been organized."
