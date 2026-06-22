<#
.SYNOPSIS
Finds large files and creates CSV and HTML storage reports.
#>
[CmdletBinding()]
param(
    [string]$ScanPath="$env:SystemDrive\Users",
    [ValidateRange(1,1048576)][int]$MinimumSizeMB=500,
    [ValidateRange(10,5000)][int]$Top=200,
    [string]$OutputRoot="$env:PUBLIC\Documents\LargeFileReports"
)

Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$runPath=Join-Path $OutputRoot ("LargeFiles_{0}_{1}" -f $env:COMPUTERNAME,(Get-Date -Format 'yyyyMMdd_HHmmss'))
$errors=New-Object System.Collections.Generic.List[object]

try{
    if(-not(Test-Path -LiteralPath $ScanPath)){throw "Scan path not found: $ScanPath"}
    New-Item $runPath -ItemType Directory -Force|Out-Null
    $minimumBytes=$MinimumSizeMB*1MB

    $files=Get-ChildItem -LiteralPath $ScanPath -File -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable +scanErrors|
        Where-Object{$_.Length -ge $minimumBytes}|
        Sort-Object Length -Descending|
        Select-Object -First $Top FullName,DirectoryName,Name,Extension,
            @{n='SizeMB';e={[math]::Round($_.Length/1MB,2)}},
            @{n='SizeGB';e={[math]::Round($_.Length/1GB,3)}},CreationTime,LastWriteTime

    $files|Export-Csv (Join-Path $runPath 'LargeFiles.csv') -NoTypeInformation -Encoding UTF8

    $folders=$files|Group-Object DirectoryName|ForEach-Object{
        [pscustomobject]@{
            Folder=$_.Name
            MatchingFiles=$_.Count
            MatchingSizeGB=[math]::Round((($_.Group|Measure-Object SizeGB -Sum).Sum),3)
        }
    }|Sort-Object MatchingSizeGB -Descending
    $folders|Export-Csv (Join-Path $runPath 'FolderSummary.csv') -NoTypeInformation -Encoding UTF8

    $style='<style>body{font-family:Segoe UI;margin:30px}table{border-collapse:collapse;width:100%}th,td{border:1px solid #ccc;padding:6px}th{background:#eee}</style>'
    $files|ConvertTo-Html -Title 'Large File Report' -Head $style -PreContent "<h1>Large File Report</h1><p>Path: $ScanPath | Minimum: $MinimumSizeMB MB</p>"|
        Out-File (Join-Path $runPath 'LargeFiles.html') -Encoding UTF8

    $scanErrors|ForEach-Object{[pscustomobject]@{Message=$_.Exception.Message;Target=$_.TargetObject}}|
        Export-Csv (Join-Path $runPath 'AccessErrors.csv') -NoTypeInformation

    Write-Host "[OK] Report created: $runPath" -ForegroundColor Green
    exit 0
}catch{Write-Error $_.Exception.Message;exit 1}
