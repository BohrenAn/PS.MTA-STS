﻿function Remove-PSMTASTSCustomDomain {
    <#
        .SYNOPSIS
        Remove-PSMTASTSCustomDomain removes custom domains from MTA-STS Function App.

        .DESCRIPTION
        Remove-PSMTASTSCustomDomain removes custom domains from MTA-STS Function App. It does not remove AzWebAppCertificates, as they could be used elsewhere.

        .PARAMETER ResourceGroupName
        Provide name of Resource Group where Function App is located.

        .PARAMETER FunctionAppName
        Provide name of Function App.

        .PARAMETER DomainName
        Provide name of domain to be removed.

        .EXAMPLE
        Remove-PSMTASTSCustomDomain -ResourceGroupName "MTA-STS" -FunctionAppName "MTA-STS-FunctionApp" -DomainName "mta-sts.contoso.com"

        Removes domain "mta-sts.contoso.com" from Function App "MTA-STS-FunctionApp" in Resource Group "MTA-STS".

        .LINK
        https://github.com/jklotzsche-msft/PS.MTA-STS
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]
        $FunctionAppName,

        [Parameter(Mandatory = $true)]
        [string]
        $DomainName
    )
    
    begin {
        if (($ResourceGroupName -and $FunctionAppName) -and ($null -eq (Get-AzContext))) {
            Write-Warning "Connecting to Azure service..."
            $null = Connect-AzAccount -ErrorAction Stop
        }
    }
    
    process {
        # Create new domain
        if($domain -notlike "mta-sts-*") {
            $domain = "mta-sts.$domain"
        }

        # Get current domains
        $currentHostnames = Get-PSMTASTSCustomDomain -ResourceGroupName $ResourceGroupName -FunctionAppName $FunctionAppName

        # Remove domain from array
        $newHostNames = $currentHostnames | Where-Object {$_ -ne $domain}
        
        # Try to remove domain from Function App
        if($null -ne (Compare-Object -ReferenceObject $currentHostnames -DifferenceObject $newHostNames)) {
            Write-Verbose "Removing $($currentHostnames.count - $newHostNames.count) domains from Function App $FunctionAppName..."
            try {
                $null = Set-AzWebApp -ResourceGroupName $ResourceGroupName -Name $FunctionAppName -HostNames $newHostNames -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_.Exception.Message
            }
        }
    }
    
    end {
        
    }

}