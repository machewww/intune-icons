<#
    .SYNOPSIS
        Pester tests
#>

#region Tests
$icons = Join-Path $projectRoot "icons"
$images = Get-ChildItem -Path $icons -Recurse -Include *.*

Describe "Image format tests" {
    ForEach ($image in $images) {
        It "$($image.Name) should be a .PNG file" {
            [IO.Path]::GetExtension($image.Name) -match ".png" | Should -Be $True
        }
    }
}
Describe "Image dimension tests" {
    Add-Type -AssemblyName System.Drawing
    ForEach ($image in $images) {
        $png = New-Object System.Drawing.Bitmap $image.FullName
        It "$($image.Name) should match height and width" {
            $png.Height -eq $png.Width | Should -Be $True
        }
        It "$($image.Name) height should be 246 pixels or more" {
            $png.Height -ge 246 | Should -Be $True
        }
        It "$($image.Name) width should be 246 pixels or more" {
            $png.Width -ge 246 | Should -Be $True
        }
    }
}
#endregion
