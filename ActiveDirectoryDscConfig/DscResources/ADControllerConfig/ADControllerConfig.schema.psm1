Configuration ADControllerConfig
{
    Import-DscResource -ModuleName PSDscResources -ModuleVersion '2.10.0.0'
    Import-DscResource -ModuleName xActiveDirectory -ModuleVersion '2.25.0.0'
    Import-DscResource -ModuleName xPendingReboot -ModuleVersion '0.4.0.0'
    Import-DscResource -ModuleName xDnsServer -ModuleVersion '1.11.0.0'

    WindowsFeature ADDSInstall
    {
        Ensure = "Present"
        Name = "AD-Domain-Services"
    }

    WindowsFeature ADDSToolsInstall {
        Ensure = 'Present'
        Name = 'RSAT-ADDS-Tools'
    }

    xPendingReboot AfterADDSToolsinstall
    {
        Name = 'AfterADDSinstall'
        DependsOn = "[WindowsFeature]ADDSToolsInstall"
    }

    Node $AllNodes.Where{$_.Role -eq "First DC"}.Nodename
    {  
        xADDomain FirstDS
        {
            DomainName = $Node.DomainName
            DomainNetBIOSName = $Node.DomainNetBIOSName
            DomainAdministratorCredential = $domainAdminCred
            SafemodeAdministratorPassword = $safemodeAdminCred
            DependsOn = "[xPendingReboot]AfterADDSToolsinstall"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainAdminCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[xADDomain]FirstDS"
        }

        xPendingReboot AfterADDSinstall
        {
            Name = 'AfterADDSinstall'
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }   
    }

    Node $AllNodes.Where{$_.Role -eq "Additional DC"}.Nodename
    {
        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainAdminCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADDomainController SecondDC
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainAdminCred
            SafemodeAdministratorPassword = $safemodeAdminCred
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }

        xPendingReboot AfterADDSinstall
        {
            Name = 'AfterADDSinstall'
            DependsOn = "[xADDomainController]SecondDC"
        }
    }

    xADReplicationSite 'NewPlymouthSite'
    {
       Ensure = 'Present'
       Name   = 'NewPlymouth'
       #RenameDefaultFirstSiteName = $true
    }    

    xADRecycleBin RecycleBin
    {
       EnterpriseAdministratorCredential = $EACredential
       ForestFQDN = $ForestFQDN
    }
}