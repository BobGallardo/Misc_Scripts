param (
    [string]$Path = (Get-Location).Path,
    [switch]$Delete
)

function Find-AndOptionallyDelete-LongNamedFiles {
    param (
        [string]$DirectoryPath,
        [switch]$Delete
    )

    $files = Get-ChildItem -Path $DirectoryPath -Recurse -File | Where-Object { $_.Name.Length -gt 100 }

    foreach ($file in $files) {
        if ($Delete) {
            $filePath = $file.FullName
            try {
                [System.IO.File]::Delete($filePath)
                # After deletion attempt, verify if the file still exists
                if (-not (Test-Path -Path $filePath)) {
                    Write-Host "Successfully deleted: $filePath"
                } else {
                    Write-Host "File still exists after deletion attempt: $filePath"
                }
            } catch {
                Write-Host "Error deleting file: $filePath. Exception: $_"
            }
        } else {
            Write-Host "Found: $($file.FullName)"
        }
    }
}

Find-AndOptionallyDelete-LongNamedFiles -DirectoryPath $Path -Delete:$Delete
