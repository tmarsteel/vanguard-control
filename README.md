# Vanguard Control Script

## Requirements

* Windows 10
* Powershell

## Installation

* Put somewhere on your PATH.
* Create a scheduled task (you can import the XML file, adapt settings and paths to your setup)
  * Trigger: run at user logon
  * Permissions: System/Admin
  * Actions: run `powershell C:\Path\To\vanguard-control.ps1 -Mode AfterStartup`

## Usage

Disables Vanguard by default. If it is enabled at startup, gives you 120 seconds top stop it from deactivating vanguard.
To enable it (for one boot):
* open a powershell prompt with administrator privileges (Ctrl+Shift+Enter in the Start Menu)
* run `vanguard-control`
* your machine will reboot in 10 seconds. After the next boot, vanguard will be enabled. For the boots after that it'll be disabled again.