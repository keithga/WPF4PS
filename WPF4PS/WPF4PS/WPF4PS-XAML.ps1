
<#
.SYNOPSIS 
WPF4PS PowerShell Library

.DESCRIPTION
Windows Presentation Framework for PowerShell Module Library
    Support routines for XAML display

.NOTES
Copyright Keith Garner (KeithGa@DeploymentLive.com), All rights reserved.

Thanks to:

http://stackoverflow.com/questions/15501938/powershell-multi-runspace-event-passing
http://www.ephingadmin.com/better-know-a-powershell-ui/
https://foxdeploy.com/resources/learning-gui-toolmaking-series/
https://learn-powershell.net/2012/10/14/powershell-and-wpf-writing-data-to-a-ui-from-a-different-runspace/

.LINK
https://github.com/keithga/WPF4PS

#>

#region UISupportFunctions

function Add-XAMLChild
{
    [CmdLetBinding()]
    PARAM ( $Children, $windowForm, [HashTable]$SyncHash )

    write-verbose "Add-XAMLChild"

    foreach ( $Child in $Children )
    {
        if ( -not ( [string]::IsNullOrEmpty($Child.Name ) ) )
        {
            write-verbose "Set Variable name $($Child.Name)"
            Set-Variable -Name ($Child.Name) -Value $windowForm.FindName($Child.Name) -scope global

            # If found in SyncHash then load into form
            if ($SyncHash)
            {
                if ($SyncHash.ContainsKey($Child.Name))
                {
                    switch -regex -casesensitive ( $child.gettype().Name ) 
                    {
                        '(CheckBox|RadioButton)' { if ($syncHash[$Child.Name] -eq 'checked' ) { $Child.IsChecked = $true } }
                        '(TextBox|PasswordBox)'  { $Child.Text = $syncHash[$Child.Name] }
                        'ListBox'                { $Child.Items | where-object Content -eq $syncHash[$Child.Name] | foreach-object { $Child.SelectedItem = $_ } }
                        '(ProgressBar|Slider)'   { }
                        default {  write-verbose "`t`t`t UNknown type: $($child.gettype().Name)" }
                    }
                }
            }

            # Add an event handler if found Like: $windowMain.Add_Loaded( { windowMain_Loaded } )
            Foreach ($Event in ($Child | Get-Member -MemberType Event) )
            {
                write-debug "`t`tSearch for $($Child.Name)_$($Event.Name)"
                if ( test-path ("Function:$($Child.Name)_$($Event.Name)") ) 
                {
                    write-verbose "add `$$($Child.Name).Add_$($Event.Name)( { $($Child.Name)_$($Event.Name) } )"
                    invoke-expression "`$$($Child.Name).Add_$($Event.Name)( { $($Child.Name)_$($Event.Name)(`$_) } )"
                }
            }
        }
        if ( $Child.Children )
        {
            Add-XAMLChild -Children $Child.Children -windowForm $WindowForm -SyncHash $SyncHash
        }
    }
}

function Get-XAMLChild
{
    [CmdLetBinding()]
    PARAM ( $Children, $windowForm, [HashTable]$SyncHash )

    write-verbose "get-XAMLChild"

    foreach ( $Child in $Children )
    {
        if ( -not ( [string]::IsNullOrEmpty($Child.Name ) ) )
        {
            write-verbose "`t`tGet Variable name $($Child.Name)"
            switch -regex -casesensitive ( $child.gettype().Name ) 
            {
                '(CheckBox|RadioButton)' { if ($Child.IsChecked) { $syncHash[$Child.Name] = 'checked'  } } 
                '(TextBox|PasswordBox)'  { $syncHash[$Child.Name] = $Child.Text }
                'ListBox'                { $syncHash[$Child.Name] = $Child.SelectedItem.Content } 
                '(ProgressBar|Slider)'   { }
                default {  write-verbose "`t`t`t UNknown type: $($child.gettype().Name)" }
            }
        }
        if ( $Child.Children )
        {
            Add-XAMLChild -Children $Child.Children -windowForm $WindowForm -SyncHash $SyncHash
        }
    }


}

function Invoke-CallBackToHost 
{
    <#
        Register-EngineEvent -SourceIdentifier "TestClicked" -Action {$Global:x.host.UI.Write("Event Happened!")}
        $x.Host.Runspace.Events.GenerateEvent( "TestClicked", $x.test, $null, "test event") 
    #>
    PARAM(
        [string]   $ID = "PowerShellUI",
        [parameter(ValueFromPipeline=$true)]
        [PSObject] $Data,
        [parameter(ValueFromRemainingArguments=$true)]
        [object[]] $args
    )
    $ParentHost.Runspace.Events.GenerateEvent( $ID, $host, $args, $Data) 
}


#endregion

#region UIThreadFunctions

[scriptblock]$UIThreadFunctions1 = {

    param( $SH = $SyncHash, $parentHost = $Host, $XF = $XAMLForm, $WPF4PSModule = $PSScriptRoot )

    import-module $WPF4PSModule -force -Scope local -ArgumentList ($VerbosePreference -eq "Continue")

}

