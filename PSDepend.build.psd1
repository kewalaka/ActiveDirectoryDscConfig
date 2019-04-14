#PSDepend dependencies
# Either install modules for generic use or save them in ./modules for Test-Kitchen

@{
    # Set up a mini virtual environment...
    PSDependOptions = @{
        AddToPath = $True
        Target = 'BuildOutput\modules'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository = 'PSGallery'
        }
    }

    InvokeBuild       = 'latest'
    BuildHelpers      = 'latest'
    Pester            = 'latest'
    PSScriptAnalyzer  = 'latest'
    DscBuildHelpers   = 'latest'
    Datum             = 'latest'
    'powershell-yaml' = 'latest'
}