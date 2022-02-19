#Requires -RunAsAdministrator
Param(
    [parameter(Position=0)]
    [String]
    [ValidateNotNull()]
    [ValidateSet("AfterStartup", "RebootWithVanguard")]
    $Mode = "RebootWithVanguard",

    [String]
    [ValidateNotNullOrEmpty()]
    $AllowFile = "ALLOW VANGUARD",

    [int]
    $StopDelay = 120,

    [int]
    $VgTrayStartTimeout = 45
)

$AbsAllowFile = "$($PSScriptRoot)\$AllowFile"

if ($Mode -eq "AfterStartup") {
    if (Test-Path -Path $AbsAllowFile -PathType Leaf) {
        Remove-Item -Path $AbsAllowFile
        Exit
    }

    $stopWatch = [system.diagnostics.stopwatch]::StartNew()

    $vgkService = Get-Service -Name "vgk"
    $vgcService = Get-Service -Name "vgc"

    if (($vgkService.StartType -ne "Disabled") -or ($vgcService.StartType -ne "Disabled")) {
        if ($StopDelay -gt 0) {
            Write-Host "Stopping Vanguard in $StopDelay seconds. Interrupt with Ctrl+C."
            Start-Sleep -Seconds $StopDelay
        }

        Set-Service -Name vgk -StartupType Disabled
        Set-Service -Name vgc -StartupType Disabled

        if ($vgkService.Status -ne "Stopped") {
            $vgkService.Stop()
        }
        if ($vgcService.Status -ne "Stopped") {
            $vgcService.Stop()
        }


        $vgkService.WaitForStatus("Stopped", (New-TimeSpan -Seconds 10))
        $vgcService.WaitForStatus("Stopped", (New-TimeSpan -Seconds 10))
    }

    $SecondsRemaining = [Math]::Ceiling($VgTrayStartTimeout - ($stopWatch.ElapsedMilliseconds / 1000))
    Write-Host "Waiting up to $SecondsRemaining seconds for vgtray to start, so it can be stopped."
    while ($stopWatch.ElapsedMilliseconds -le $VgTrayStartTimeout * 1000) {
        try {
            $vgtrayProcess = Get-Process -Name "vgtray" -ErrorAction Stop
        }
        catch [Microsoft.PowerShell.Commands.ProcessCommandException] {
            Start-Sleep -Seconds 5
            continue
        }

        Write-Host "vgtray has started, stopping..."
        Stop-Process -InputObject $vgtrayProcess
        Wait-Process -InputObject $vgtrayProcess
        Write-Host "vgtray stopped."
        break
    }
}

if ($Mode -eq "RebootWithVanguard") {
    sc.exe config vgk "start=" system # ps' Set-Service can't do this
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to activate the vanguard service vgk"
        Write-Host "Press enter to close the window"
        Read-Host
        exit 1
    }

   sc.exe config vgc "start=" auto # system is not valid for vgc
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to activate the vanguard service vgc"
        Write-Host "Press enter to close the window"
        Read-Host
        exit 1
    }

    echo $null >> $AbsAllowFile
    Write-Host "Rebooting in 5 Seconds. Interrupt with Ctrl+C."
    Start-Sleep -Seconds 5
    shutdown /r /t 5 /c "Rebooting with Vanguard enabled." /d u:4:1
}
