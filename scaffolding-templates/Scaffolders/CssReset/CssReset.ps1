[T4Scaffolding.Scaffolder(Description = "Custom CSS reset")][CmdletBinding()]
param(
    [string]$Project,
    [string]$CodeLanguage,
    [string[]]$TemplateFolders,
    [switch]$Force = $false
)

$outputPath = "public\css\reset"

Add-ProjectItemViaTemplate $outputPath -Template CssResetTemplate `
	-Model @{ } `
	-SuccessMessage "Added CssReset output at {0}" `
	-TemplateFolders $TemplateFolders -Project $Project -CodeLanguage $CodeLanguage -Force:$Force