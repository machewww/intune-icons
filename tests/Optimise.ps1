# AppVeyor Testing
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $projectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $projectRoot = ((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
}
Write-Host "Project root is: $projectRoot"

#region Functions
Function Invoke-Process {
    <# 
    .DESCRIPTION 
        Invoke-Process is a simple wrapper function that aims to "PowerShellyify" launching typical external processes. There 
        are lots of ways to invoke processes in PowerShell with Start-Process, Invoke-Expression, & and others but none account 
        well for the various streams and exit codes that an external process returns. Also, it's hard to write good tests 
        when launching external proceses. 
    
        This function ensures any errors are sent to the error stream, standard output is sent via the Output stream and any 
        time the process returns an exit code other than 0, treat it as an error. 
    #> 
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $FilePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $ArgumentList
    )

    # Set to avoid issues where the image has already been optimised
    $ErrorActionPreference = 'SilentlyContinue'

    try {
        $stdOutTempFile = "$env:TEMP\$((New-Guid).Guid)"
        $stdErrTempFile = "$env:TEMP\$((New-Guid).Guid)"

        $startProcessParams = @{
            FilePath               = $FilePath
            ArgumentList           = $ArgumentList
            RedirectStandardError  = $stdErrTempFile
            RedirectStandardOutput = $stdOutTempFile
            Wait                   = $true;
            PassThru               = $true;
            NoNewWindow            = $true;
        }
        if ($PSCmdlet.ShouldProcess("[$($ArgumentList)]", "[$($FilePath)]")) {
            $cmd = Start-Process @startProcessParams
            $cmdOutput = Get-Content -Path $stdOutTempFile -Raw
            $cmdError = Get-Content -Path $stdErrTempFile -Raw
            if ($cmd.ExitCode -ne 0) {
                if ($cmdError) {
                    # throw $cmdError.Trim()
                }
                if ($cmdOutput) {
                    # throw $cmdOutput.Trim()
                }
            }
            else {
                if ([string]::IsNullOrEmpty($cmdOutput) -eq $false) {
                    Write-Output -InputObject $cmdOutput
                }
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        Remove-Item -Path $stdOutTempFile, $stdErrTempFile -Force -ErrorAction Ignore
    }
}
#endregion

#region Optimise images
$pngout = "$projectRoot\utils\pngout.exe"
# $pngcrush = "$projectRoot\utils\pngcrush.exe"
$icons = "$projectRoot\icons"
$imageHashes = "$projectRoot\tests\ImageHashes.json"

# Read in the existing hashes file, otherwise determine the hashes of PNG files
If (Test-Path -Path $imageHashes) {
    $pngHashes = Get-Content -Path $imageHashes -Verbose | ConvertFrom-Json
}
Else {
    $pngImages = Get-ChildItem -Path $icons -Recurse -Include *.png
    $pngHashes = @{}
    ForEach ($png in $pngImages) {
        $hash = Get-FileHash -Path $png.FullName
        $pngHashes.Add((Split-Path -Path $hash.Path -Leaf), $hash.Hash)
    }
}

# Get all images in the icons folder
$images = Get-ChildItem -Path $icons -Recurse -Include *.*

# Optimse each file if the hash does not match
Push-Location $icons
$cleanUp = @()
ForEach ($image in $images) {
    $hash = Get-FileHash -Path $image.FullName -Verbose
    If ($pngHashes.($image.Name) -ne $hash.Hash) {
        $result = Invoke-Process -FilePath $pngout -ArgumentList "$($image.FullName) /y /force" -Verbose
        If ($result -like "*Out:*") {
            $result
            If ([IO.Path]::GetExtension($image.Name) -notmatch ".png" ) {
                $cleanUp += $image.FullName
            }
        }
    }
    Else {
        Write-Host "$($image.Name): Hash matches. Skip optimisation."
    }
}

# Remove files that aren't .png that have been optimised
ForEach ($file in $cleanUp) { Remove-Item -Path $file -Force -Verbose }
Pop-Location

# Read the hashes from all PNG files and output to file for next run
$pngImages = Get-ChildItem -Path $icons -Recurse -Include *.png
$pngHashes = @{}
ForEach ($png in $pngImages) {
    $hash = Get-FileHash -Path $png.FullName
    $pngHashes.Add((Split-Path -Path $hash.Path -Leaf), $hash.Hash)
}
$pngHashes | Convertto-Json | Out-File -FilePath $imageHashes -Force -Verbose
#endregion
