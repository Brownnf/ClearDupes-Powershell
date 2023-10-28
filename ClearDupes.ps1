# Define the source and destination directories
$sourceDirectory = "C:\Path\to\Source"
$destinationDirectory = "C:\Path\to\Destination"
$ErrorActionPreference = "SilentlyContinue"

# Function to recursively compare files and collect matching files for deletion
function Compare-And-Collect-Files ($sourcePath, $destinationPath, [ref]$filesToDelete) {
    $sourceFiles = Get-ChildItem -Path $sourcePath -File -Recurse
    $destinationFiles = Get-ChildItem -Path $destinationPath -File -Recurse

    # Compare and collect matching files for deletion
    foreach ($file in $sourceFiles) {
        $destinationFile = $destinationFiles | Where-Object { $_.Name -eq $file.Name }

        if ($destinationFile -ne $null) {
            
            $filesToDelete.Value += $file.FullName
        }
    }

    # Recursively process sub-directories
    $sourceSubDirectories = Get-ChildItem -Path $sourcePath -Directory
    $destinationSubDirectories = Get-ChildItem -Path $destinationPath -Directory

    foreach ($subDir in $sourceSubDirectories) {
        $matchingDestinationDir = $destinationSubDirectories | Where-Object { $_.Name -eq $subDir.Name }

        if ($matchingDestinationDir -ne $null) {
            
            Compare-And-Collect-Files $subDir.FullName $matchingDestinationDir.FullName $filesToDelete
        }
    }
}

# Call the function to collect files to delete
$filesToDelete = @()
Write-Host "Collecting files to delete..."
Compare-And-Collect-Files $sourceDirectory $destinationDirectory ([ref]$filesToDelete)

Write-Host
# Prompt the user for confirmation before deleting the selected files
if ($filesToDelete.Count -gt 0) {
    Write-Host "A total of $($filesToDelete.Count) will be deleted:"
    $filesdeleted = ($filesToDelete.Count)

    $confirmation = Read-Host "Do you want to view these items? (Y/N)"
        if ($confirmation -eq "Y" -or $confirmation -eq "y") {
        foreach ($fileToDelete in $filesToDelete) {
            Write-Host "$fileToDelete"
        }}
    Write-Host
    $confirmation = Read-Host "Do you want to proceed with the deletion? (Y/N)"
    
    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
        foreach ($fileToDelete in $filesToDelete) {
            Remove-Item $fileToDelete -Force
            $substringAfterSlash = $fileToDelete.Split("\")[-1]
            Write-Host "File deleted: $substringAfterSlash"
        }
        Write-Host
        Write-Host "Deletion process completed. $($filesdeleted) files removed"
    } else {
        Write-Host "Deletion process canceled."
    }
} else {
    Write-Host "No files to delete."
}