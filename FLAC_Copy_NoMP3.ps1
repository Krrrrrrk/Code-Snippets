$source      = "F:\music"     
$destination = "H:\music"     
$dryRun      = $false  # $true for a dry run, $false to actually copy

# logging
$logDir             = $destination
$actionLogPath      = Join-Path $logDir "ScriptAction.log"
$skippedCsvPath     = Join-Path $logDir "SkippedFolders.csv"
$copiedCsvPath      = Join-Path $logDir "CopiedFolders.csv"

$skippedFolders = @()

# Prepare logging containers
$skippedFolders = @()
$copiedFolders  = @()

# Ensure logging directory exists
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }

# Clean up old logs
foreach ($path in @($actionLogPath, $skippedCsvPath, $copiedCsvPath)) {
    if (Test-Path $path) { Remove-Item $path -Force }
}

# Get top-level album folders (non-recursive)
$albumFolders = Get-ChildItem -Path $source -Directory

foreach ($folder in $albumFolders) {
    # Look only in the top-level of the folder
    $topLevelFiles = [System.IO.Directory]::EnumerateFiles($folder.FullName, "*", [System.IO.SearchOption]::TopDirectoryOnly)
    $hasFlac = $topLevelFiles | Where-Object { $_.ToLower().EndsWith(".flac") }

    $targetPath = Join-Path -Path $destination -ChildPath $folder.Name

    if ($hasFlac) {
        $logMsg = "[COPY] $folder.FullName --> $targetPath"

        if ($dryRun) {
            $logMsg = "[DRY RUN] " + $logMsg
            Write-Host $logMsg
            Add-Content -Path $actionLogPath -Value $logMsg
        } else {
            Write-Host $logMsg
            Add-Content -Path $actionLogPath -Value $logMsg

            # Robocopy the folder (log output to console and file)
            $robocopyArgs = @(
                "`"$folder.FullName`"", "`"$targetPath`"",
                "/E", "/COPYALL", "/R:1", "/W:1", "/NFL", "/NDL", "/NJH", "/NJS"
            )

            $tempLog = [System.IO.Path]::GetTempFileName()

            Start-Process -FilePath "robocopy.exe" -ArgumentList $robocopyArgs -NoNewWindow -Wait -RedirectStandardOutput $tempLog

            Get-Content $tempLog | ForEach-Object {
                Write-Host $_
                Add-Content -Path $actionLogPath -Value $_
            }

            Remove-Item $tempLog -Force
        }

        # Track copied folder name
        $copiedFolders += [PSCustomObject]@{ FolderName = $folder.Name }

    } else {
        $logMsg = "[SKIP] $folder.FullName - No .flac files at album folder level"
        Write-Host $logMsg
        Add-Content -Path $actionLogPath -Value $logMsg

        # Track skipped folder name
        $skippedFolders += [PSCustomObject]@{ FolderName = $folder.Name }
    }
}

# Export CSV logs
$copiedFolders  | Export-Csv -Path $copiedCsvPath -NoTypeInformation -Encoding UTF8
$skippedFolders | Export-Csv -Path $skippedCsvPath -NoTypeInformation -Encoding UTF8

# Done
Write-Host "Top-level check complete."
Write-Host "Action log:     $actionLogPath"
Write-Host "Copied folders: $copiedCsvPath"
Write-Host "Skipped folders:$skippedCsvPath"
