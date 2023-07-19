
$ouDN = "[OU TARGET]"
$computers = Get-ADComputer -Filter * -SearchBase $ouDN | Select-Object -ExpandProperty Name

# Loop
foreach ($computer in $computers) {
    Write-Host "Running code on $computer"

    # copy
    Copy-Item -Path "[path to install .msi/exe]" -Destination "\\$computer\C$" -Force

    # install
    Invoke-Expression -Command "psexec \\$computer -s -i msiexec /i 'c:\[install.msi/.exe]' ALLUSERS=1 /qn /norestart"
}

