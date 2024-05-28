<#
.SYNOPSIS
    Processes .rar files to extract .bin files and optionally create a CSV database.

.DESCRIPTION
    This script processes all .rar files in the current directory to extract .bin files.
    It can create a CSV file listing the .rar archives and their .bin files, and display counts of archives grouped by the number of .bin files.
    The script also supports extracting the archives to specified working and final destination directories.
    The script detects the operating system and uses the appropriate version of 7z.

.PARAMETER ExtractAll
    Extract all .rar files.

.PARAMETER ExtractWithBinCount
    Specify the number of .bin files to filter .rar files for extraction.

.PARAMETER WhatIf
    Test the script without extracting the archives.

.PARAMETER ShowCounts
    Show the total counts of .rar files grouped by the number of .bin files.

.PARAMETER CreateCsv
    Switch to create the CSV file.

.PARAMETER CsvPath
    Path and name for the output CSV file, defaulting to "bins-in-rar.csv" in the current directory.

.PARAMETER WorkingDirectory
    Specifies the working directory for extraction, defaulting to the current directory.

.PARAMETER FinalDestination
    Specifies the final destination directory for extracted files, defaulting to the current directory.

.PARAMETER SevenZipPath
    Specify the location of 7z executable if it's not in the default location or PATH.

.EXAMPLE
    # On Windows
    pwsh -File .\archive-bins.ps1 -ExtractWithBinCount 4 -WhatIf

    Shows what would happen if you extract all .rar files with 4 .bin files without actually extracting them.

.EXAMPLE
    # On Linux or macOS
    pwsh -File ./archive-bins.ps1 -ExtractWithBinCount 4 -WhatIf

    Shows what would happen if you extract all .rar files with 4 .bin files without actually extracting them.

.EXAMPLE
    # On Windows
    pwsh -File .\archive-bins.ps1 -ShowCounts -CreateCsv -CsvPath "C:\Temp\bins-in-rar.csv"

    Displays the counts of .rar files grouped by the number of .bin files and creates a CSV file named "bins-in-rar.csv" in the "C:\Temp" directory.

.EXAMPLE
    # On Linux or macOS
    pwsh -File ./archive-bins.ps1 -ShowCounts -CreateCsv -CsvPath "/tmp/bins-in-rar.csv"

    Displays the counts of .rar files grouped by the number of .bin files and creates a CSV file named "bins-in-rar.csv" in the "/tmp" directory.

.EXAMPLE
    # On Windows
    pwsh -File .\archive-bins.ps1 -ExtractAll -WorkingDirectory "C:\Temp\Working" -FinalDestination "C:\Temp\Final"

    Extracts all .rar files to the "C:\Temp\Working" directory and then moves the extracted files to the "C:\Temp\Final" directory.

.EXAMPLE
    # On Linux or macOS
    pwsh -File ./archive-bins.ps1 -ExtractAll -WorkingDirectory "/tmp/working" -FinalDestination "/tmp/final"

    Extracts all .rar files to the "/tmp/working" directory and then moves the extracted files to the "/tmp/final" directory.
#>

param (
    [switch]$ExtractAll,                    # Extract all .rar files
    [int]$ExtractWithBinCount,              # Extract .rar files with a specified number of .bin files
    [switch]$WhatIf,                        # Test the script without extracting the archives
    [switch]$ShowCounts,                    # Show the total counts of .rar files grouped by the number of .bin files
    [switch]$CreateCsv,                     # Switch to create the CSV file
    [string]$CsvPath = "./bins-in-rar.csv", # Path and name for the output CSV file, default to "bins-in-rar.csv" in the current directory
    [string]$WorkingDirectory = ".",        # Working directory for extraction
    [string]$FinalDestination = ".",        # Final destination directory for extracted files
    [string]$SevenZipPath                    # Specify the location of 7z executable if it's not in the default location or PATH
)

