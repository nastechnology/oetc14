<#
.SYNOPSIS
    Installs Puppet on this machine.

.DESCRIPTION
    Downloads and installs the PuppetLabs Puppet MSI package.

    This script requires administrative privileges.

    You can run this script from an old-style cmd.exe prompt using the
    following:

      powershell.exe -ExecutionPolicy Unrestricted -NoExit -File "windows.ps1"

.PARAMETER MsiUrl
    This is the URL to the Puppet MSI file you want to install. This defaults
    to a version from PuppetLabs.
#>
Param([string]$MsiUrl = "http://puppetlabs.com/downloads/windows/puppet-3.4.2.msi")

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host -ForegroundColor Red "You must run this script as an administrator."
    Exit 1
}

# Download Puppet
Write-Host "Downloading Puppet..."
$downloadPath = "C:\vagrant\puppet-3.4.2.msi"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($MsiUrl, $downloadPath)

# Install it
Write-Host "Installing Puppet..."
$install_args = @("/qn", "/i", $downloadPath, "PUPPET_MASTER_SERVER=puppet.nacswildcats.dev", "PUPPET_AGENT_CERTNAME=xp.nas.dev")
$process = Start-Process -FilePath msiexec.exe -ArgumentList $install_args -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installer failed."
    Exit 1
}

# Stop the service that it autostarts
Write-Host "Stopping Puppet service that is running by default..."
Start-Sleep -s 5
Stop-Service -Name puppet

Write-Host "Puppet successfully installed."

Break
