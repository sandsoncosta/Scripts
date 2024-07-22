param (
    [string]$ipAddress
)

function Get-WhoisInfo {
    param (
        [string]$ipAddress
    )

    $url = "https://ipinfo.io/$ipAddress/json"
    
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    $output = $response | ConvertTo-Json -Depth 10
    
    Write-Output $output
}

if ($ipAddress) {
    Get-WhoisInfo -ipAddress $ipAddress
} else {
    Write-Output "Uso: whois <IP>"
}