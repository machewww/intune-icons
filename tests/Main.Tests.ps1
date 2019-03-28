# AppVeyor Testing
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $projectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $projectRoot = ((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
}
Write-Host "Project root is: $projectRoot"

# Optimise images
$images = Get-ChildItem -Path (Join-Path $projectRoot "icons") -Recurse -Include *.*
ForEach ($image in $images) {
    Write-Host "Optimising: $($image.Name)"
    PNGOUT $image.Name
}

# Tests
Describe "Images tests" {
    $images = Get-ChildItem -Path (Join-Path $projectRoot "icons") -Recurse -Include *.*
    It "Should only contain PNG images" {
        ForEach ($image in $images) {
            Write-Host "Testing: $($image.Name)"
            [IO.Path]::GetExtension($image.Name) -match ".png" | Should -Be $True
        }
    }
}
