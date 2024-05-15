netstat -nao | Select-String —Pattern "ESTABLISHED" | ForEach-Object {
	$parts = ($_ -split '\s+') -ne ''
	$protocol = $parts[0]
	$localAddress = $parts[1]
	$remoteAddress = $parts[2]
	$processId = $parts[-1]
	
	$processName = (Get-process -Id $processId).ProcessName
	
	$ipOnly = $remoteAddress -replace ':\d+', ''
	
	$whoisInfo = try { Invoke-RestMethod -uri ("https://ipinfo.io/$ipOnly/json") -ErrorAction Stop } catch {$null}
	
	if ($whoisInfo) {
		$org = $whoisInfo.org
		$country = $whoisInfo.country
	} else {
		$org = "N/A"
		$country = "N/A"
		} 
		
		"{0, -8} {1, -25} {2,-25} {3, -10} {4, -25} {5, -10}, {6, -2}" -f $protocol,	$loca1Address,
		$remoteAddress,
		$processld,
		$processName,
		$org,
		$country
} | Out-Host