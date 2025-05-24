# Notice to user
Write-Host "Generate IATA Codes (Step 2 of 2)"

# Path to your SQL file with individual INSERT statements
$parentFolder = Split-Path $PSScriptRoot -Parent
$sqlFile = "import_airports.sql"
$filePath = Join-Path -Path $parentFolder -ChildPath "SQL/${sqlFile}"
$outputSqlFile = "import_airports_merged.sql"
$outputPath = Join-Path -Path $parentFolder -ChildPath "SQL/${outputSqlFile}"

# Read all lines from the file
$lines = Get-Content -Path $filePath

# Extract the header from the first line (everything up to and including "VALUES ")
# This assumes all lines use the same INSERT structure.
$headerPattern = '^(INSERT INTO public\."IATAAirportCodes"\s*\([^)]+\)\s+VALUES\s+)'
if ($lines[0] -match $headerPattern) {
    $header = $Matches[1]
} else {
    Write-Error "Could not extract the INSERT header from the first line."
    exit
}

# Extract the values part from each line.
# We assume each line ends with ');' and the values are enclosed in parentheses.
$values = foreach ($line in $lines) {
    if ($line -match 'VALUES\s*\((.*)\);') {
        $Matches[1]
    }
}

# Join all value sets into one big VALUES clause.
# Each set is wrapped in parentheses and separated by commas.
$combinedValues = "(" + ($values -join "),`n(") + ")"

# Build the combined INSERT statement.
$combinedInsert = $header + $combinedValues + ";"

# Optionally, output to a new file.
$combinedInsert | Out-File -FilePath $outputPath

Write-Host "Combined INSERT statement created at $outputPath"
