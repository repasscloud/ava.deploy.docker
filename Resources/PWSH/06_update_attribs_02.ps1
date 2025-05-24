# Define the currency payloads
$currencies = @(
    @{
        id      = 0
        iso4217 = "AUD"
        symbol  = "$"
        name    = "Australian Dollar"
    },
    @{
        id      = 0
        iso4217 = "USD"
        symbol  = "$"
        name    = "US Dollar"
    },
    @{
        id      = 0
        iso4217 = "GBP"
        symbol  = "£"
        name    = "British Pound"
    },
    @{
        id      = 0
        iso4217 = "EUR"
        symbol  = "€"
        name    = "Euro"
    },
    @{
        id      = 0
        iso4217 = "NZD"
        symbol  = "$"
        name    = "New Zealand Dollar"
    }
)

# Base URL for your API
$uri = "https://dev.ava-api.uzhv.com/api/v1/attrib/currencies"

foreach ($payload in $currencies) {
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

        Write-Host "Posted currency: $($payload.iso4217) - $($payload.name)"
    }
    catch {
        Write-Warning "Failed to post $($payload.iso4217): $_"
    }
}
