# Define the taxIds you want to post
$taxids = @(
    "ABN",
    "ACN",
    "ARBN"
)

# Base URL for your API
$uri = "https://dev.ava-api.uzhv.com/api/v1/attrib/taxids"

foreach ($taxid in $taxids) {
    # Build the payload
    $payload = @{
        id      = 0
        taxIdType = $taxid
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

        Write-Host "Posted $taxid"
    }
    catch {
        Write-Warning "Failed to post $taxid : $_"
    }
}
