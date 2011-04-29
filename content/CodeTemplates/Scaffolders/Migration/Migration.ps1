[T4Scaffolding.Scaffolder(Description = "Database Migration for use by migratordotnet")][CmdletBinding()]
param(
	[parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$MigrationName,
    [string]$Project,
	[string]$CodeLanguage,
	[string[]]$TemplateFolders,
	[switch]$Force = $false
)

$migid = ([System.DateTime]::Now).ToString("yyyyMMddHHmmss")
$outputPath = "Migrations\" + $migid.ToString() + "_" + $MigrationName
$namespace = (Get-Project $Project).Properties.Item("DefaultNamespace").Value + ".Migrations"
$templateName = "GenericMigrationTemplate"
$entity1Guess = "Example"
$entity2Guess = "OtherExample"


function Generate-SpecializedMigration {
	param([int]$prefixLength, [string]$class)
	
	("Table", "FK", "ForeignKey", "Index") | ? { ($MigrationName.SubString($prefixLength, $_.Length) -eq $_) } | % {
		$templateName = $class + $_ + "MigrationTemplate"

		$split = $MigrationName.Substring($MigrationName.IndexOf($_) + $_.Length).Split("_-, ")
		$entity1Guess = $split[0]
		$entity2Guess = $split[1]

		Add-ProjectItemViaTemplate $outputPath -Template $templateName `
			-Model @{ Namespace = $namespace; MigrationName = $MigrationName; MigrationId = $migid.ToString(); Entity1Guess = $entity1Guess; Entity2Guess = $entity2Guess } `
			-SuccessMessage "Added $_ Migration output at {0}" `
			-TemplateFolders $TemplateFolders -Project $Project -CodeLanguage $CodeLanguage -Force:$Force
	}
}

("^Add", "^Create") | %{ if($MigrationName -match $_) {
	Generate-SpecializedMigration ($_.Length - 1) "Create"
	exit
} }

Add-ProjectItemViaTemplate $outputPath -Template $templateName `
	-Model @{ Namespace = $namespace; MigrationName = $MigrationName; MigrationId = $migid.ToString() } `
	-SuccessMessage "Added Migration output at {0}" `
	-TemplateFolders $TemplateFolders -Project $Project -CodeLanguage $CodeLanguage -Force:$Force