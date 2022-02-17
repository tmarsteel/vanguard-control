#Requires -RunAsAdministrator
Param(
    [parameter(Position=0)]
    [String]
    [ValidateNotNull()]
    [ValidateSet("AfterStartup", "RebootWithVanguard")]
    $Mode = "RebootWithVanguard",

    [parameter(ParameterSetName="Allowfile")]
    [String]
    [ValidateNotNullOrEmpty()]
    $AllowFile = "ALLOW VANGUARD"
)

$AbsAllowFile = "$($PSScriptRoot)\$AllowFile"

if ($Mode -eq "AfterStartup") {
    if (Test-Path -Path $AbsAllowFile -PathType Leaf) {
        Remove-Item -Path $AbsAllowFile
        Exit
    }

    $vgkService = Get-Service -Name vgk

    if ($vgkService.StartType -ne "Disabled") {
        Write-Host "Stopping Vanguard in 120 seconds. Interrupt with Ctrl+C."
        Start-Sleep -Seconds 120
        Set-Service -Name vgk -StartupType Disabled
        if ($vgkService.Status -ne "Stopped") {
            $vgkService.Stop()
        }
        $vgkService.WaitForStatus("Stopped", (New-TimeSpan -Seconds 10))
    } else {
        Write-Host "Vanguard is disabled. Run 'sc config vgk start= system' to enable it."
    }

    taskkill /IM vgtray.exe
}

if ($Mode -eq "RebootWithVanguard") {
    sc.exe config vgk "start=" "system" # ps' Set-Service can't do this
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to activate the vanguard service vgk."
        Write-Host "Press enter to close the window"
        Read-Host
        exit 1
    }
    echo $null >> $AbsAllowFile
    Write-Host "Rebooting in 5 Seconds. Interrupt with Ctrl+C."
    Start-Sleep -Seconds 5
    shutdown /r /t 5 /c "Rebooting with Vanguard enabled." /d u:4:1
}
