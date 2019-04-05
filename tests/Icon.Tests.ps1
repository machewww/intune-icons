# AppVeyor Testing
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $projectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $projectRoot = ((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
}

#region Tests
$icons = Join-Path $projectRoot "icons"
$images = Get-ChildItem -Path $icons -Recurse -Include *.*

Describe "All images should be in PNG format" {
    ForEach ($image in $images) {
        It "$($image.Name) should be a .PNG file" {
            [IO.Path]::GetExtension($image.Name) -match ".png" | Should -Be $True
        }
    }
}
Describe "All images should be square" {
    Add-Type -AssemblyName System.Drawing
    ForEach ($image in $images) {
        $png = New-Object System.Drawing.Bitmap $image.FullName
        It "$($image.Name) should match height and width" {
            $png.Height -eq $png.Width | Should -Be $True
        }
    }
}
#endregion
