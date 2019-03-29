# AppVeyor Testing
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $projectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $projectRoot = ((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
}

#region Tests
$icons = "$projectRoot\icons"
$images = Get-ChildItem -Path $icons -Recurse -Include *.*

Describe "All images should be in PNG format" {
    It "Should only be a .PNG file" {
        ForEach ($image in $images) {
            Write-Host "Testing: $($image.Name)"
            [IO.Path]::GetExtension($image.Name) -match ".png" | Should -Be $True
        }
    }
}
Describe "All images should be square" {
    It "Should match height and width" {
        Add-Type -AssemblyName System.Drawing
        ForEach ($image in $images) {
            Write-Host "Testing: $($image.Name)"
            $png = New-Object System.Drawing.Bitmap $image.FullName
            $png.Height -eq $png.Width | Should -Be $True
        }
    }
}
#endregion
