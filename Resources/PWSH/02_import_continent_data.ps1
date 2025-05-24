# Notice to user
Write-Host "Import Continent Data (Step 1 of 3)"

$apiUrl = "http://localhost:5165/api/Continent"

$parentFolder = Split-Path $PSScriptRoot -Parent
$csvFile = "region_continent_data.csv"
$csvPath = Join-Path -Path $parentFolder -ChildPath "CSV/${csvFile}"

Import-Csv -Path $csvPath | ForEach-Object {
    $payload = @{
        name = $_.continent
        continentCode = $_.continentIso
        regionId = $_.regionId
    }

    # Convert the payload to JSON
    $jsonPayload = $payload | ConvertTo-Json -Depth 3

    try {
        # Post the JSON to the API endpoint
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $jsonPayload -ContentType "application/json"
        Write-Host "$response"
    }
    catch {
        Write-Host "Error posting record with id $($response.id): $_"
    }
}