# Detect the operating system and set the 7z command and path handling accordingly
if ($SevenZipPath) {
    $sevenZipCmd = $SevenZipPath
} else {
    if ($IsWindows) {
        $sevenZipCmd = "7z"
        if (-not (Get-Command $sevenZipCmd -ErrorAction SilentlyContinue)) {
            $sevenZipCmd = "C:\Program Files\7-Zip\7z.exe"
            if (-not (Test-Path $sevenZipCmd)) {
                Write-Error "7z.exe not found in PATH or 'C:\Program Files\7-Zip'. Please install 7-Zip or specify the location using -SevenZipPath."
                exit 1
            }
        }
    } elseif ($IsLinux -or $IsMacOS) {
        $sevenZipCmd = "7z"
        if (-not (Get-Command $sevenZipCmd -ErrorAction SilentlyContinue)) {
            Write-Error "7z not found in PATH. Please install p7zip-full, brew install p7zip (MacOS), or specify the location using -SevenZipPath."
            exit 1
        }
    } else {
        Write-Error "Unsupported operating system."
        exit 1
    }
}

# Initialize an array to store data
$data = @()

# Initialize a hash table to store all unique types across all .rar files
$allUniqueTypes = @{}

# Function to extract text between parentheses
function Extract-TextInParentheses {
    param (
        [string]$filename
    )
    if ($filename -match '\(([^)]+)\)') {
        return $matches[1]
    }
    return $null
}

# Loop through each .rar file to find all unique types
$rarFiles = Get-ChildItem -Filter *.rar
foreach ($rarFile in $rarFiles) {
    # Extract the list of .bin files
    $binFiles = & "$sevenZipCmd" l "$($rarFile.FullName)" | Select-String -Pattern '\.bin$' | ForEach-Object { $_.Line.Trim() }

    # Initialize a hash table to store counts of each unique type of .bin file for the current .rar file
    $binTypesCounts = @{}
    $binTypesCounts['Archive'] = $rarFile.Name
    $binTypesCounts['Number of BIN Files'] = 0

    # Loop through each .bin file
    foreach ($binFile in $binFiles) {
        $binText = Extract-TextInParentheses -filename $binFile

        # Update the count for the current type of .bin file
        if ($binText) {
            if (-not $binTypesCounts.ContainsKey($binText)) {
                $binTypesCounts[$binText] = 0
            }
            $binTypesCounts[$binText]++
            $allUniqueTypes[$binText] = $true
        }
        $binTypesCounts['Number of BIN Files']++
    }

    # Add the hash table to the data array
    $data += $binTypesCounts
}

# Prepare CSV header
$header = @('Archive', 'Number of BIN Files') + $allUniqueTypes.Keys

# Create CSV file if specified
if ($CreateCsv) {
    $csvFullPath = $CsvPath
    if ($WhatIf) {
        Write-Output "What-If: Would create CSV file at $csvFullPath"
    } else {
        $data | Select-Object $header | Export-Csv -Path $csvFullPath -NoTypeInformation
    }
}

# Group the .rar archives by the total number of .bin files and display the counts if specified
if ($ShowCounts) {
    $groupedCounts = $data | Group-Object -Property 'Number of BIN Files' | Sort-Object Name
    $formattedCounts = $groupedCounts | ForEach-Object {
        [PSCustomObject]@{
            'Number of BIN Files' = $_.Name
            'Number of RAR Files' = $_.Count
        }
    }
    $formattedCounts | Format-Table -AutoSize
}

# Extract .rar files based on specified options
foreach ($rarFile in $rarFiles) {
    $binFileCount = ($data | Where-Object { $_.'Archive' -eq $rarFile.Name }).'Number of BIN Files'

    # Determine whether to extract the file based on the specified options
    $shouldExtract = $false
    if ($ExtractAll) {
        $shouldExtract = $true
    } elseif ($ExtractWithBinCount -eq $binFileCount) {
        $shouldExtract = $true
    }

    # Perform the extraction if needed
    if ($shouldExtract) {
        $workingFolder = Join-Path -Path $WorkingDirectory -ChildPath "$($rarFile.BaseName)"
        $finalFolder = Join-Path -Path $FinalDestination -ChildPath "$($rarFile.BaseName)"
        if ($WhatIf) {
            Write-Output "What-If: Would extract $($rarFile.Name) to $workingFolder and move to $finalFolder"
        } else {
            Write-Output "Extracting $($rarFile.Name) to $workingFolder"
            New-Item -ItemType Directory -Path $workingFolder -Force
            & "$sevenZipCmd" x "$($rarFile.FullName)" -o"$workingFolder"

            Write-Output "Moving extracted files to $finalFolder"
            New-Item -ItemType Directory -Path $finalFolder -Force
            Move-Item -Path (Join-Path -Path $workingFolder -ChildPath '*') -Destination $finalFolder -Force
        }
    }
}

