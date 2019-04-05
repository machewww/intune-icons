<#
    .SYNOPSIS
        AppVeyor tests setup script.
#>
# Line break for readability in AppVeyor console
Write-Host -Object ''
Write-Host "PowerShell Version:" $PSVersionTable.PSVersion.tostring()

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name Pester -Force
Install-Module -Name posh-git -Force
