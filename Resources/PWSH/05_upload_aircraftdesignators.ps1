# Define the CSV URL and target API endpoint
$csvUrl = "https://raw.githubusercontent.com/repasscloud/AircraftTypeDesignatorScraper/refs/heads/main/aircraft_type_designators.csv"
$apiEndpoint = "http://localhost:5165/api/v1/wikipedia/aircrafttypedesignators"

# Download CSV content
Write-Host "📥 Downloading CSV..."
$csvContent = Invoke-WebRequest -Uri $csvUrl -UseBasicParsing
if (-not $csvContent.Content) {
    Write-Error "Failed to download CSV."
    exit 1
}

# Convert CSV string to objects
Write-Host "🔍 Parsing CSV..."
$csv = $csvContent.Content | ConvertFrom-Csv

# Loop through each row and send as POST (throttled)
foreach ($row in $csv) {
    $payload = @{
        id = 0
        model = $row.'Model'
    }

    # Optional fields: include only if not blank
    if ($row.'ICAO Code' -and $row.'ICAO Code'.Trim() -ne "") {
        $payload["icao_code"] = $row.'ICAO Code'
    }
    if ($row.'IATA Type Code' -and $row.'IATA Type Code'.Trim() -ne "") {
        $payload["iata_type_code"] = $row.'IATA Type Code'
    }
    if ($row.'Wikipedia Link' -and $row.'Wikipedia Link'.Trim() -ne "") {
        $payload["wikipedia_link"] = $row.'Wikipedia Link'
    }

    # Convert to JSON
    $json = $payload | ConvertTo-Json -Depth 2 -Compress

    # Send the POST request
    try {
        $response = Invoke-RestMethod -Uri $apiEndpoint -Method Post -Body $json -ContentType "application/json"
        if ($null -ne $response) {
            Write-Host "✅ Posted: $($payload.model) — API Response: $response"
        }
    }
    catch {
        Write-Warning "❌ Failed to post: $($payload.model) — $_"
    }

    # Throttle to avoid hammering the API
    Start-Sleep -Milliseconds 100
}