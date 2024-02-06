$ErrorActionPreference = "SilentlyContinue"
# Function to compute hash of a file
function Get-FileHash($filePath) {
    $hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
    $fileStream = [System.IO.File]::OpenRead($filePath)
    $hashBytes = $hashAlgorithm.ComputeHash($fileStream)
    $fileStream.Close()
    $hashString = [System.BitConverter]::ToString($hashBytes) -replace '-', ''
    return $hashString.ToLower()
}

# Source directory
$sourceDirectory = "C:\Path\To\Source"

# Target directory
$targetDirectory = "C:\Path\To\Target"

# Hashtable for source directory
$sourceHashtable = @{}

# Hashtable for target directory
$targetHashtable = @{}

# Function to recursively traverse directories and populate hash tables
function Populate-Hashtable($directory, [ref]$hashTable) {
    Get-ChildItem -Path $directory -File -Recurse | ForEach-Object {
        $hash = Get-FileHash $_.FullName
        $hashTable.Value[$_.FullName] = $hash
    }
}

# Populate hash table for source directory
Populate-Hashtable $sourceDirectory ([ref]$sourceHashtable)

# Populate hash table for target directory
Populate-Hashtable $targetDirectory ([ref]$targetHashtable)

# Function to compare hash tables and create a new hash table with duplicate files
function Compare-HashTables($sourceHashTable, $targetHashTable) {
    $duplicateHashTable = @{}
    foreach ($sourceFile in $sourceHashTable.Keys) {
        $sourceHash = $sourceHashTable[$sourceFile]
        if ($targetHashTable.ContainsValue($sourceHash)) {
            $duplicateHashTable[$sourceFile] = $sourceHash
        }
    }
    return $duplicateHashTable
}

# Compare hash tables and create a new hash table with duplicate files
$duplicateHashTable = Compare-HashTables $sourceHashtable $targetHashtable

# Create array from duplicate hash keys
$filesToDelete = $duplicateHashTable.Keys

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
