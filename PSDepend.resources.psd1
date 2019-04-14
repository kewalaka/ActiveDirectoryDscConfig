@{
    PSDependOptions              = @{
        AddToPath      = $true
        Target         = 'DSC_Resources'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository = 'PSGallery'
        }
    }

    xActiveDirectory    = '2.25.0.0'
    xPendingReboot      = '0.4.0.0'
    xDNSServer          = '1.11.0.0'
    PSDscResources      = '2.10.0.0'
}