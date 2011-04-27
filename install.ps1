
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
$sln = $dte.Solution.FileName | split-path -parent
$templates = join-path $sln "mvcboost\scaffolding-templates"
$proj = (get-project).FileName | split-path -parent
$binfile = join-path (get-project).name (join-path "bin\" (get-project).Properties.Item("OutputFileName").Value)

Task "Installing MvcScaffolding..."`
	{ Install-Package MvcScaffolding > $null }

Task "Installing MigratorDotNet..."`
	{ Install-Package MigratorDotNet > $null }

Task "Creating public directories..." `
	{ @( "img", "css", "js" ) | % { new-item (join-path (join-path $proj "public") $_) -type directory } > $null }`
	{ return Test-Path (join-path $proj "public") }

Task "Copying custom t4 templates..." `
	{ copy-item $templates -destination (join-path $proj "CodeTemplates") -recurse }`
	{ Test-Path (join-path $proj "CodeTemplates") }

Task "Creating custom build file..." `
  { $file = @"
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <MigratorTasksPath>`$(MSBuildProjectDirectory)\migrator</MigratorTasksPath>
  </PropertyGroup>

  <Import Project="`$(MigratorTasksPath)\Migrator.Targets"/>

  <Target Name="Migrate">
    <Migrate Migrations="$binfile" Provider="SqlServer" ConnectionString="Data Source=r2d2;Initial Catalog=DATABASE_NAME;Integrated Security=SSPI;"/>
  </Target>
</Project>
"@
     $file > build.proj
   }`
   { Test-Path "build.proj" }

Task "Generating dummy scaffolder"`
  { Scaffold CustomScaffolder DummyScaffolder }

Task "Generating css reset..."`
  { Scaffold CssReset }

Write-Host
Write-Host "TODO: modify database connection string in build.proj"
Write-Host "TODO: delete dummy scaffolder from CodeTemplates"