[scriptblock]$UIThreadFunctions2 = {

    $windowForm = [Windows.Markup.XamlReader]::Load( (New-Object System.Xml.XmlNodeReader $XF) )
    Add-XAMLChild -children ($windowForm.Content.Children + $windowForm) -WindowForm $windowForm -SyncHash $SH
    $windowForm.Owner = [System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle -as [System.Windows.Window]
    $dialogResult = $windowForm.ShowDialog() 
    if ( $SH ) 
    { 
        Get-XAMLChild -Children ($windowForm.Content.Children + $windowForm) -WindowForm $windowForm -SyncHash $SH
        $sh.Result = $Dialogresult  
        $SH.Window = $windowForm
    }

<#
#>

}

#endregion

#region Show-XAMLWindow

function Show-XAMLWindow
{
<#
.SYNOPSIS 
Show WPF XAML Window in PowerShell

.DESCRIPTION
Show a Windows Presentation Framework XAML file in Powershell. 

This routine will run synchronously, blocking powershell execution until the dialog box is closed. 

.PARAMETER XAML
String blob of XAML code, can be a XAML blob directly from Visual Studio

.PARAMETER ControlScripts
A PowerShell ScriptBlock containing callback functions for control events
	If the WPF form has control like:
		<TextBox x:Name="textBox1" ... 
	And the scriptblock contains a function like (Note the Global):
		function global:TextBox1_OnTextChanged()  {  $TextBox2.Text = $TextBox1.Text } 
	Then the function will be assigned to the OnTextChanged event handler for TextBox1.

	Note that any control given a Name will be assigned a variable of the same name, like $TextBox1 and $TextBox2

.PARAMETER SyncHash
HashTable of Key/Values to be passed between PowerShell and the WPF form.
	If a control exits with a given name, WPF4PS will attempt to load the SyncHash value of the same name.
	All controls with a given name will be assigned back into the SyncHash once the form is closed. 

	Additionally "Result" will be given the return value from ShowDialog (typically true/false) and 
	"Window" will be given the handle from the Window object.

.NOTES
Copyright Keith Garner (KeithGa@DeploymentLive.com), All rights reserved.

.LINK
https://github.com/keithga/WPF4PS

#>
    param(
        [parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
	    [string]       $XAML,
        [parameter(Mandatory=$true,Position=1)]
        [scriptblock]  $ControlScripts,
        [parameter(Mandatory=$false,Position=2)]
        [HashTable]    $SyncHash
    )

    write-verbose "Show XAML Window"

    [xml]$IntXAML = $XAML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'

    $NewScriptBlock = [ScriptBlock]::Create($UIThreadFunctions1.ToString() + $ControlScripts.ToString() + $UIThreadFunctions2.ToString())

    invoke-command -ArgumentList $SyncHash, $Host, $IntXAML, $PSScriptRoot -ScriptBlock $NewScriptBlock

}

function Show-XAMLWindowAsync
{
<#
.SYNOPSIS 
Show WPF XAML Window in PowerShell

.DESCRIPTION
Show a Windows Presentation Framework XAML file in Powershell. 

This routine will run Asynchronously, running the processing in a background thread. 

.PARAMETER XAML
String blob of XAML code, can be a XAML blob directly from Visual Studio

.PARAMETER ControlScripts
A PowerShell ScriptBlock containing callback functions for control events
	If the WPF form has control like:
		<TextBox x:Name="textBox1" ... 
	And the scriptblock contains a function like (Note the Global):
		function global:TextBox1_OnTextChanged()  {  $TextBox2.Text = $TextBox1.Text } 
	Then the function will be assigned to the OnTextChanged event handler for TextBox1.

	Note that any control given a Name will be assigned a variable of the same name, like $TextBox1 and $TextBox2

.PARAMETER SyncHash
HashTable of Key/Values to be passed between PowerShell and the WPF form.
	If a control exits with a given name, WPF4PS will attempt to load the SyncHash value of the same name.
	All controls with a given name will be assigned back into the SyncHash once the form is closed. 

	Additionally "Result" will be given the return value from ShowDialog (typically true/false) and 
	"Window" will be given the handle from the Window object.

.NOTES
Copyright Keith Garner (KeithGa@DeploymentLive.com), All rights reserved.

.LINK
https://github.com/keithga/WPF4PS

#>

    param(
        [parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
	    [string]       $XAML,
        [parameter(Mandatory=$true,Position=1)]
        [scriptblock]  $ControlScripts,
        [parameter(Mandatory=$false,Position=2)]
        [HashTable]    $SyncHash
    )

    write-verbose "Show XAML Window"

    [xml]$IntXAML = $XAML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'

    $NewScriptBlock = [ScriptBlock]::Create($UIThreadFunctions1.ToString() + $ControlScripts.ToString() + $UIThreadFunctions2.ToString())

    $RunSpace = [RunspaceFactory]::CreateRunspace()
    $RunSpace.ApartmentState ="STA"
    $RunSpace.ThreadOptions = "ReUseThread"
    $RunSpace.Open() | out-null
    $RunSpace.SessionStateProxy.SetVariable("SyncHash",$SyncHash)
    $RunSpace.SessionStateProxy.SetVariable("ParentHost",$Host)
    $RunSpace.SessionStateProxy.SetVariable("XAMLForm",$IntXAML)
    $RunSpace.SessionStateProxy.SetVariable("WPF4PS", $PSScriptRoot )

    $Pipeline = $runspace.CreatePipeline()

    $cmd = [PowerShell]::Create().AddScript( $NewScriptBlock ) 
    $cmd.Runspace = $RunSpace
    $cmd.BeginInvoke() | Write-Output

}

#endregion

