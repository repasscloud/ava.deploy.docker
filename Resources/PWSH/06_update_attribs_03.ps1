# Define the dial code payloads
$dialcodes = @(
    @{
        id          = 0
        countryCode = "61"
        countryName = "Australia"
    },
    @{
        id          = 0
        countryCode = "64"
        countryName = "New Zealand"
    },
    @{
        id          = 0
        countryCode = "1"
        countryName = "United States"
    },
    @{
        id          = 0
        countryCode = "44"
        countryName = "United Kingdom"
    }
)

# Base URL for your API
$uri = "https://dev.ava-api.uzhv.com/api/v1/attrib/dialcodes"

foreach ($payload in $dialcodes) {
    # Convert to JSON
    $jsonBody = $payload | ConvertTo-Json

    # Send the POST
    try {
        Invoke-RestMethod `
            -Uri              $uri `
            -Method           Post `
            -Headers          @{ Accept = "text/plain" } `
            -ContentType      "application/json" `
            -Body             $jsonBody `
            -AllowInsecureRedirect

        Write-Host "Posted dialcode: $($payload.countryCode) - $($payload.countryName)"
    }
    catch {
        Write-Warning "Failed to post $($payload.countryCode): $_"
    }
}
