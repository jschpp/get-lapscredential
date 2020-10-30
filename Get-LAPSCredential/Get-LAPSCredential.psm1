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
            $AdmPwdPassword = Get-AdmPwdPassword -Computername $Computer | Select-Object -ExpandProperty Password
            if ($AdmPwdPassword) {
                $Password = $AdmPwdPassword | ConvertTo-SecureString -AsPlainText -Force -ErrorAction Stop
            } else {
                Write-Error "Couldn't get Password for '$Computer'!" -ErrorAction Stop
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
    One or more computername(s) for which to create credentials

    .EXAMPLE
    PS C:\> Get-LAPSCredential -Computername "DESKTOP-HYKJASF"

    UserName                                          Password
    --------                                          --------
    DESKTOP-HYKJASF\Administrator System.Security.SecureString

    .INPUTS
    System.String. Name of the Computer for which the credential will be created.

    .OUTPUTS
    System.Management.Automation.PSCredential. Created Credential.

    .NOTES
    none
    #>

}

Export-ModuleMember -Function Get-LAPSCredential
