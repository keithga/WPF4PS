
<#
.SYNOPSIS 
WPF4PS PowerShell Library

.DESCRIPTION
Windows Presentation Framework for PowerShell Module Library

.NOTES
Copyright Keith Garner (KeithGa@DeploymentLive.com), All rights reserved.

.LINK
https://github.com/keithga/WPF4PS

#>

[CmdletBinding()]
param(
	[parameter(Position=0,Mandatory=$false)]
	[Switch] $Verbose = $false
)

if ($Verbose)
{
	# Work Arround: I could not get verbose to work within a *.psm1 file using CmdletBinding
	$VerbosePreference = "Continue"
}

Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase,"System.Windows.Forms"

foreach ( $Script in get-childitem -path $PSScriptRoot\WPF4PS-*.ps1 )
{
    write-verbose "dot source script: $Script"
    . $Script
}

Export-ModuleMember -Function Select-OpenFileDialog, Select-SaveFileDialog, Show-MessageBox, Show-XAMLWindow, Show-XAMLWindowAsync, Add-XAMLChild, Get-XAMLChild
