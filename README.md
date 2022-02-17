# Vanguard Control Script

Disables Vanguard by default. If it is enabled at startup, gives you 120 seconds top stop it from deactivating vanguard.
You can then enable Vanguard for a single boot (see below).

## Requirements

* Windows 10
* Powershell

## Installation

* Create a scheduled task (you can import [this XML file](VanguardControlAtStartup.xml), adapt settings and paths to your setup)
  * Trigger: run at user logon
  * Permissions: System/Admin
  * Actions: run `powershell C:\Path\To\vanguard-control.ps1 -Mode AfterStartup`
* Create a desktop shortcut to powershell and check "Run as Administrator". Edit the shortcut so that it has this command:
  `powershell C:\Path\To\vanguard-control.ps1`
  ![desktop shortcut](desktop-shortcut.png)

## Usage

If you want to play Valorant:
* save all open files!
* double-click your desktop icon
* your PC will reboot in 10 seconds.
* After the reboot, vanguard will be enabled.
* For the boots after that it'll be disabled again.

