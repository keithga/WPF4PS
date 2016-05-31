
<#
.SYNOPSIS
WPF4PS framework Examples

.DESCRIPTION
Simple Example

.NOTES
Copyright Keith Garner, All rights reserved.

#>

[cmdletbinding()]
param()

import-module $PSScriptRoot\wpf4ps -force -ArgumentList ($VerbosePreference -eq "Continue")

$MyXAML = @"
<Window x:Class="WpfApplication1.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication1"
        mc:Ignorable="d"
        Title="MainWindow" FontFamily="Segoe WP Semibold" Width="400" Height="300" Name="WindowMain" >
    <Grid>
        <Label>Hello World</Label>
        <Button x:Name="Button1" Content="Big Red Button" Width="125" Height="25" Background="#FFDD0000" Margin="0,60,0,0"/>
        <TextBox x:Name="textBox1" Height="23"  Width="200" />
    </Grid>
</Window>
"@

$MyControl = [scriptBlock]{

    function global:button1_click()
    {
		"Click the Big Red Button`n" + $TextBox1.TExt  | show-MessageBox 
		$WindowMain.Close()
    }

}

$MyHash = [Hashtable]::Synchronized(@{ textBox1 = "Hello World" })

Show-XAMLWindow -XAML $MyXAML -ControlScripts $MyControl -SyncHash $MyHash

$MyHash.TextBox1 | Write-Host 