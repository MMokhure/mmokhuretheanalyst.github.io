$ErrorActionPreference = "Stop"

$dataFile = "data/owid-covid-data.csv"
$outputFile = "data/covid-data.json"
$regions = @("World", "Africa", "Botswana")

if (-not (Test-Path $dataFile)) {
    throw "Dataset not found at $dataFile"
}

function Convert-ToNumber {
    param($value)
    $parsed = 0
    if ([double]::TryParse($value, [ref]$parsed)) {
        return $parsed
    }
    return 0
}

$csv = Import-Csv -Path $dataFile
$records = @()

foreach ($region in $regions) {
    $regionRows = $csv | Where-Object { $_.location -eq $region }
    $groups = $regionRows | Group-Object {
        (Get-Date $_.date).ToString("yyyy-MM-01")
    }

    foreach ($group in $groups) {
        $sumCases = 0
        $sumDeaths = 0
        $sumVaccinations = 0

        foreach ($row in $group.Group) {
            $sumCases += Convert-ToNumber $row.new_cases
            $sumDeaths += Convert-ToNumber $row.new_deaths
            $sumVaccinations += Convert-ToNumber $row.new_vaccinations
        }

        $records += [pscustomobject]@{
            region       = $region
            date         = $group.Name
            new_cases    = [math]::Round($sumCases)
            new_deaths   = [math]::Round($sumDeaths)
            vaccinations = [math]::Round($sumVaccinations)
        }
    }
}

$sorted = $records | Sort-Object region, date
$json = $sorted | ConvertTo-Json -Depth 3
Set-Content -Path $outputFile -Value $json -Encoding UTF8
Write-Output "Wrote $($sorted.Count) rows to $outputFile"

