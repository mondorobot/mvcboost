param($installPath, $toolsPath, $package, $project)

# Build some helpful paths
$proj = $project.FileName | split-path -parent
$projFileName = $project.FullName | split-path -leaf
$binfile = join-path "bin\" $project.Properties.Item("OutputFileName").Value
$targetsfile = join-path $toolsPath 'migrations.targets'

Write-Host "Writing custom build targets..."
@"
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <MigratorTasksPath>$toolsPath</MigratorTasksPath>
  </PropertyGroup>

  <Import Project="`$(MigratorTasksPath)\Migrator.Targets"/>

  <Target Name="Migrate">
    <Migrate Migrations="$binfile" Provider="SqlServer" ConnectionString="Database=DATABASE_NAME;Data Source=DATABASE_SERVER;Trusted_Connection=true"/>
  </Target>

  <Target Name="ScriptMigration">
    <Migrate Provider="SqlServer"
            Connectionstring="Database=DATABASE_NAME;Data Source=DATABASE_SERVER;Trusted_Connection=true;"
            Directory="db\`$(SchemaVersion)"
            Scriptfile="migrations.sql"/>
  </Target>
</Project>
"@ > $targetsfile

Write-Host "Importing custom build targets..."
$targetsFile = join-path $toolsPath 'migrations.targets'
 
# Need to load MSBuild assembly if it's not loaded yet.
Add-Type -AssemblyName 'Microsoft.Build, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'

# Grab the loaded MSBuild project for the project
$msbuild = [Microsoft.Build.Evaluation.ProjectCollection]::GlobalProjectCollection.GetLoadedProjects($project.FullName) | Select-Object -First 1

# Make the path to the targets file relative.
$projectUri = new-object Uri('file://' + $project.FullName)
$targetUri = new-object Uri('file://' + $targetsFile)
$relativePath = $projectUri.MakeRelativeUri($targetUri).ToString().Replace([System.IO.Path]::AltDirectorySeparatorChar, [System.IO.Path]::DirectorySeparatorChar)

# Add the import and save the project
$msbuild.Xml.AddImport($relativePath) | out-null
$project.Save()

Write-Host
Write-Host "TODO: modify database connection strings in $targetsFile" -ForegroundColor DarkMagenta
Write-Host "TODO: delete "Scripts" and "Content" folder if not using them" -ForegroundColor DarkMagenta
Write-Host "TODO: change default layout to _Layout-HTML5.cshtml" -ForegroundColor DarkMagenta
Write-Host
Write-Host "To deploy migrations, execute: " -ForegroundColor Green
Write-Host "    MSBuild $projFileName /t:Migrate" -ForegroundColor DarkGray