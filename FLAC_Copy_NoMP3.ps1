$source      = "F:\music"     
$destination = "H:\music"     
$dryRun      = $false # set to true if you wanna see what it'll do before it does it, it'll still write the log and csv to the destination folder.                          

# logging
$logDir         = $destination
$actionLogPath  = Join-Path $logDir "ScriptAction.log"
$skippedCsvPath = Join-Path $logDir "SkippedFolders.csv"

$skippedFolders = @()
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
if (Test-Path $actionLogPath) { Remove-Item $actionLogPath -Force }

# top-level album folders --- !non-recursive!
$albumFolders = Get-ChildItem -Path $source -Directory

foreach ($folder in $albumFolders) {
    $topLevelFiles = [System.IO.Directory]::EnumerateFiles($folder.FullName, "*", [System.IO.SearchOption]::TopDirectoryOnly)
    $hasFlac = $topLevelFiles | Where-Object { $_.ToLower().EndsWith(".flac") }

    $targetPath = Join-Path -Path $destination -ChildPath $folder.Name

    if ($hasFlac) {
        $logMsg = "[COPY] $folder.FullName --> $targetPath"
        if ($dryRun) {
            $logMsg = "[DRY RUN] " + $logMsg
        } else {
            if (!(Test-Path $targetPath)) {
                New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
            }
            Copy-Item -Path $folder.FullName -Destination $targetPath -Recurse -Force
        }
    } else {
        $logMsg = "[SKIP] $folder.FullName - No .flac files at album folder level"
        $skippedFolders += [PSCustomObject]@{
            FolderName = $folder.Name
            FullPath   = $folder.FullName
            Reason     = "No .flac files in top-level album folder"
        }
    }

    Add-Content -Path $actionLogPath -Value $logMsg
}


$skippedFolders | Export-Csv -Path $skippedCsvPath -NoTypeInformation -Encoding UTF8

Write-Host "Top-level check complete."
Write-Host "Action log:    $actionLogPath"
Write-Host "Skipped log:   $skippedCsvPath"
