$logFile = "[filepath]\DLL_Replace.log"
$ou = "[Target OU]"

$computers = Get-ADComputer -Filter * -SearchBase $ou | Select-Object -ExpandProperty Name

foreach ($computer in $computers) {
Write-Host "Processing computer: $computer"
$success = $true

# Unregister
Write-Host "Unregistering DLL on $computer..."
psexec "\\$computer" regsvr32.exe /u c:\windows\sysWOW64\UEClientObj.dll /s 
if ($LASTEXITCODE -ne 0) {
    $success = $false
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Failed to unregister DLL on $computer." | Out-File $logFile -Append
}

# Rename
Write-Host "Renaming DLL on $computer..."
psexec "\\$computer" -d cmd /c "ren c:\windows\SYSWOW64\UEClientObj.dll UEClientObj.old" 
if (-not (Test-Path "\\$computer\c$\windows\SYSWOW64\UEClientObj.old")) {
    $success = $false
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Failed to rename DLL on $computer." | Out-File $logFile -Append
}

# Copy DLL 
Write-Host "Copying DLL to $computer..."
Copy-Item -Path "[File path to NEW .dll]\UEClientObj.dll" -Destination "\\$computer\c$\windows\SYSWOW64\" -Force
if (-not (Test-Path "\\$computer\c$\windows\SYSWOW64\UEClientObj.dll")) {
    $success = $false
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Failed to copy DLL to $computer." | Out-File $logFile -Append
}

# I couldn't get this to work
# Record failure in CSV file
#if (!$success) {
#   $result = [pscustomobject]@{
#        ComputerName = $computer
#        Success = $false
#    }
#    $result | Export-Csv -Path "[filepath]]log.csv" -Append
#}

}
