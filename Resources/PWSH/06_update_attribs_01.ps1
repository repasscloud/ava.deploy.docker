# Define the countries you want to post
$countries = @(
    "New Zealand"
    "United Kingdom"
    "United States"
)

# Base URL for your API
$uri = "https://dev.ava-api.uzhv.com/api/v1/attrib/countries"

foreach ($country in $countries) {
    # Build the payload
    $payload = @{
        id      = 0
        country = $country
    }

    # Convert to JSON
    $jsonBody = $payload | ConvertTo-Json

    # Send the POST
    try {
        Invoke-RestMethod `
            -Uri      $uri `
            -Method   Post `
            -Headers  @{ Accept = "text/plain" } `
            -ContentType "application/json" `
            -Body     $jsonBody `
            -AllowInsecureRedirect

        Write-Host "Posted $country"
    }
    catch {
        Write-Warning "Failed to post $country : $_"
    }
}
