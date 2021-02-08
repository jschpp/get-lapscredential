$ModuleName = "Get-LAPSCredential"
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$out = Join-Path $Here "out"
$bin = Join-Path $Here "bin"
$ModulePath = Join-Path $Here $ModuleName

if (Test-Path $out) {
    Remove-Item $out -Recurse -Verbose
}
New-Item $out -ItemType Directory

Copy-Item -Path $ModulePath\* -Destination $out -Recurse
$Module = Test-ModuleManifest -Path (Join-path -Path $out -ChildPath "$ModuleName.psd1")
nuget.exe pack "$ModuleName.nuspec" -Version $Module.Version -BasePath $out -outputdirectory $bin
