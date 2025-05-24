# Notice to user
Write-Host "Import Continent Data (Step 2 of 3)"

$apiUrl = "http://localhost:5165/api/Country"

$parentFolder = Split-Path $PSScriptRoot -Parent
$csvFile = "region_continent_country_data.csv"
$filePath = Join-Path -Path $parentFolder -ChildPath "CSV/${csvFile}"

Import-Csv -Path $filePath | ForEach-Object {
    $payload = @{
        name = $_.country
        countryCode = $_.countryIso
        countryFlag = $_.flag
        continentId = $_.continentId
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
