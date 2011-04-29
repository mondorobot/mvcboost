
function Done {
	Write-Host "done" -ForegroundColor Green
}

function Skip {
	Write-Host "skipped" -ForegroundColor Gray
}

function Task {
	param([string]$msg, [scriptblock]$taskfunc, [scriptblock]$canskip = { $false })

	Write-Host $msg -nonewline
	if(!($canskip.Invoke())) {
		$taskfunc.Invoke()
		Done
	} else {
		Skip
	}
}

# Build some helpful paths
$proj = (get-project).FileName | split-path -parent
$binfile = join-path (get-project).name (join-path "bin\" (get-project).Properties.Item("OutputFileName").Value)

Task "Creating custom build file..." `
  { $file = @"
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <MigratorTasksPath>`$(MSBuildProjectDirectory)\tools</MigratorTasksPath>
  </PropertyGroup>

  <Import Project="`$(MigratorTasksPath)\Migrator.Targets"/>

  <Target Name="Migrate">
    <Migrate Migrations="$binfile" Provider="SqlServer" ConnectionString="Database=DATABASE_NAME;Data Source=DATABASE_SERVER;Trusted_Connection=true"/>
  </Target>

  <Target Name="ScriptMigration">
    <Migrate Provider="SqlServer"
            Connectionstring="Database=DATABASE_NAME;Data Source=DATABASE_SERVER;Trusted_Connection=true;"
            Directory="db\$(SchemaVersion)"
            Scriptfile="migrations.sql"/>
  </Target>
</Project>
"@
     $file > migrations.proj
   }`
   { Test-Path "migrations.proj" }

Write-Host
Write-Host "TODO: modify database connection strings in build.proj"
Write-Host
Write-Host "To deploy migrations, execute: "
Write-Host "    MSBuild migrations.proj /t:Migrate"