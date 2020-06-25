function Get-LAPSCredential {
    [CmdletBinding(ConfirmImpact = "Low")]
    [OutputType([pscredential])]

    # Get-AdmPwdPassword only returns plaintext. So to satisfy PSScriptAnalyzer this is needed
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $Computername
    )

    begin { }

    process {
        foreach ($Computer in $Computername) {
            if (Get-AdmPwdPassword -Computername $Computer | Select-Object -ExpandProperty Password) {
                $Password = Get-AdmPwdPassword -Computername $Computer | Select-Object -ExpandProperty Password | ConvertTo-SecureString -AsPlainText -Force -ErrorAction Stop
            } else {
                Write-Error "Couldn't get Passwort for '$Computer'!" -ErrorAction Stop
            }
            $UserName = "$Computer\Administrator"

            [PSCredential]::new($Username, $Password)
        }
    }

    end { }

    <#
    .SYNOPSIS
    Retrieves the LAPS credentials for a Computer

    .DESCRIPTION
    Creates a credential object for each given computername.
    Username: computername\Administrator
    Password: retrieved from LAPS

    .PARAMETER Computername
    One or more computernames for which to create credentials

    .EXAMPLE
    Get-LAPSCredential -Computername "DESKTOP-HYKJASF"

    .NOTES
    none
    #>

}

Export-ModuleMember -Function Get-LAPSCredential
