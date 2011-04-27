[T4Scaffolding.Scaffolder(Description = "Database Migration for use by migratordotnet")][CmdletBinding()]
param(
	[parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$MigrationName,
    [string]$Project,
	[string]$CodeLanguage,
	[string[]]$TemplateFolders,
	[switch]$Force = $true
)

$migid = ([System.DateTime]::Now).ToString("yyyyMMddHHmmss")
$outputPath = "Migrations/" + $migid.ToString() + "_" + $MigrationName
$namespace = (Get-Project $Project).Properties.Item("DefaultNamespace").Value + ".Migrations"

Add-ProjectItemViaTemplate $outputPath -Template MigrationTemplate `
	-Model @{ Namespace = $namespace; MigrationName = $MigrationName; MigrationId = $migid.ToString() } `
	-SuccessMessage "Added Migration output at {0}" `
	-TemplateFolders $TemplateFolders -Project $Project -CodeLanguage $CodeLanguage -Force:$Force