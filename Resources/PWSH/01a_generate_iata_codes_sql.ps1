# Notice to user
Write-Host "Generate IATA Codes (Step 1 of 2)"
Write-Host ""
Write-Host "This will take a few minutes..."

# Define file paths
$parentFolder = Split-Path $PSScriptRoot -Parent
$csvFile = "airports.csv"
$csvPath = Join-Path -Path $parentFolder -ChildPath "CSV/${csvFile}"
$sqlFile = "import_airports.sql"
$outputFile = Join-Path -Path $parentFolder -ChildPath "SQL/${sqlFile}"

# Helper function: returns a SQL-safe string value or NULL if empty.
function ConvertTo-QuotedString {
    param($value)
    if ([string]::IsNullOrWhiteSpace($value)) {
        return "NULL"
    }
    # Escape single quotes by doubling them.
    $escaped = $value -replace "'", "''"
    return "'$escaped'"
}

# Import CSV (header row should match the JSON keys)
$csvData = Import-Csv -Path $csvPath

# Create an array to hold all the INSERT statements.
$output = @()

foreach ($row in $csvData) {
    # Only process rows where iata_code is not null or empty.
    if (-not [string]::IsNullOrWhiteSpace($row.iata_code)) {

        # Map CSV columns to the SQL columns.
        # Numeric fields (Id, Latitude, Longitude, ElevationFt) are not quoted.
        $id = $row.id
        $identity = ConvertTo-QuotedString $row.ident
        $type = ConvertTo-QuotedString $row.type
        $name = ConvertTo-QuotedString $row.name
        $latitude = $row.latitude_deg
        $longitude = $row.longitude_deg
        # For elevation_ft, if empty then use NULL
        $elevationFt = if ([string]::IsNullOrWhiteSpace($row.elevation_ft)) { "NULL" } else { $row.elevation_ft }
        $continent = ConvertTo-QuotedString $row.continent
        $isoCountry = ConvertTo-QuotedString $row.iso_country
        $isoRegion = ConvertTo-QuotedString $row.iso_region
        $municipality = ConvertTo-QuotedString $row.municipality
        $scheduledService = ConvertTo-QuotedString $row.scheduled_service
        $icaoCode = ConvertTo-QuotedString $row.icao_code
        $iataCode = ConvertTo-QuotedString $row.iata_code
        $gpsCode = ConvertTo-QuotedString $row.gps_code
        $localCode = ConvertTo-QuotedString $row.local_code
        $homeLink = ConvertTo-QuotedString $row.home_link
        $wikipediaLink = ConvertTo-QuotedString $row.wikipedia_link
        $keywords = ConvertTo-QuotedString $row.keywords
        # $region = if ($row.continent -eq "NA") { ConvertTo-QuotedString "NA" } 
        #   elseif ($row.continent -eq "EU" -or $row.continent -eq "AF") { ConvertTo-QuotedString "EMEA" } 
        #   elseif ($row.continent -eq "OC" -or $row.continent -eq "AS") { ConvertTo-QuotedString "APAC" } 
        #   elseif ($row.continent -eq "SA") { ConvertTo-QuotedString "LATAM" } 
        #   else { ConvertTo-QuotedString "UNKNOWN" }

        $isoC = $row.iso_country
        try {
            $response = Invoke-RestMethod -Uri "http://localhost:5165/api/Country/isoCode/$isoC" -Method GET -Headers @{ accept = "*/*" }
            $region = ConvertTo-QuotedString $response.continentId
        } catch {
            Write-Warning "API lookup failed for ISO code $isoC. Defaulting region to UNKNOWN."
            $region = ConvertTo-QuotedString "UNKNOWN"
        }

        # Build the INSERT statement.
        $line = "INSERT INTO public.""IATAAirportCodes"" (" +
                """Id"", ""Identity"", ""Type"", ""Name"", ""Latitude"", ""Longitude"", ""ElevationFt"", " +
                """Continent"", ""IsoCountry"", ""IsoRegion"", ""Municipality"", ""ScheduledService"", " +
                """ICAOCode"", ""IATACode"", ""GPSCode"", ""LocalCode"", ""HomeLink"", ""WikipediaLink"", ""Keywords"", ""_Region"") " +
                "VALUES ($id, $identity, $type, $name, $latitude, $longitude, $elevationFt, $continent, " +
                "$isoCountry, $isoRegion, $municipality, $scheduledService, $icaoCode, $iataCode, " +
                "$gpsCode, $localCode, $homeLink, $wikipediaLink, $keywords, $region);"

        $output += $line
    }
}

# Write all the INSERT statements to the output SQL file.
$output | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "SQL file generated at $outputFile"

<# Clean up SQL table #>
# DELETE FROM public."AirportIATACodes"
# WHERE "IATACode" IS NULL OR "IATACode" = '';


# -- Create the extension if not already available
# CREATE EXTENSION IF NOT EXISTS pg_cron;

# -- Schedule the job (runs at midnight every day)
# SELECT cron.schedule('cleanup_airport_iata_codes', '0 0 * * *', $$
#     DELETE FROM public."AirportIATACodes"
#     WHERE "IATACode" IS NULL OR TRIM("IATACode") = '';
# $$);

# How to insert them with SQL directly from terminal really fast
# export PGPASSWORD="devpassword"
# psql -h 170.64.135.239 -p 5432 -d ava_db -U postgres -f /Users/danijeljw/Developer/dotnet-dev/Ava.API/_help/import_airports.sql