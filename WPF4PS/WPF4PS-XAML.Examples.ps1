

<#
.SYNOPSIS
WPF4PS framework Examples

.DESCRIPTION
How to call the Common Dialogs

.NOTES
Copyright Keith Garner, All rights reserved.

#>

[cmdletbinding()]
param()

import-module $PSScriptRoot\wpf4ps -force -ArgumentList ($VerbosePreference -eq "Continue")

$XAMLWindow = @{

	###############################################
	#
	#  Part 1 - A hashtable of Key/Value data to pass to/from the form
	#

    SyncHash = [Hashtable]::Synchronized(@{ 
        textBox1 = "Hello World" 
        radiobutton2 = "checked"
        ListBox1 = 'Three'
    })

	###############################################
	#
	#  Part 2 - The XAML content (as generated from Visual Studio)
	#

    XAML = (get-content -raw -path "$PSScriptRoot\MainWindow.xaml")

	###############################################
	#
	#  Part 3 - script block of event handlers automatically bound to elements in the XAML.
	#

    ControlScripts = [scriptBlock]{

        function global:WindowMain_Loaded()
        {
            get-childitem $PSscriptRoot | foreach-Object { $ListBox2.Items.Add( $_ ) }            
        }

        function global:windowmain_closing( [System.ComponentModel.CancelEventArgs] $e )
        {
            if ($TextBox1.Text.Length -eq 0)
            {
                "Text Box must not be empty" | Show-MessageBox
                $e.Cancel = $true
            }
        }

        function global:button1_click()
        {
            [System.Windows.Forms.MessageBox]::Show("Button CLick")
        }

        function global:buttonOK_click()
        {
            $WindowMain.DialogResult = $true
            $WindowMain.Close()
        }

        function global:Slider1_ValueChanged()
        {
            $progressBar1.Value = $Slider1.Value * 10
        }

    }

	###############################################

}

Show-XAMLWindow @XAMLWindow
# Show-XAMLWindowAsync @XAMLWindow

$XAMLWindow.SyncHash | out-string | write-output

