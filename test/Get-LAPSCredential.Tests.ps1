$ModuleManifestName = 'Get-LAPSCredential.psd1'
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Modules = Get-ChildItem "$here\.." -Filter '*.psm1' -Recurse
$Rules = Get-ScriptAnalyzerRule
$ModuleManifestPath = Resolve-Path "$Here\..\Get-LAPSCredential\$ModuleManifestName"

Import-Module $ModuleManifestPath

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

Describe 'Testing all Modules in this Repo to be be correctly formatted' {
    foreach ($module in $modules) {
        Context "Testing Module - $($module.BaseName) for Standard Processing" {
            foreach ($rule in $rules) {
                It "passes the PSScriptAnalyzer Rule $rule" {
                    (Invoke-ScriptAnalyzer -Path $module.FullName -IncludeRule $rule.RuleName ).Count | Should Be 0
                }
            }
        }
    }
}

InModuleScope "Get-LAPSCredential" {
    Describe 'Testing if a credential is returned' {
        Mock "Get-AdmPwdPassword" { return [pscustomObject]@{Password = "Test" } }
        Mock "Get-AdmPwdPassword" { return [pscustomObject]@{Password = "" } } -ParameterFilter { $Computername -eq "Invalid" }
        It 'returns an error when theres an invalid name or wrong credentials' {
            { Get-LAPSCredential -Computername "Invalid" } | Should -Throw
            Assert-MockCalled -CommandName "Get-AdmPwdPassword" -Times 1
        }
        It 'returns the correct credential' {
            $cred = Get-LapsCredential -Computername "Test"
            $cred.UserName | Should -Be "Test\Administrator"
            $cred.GetNetworkCredential().Password | Should -BeExactly "Test"
            Assert-MockCalled -CommandName "Get-AdmPwdPassword" -Times 1
        }
    }
}
