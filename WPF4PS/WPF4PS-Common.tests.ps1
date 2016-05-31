
<#
.SYNOPSIS
WPF4PS framework Testing

.DESCRIPTION
Pester tests for WFP4PS libraries

.NOTES
Copyright Keith Garner, All rights reserved.

#>

import-module $PSScriptRoot\WPF4PS -force

Describe "MessageBox" {
    It "Simple MsgBox" {
        Show-MessageBox -Message "Hello World" | should be ([System.Windows.Forms.DialogResult]::OK).ToString()
        "Hello World " | Show-MessageBox | should be ([System.Windows.Forms.DialogResult]::OK).ToString()
    }

    It "MsgBox with title" {
        Show-MessageBox -Message "Hello World" -title "Random Title" | should be ([System.Windows.Forms.DialogResult]::OK).ToString()
    }

    It "MsgBox with icons" {
        Show-MessageBox -Message "Hello World" -title "Random Title" -icons 16 | should be ([System.Windows.Forms.DialogResult]::OK).ToString()
        Show-MessageBox -Message "Hello World" -title "Random Title" -icons 32 | should be ([System.Windows.Forms.DialogResult]::OK).ToString()
        Show-MessageBox -Message "Hello World" -title "Random Title" -icons 48 | should be ([System.Windows.Forms.DialogResult]::OK).ToString()
        Show-MessageBox -Message "Hello World" -title "Random Title" -icons 64 | should be ([System.Windows.Forms.DialogResult]::OK).ToString()
    }

    it "MsgBox with Buttons" {
        Show-MessageBox -Message "Hello World" -buttons 0 | should be ([System.Windows.Forms.DialogResult]::OK).ToString()

        write-host "OK Cancel"
        Show-MessageBox -Message "Hello World" -buttons 1 | should be ([System.Windows.Forms.DialogResult]::OK).ToString()
        Show-MessageBox -Message "Hello World" -buttons 1 | should be ([System.Windows.Forms.DialogResult]::Cancel).ToString()

        write-host "Abort Retry Cancel"
        Show-MessageBox -Message "Hello World" -buttons 2 | should be ([System.Windows.Forms.DialogResult]::Abort).ToString()
        Show-MessageBox -Message "Hello World" -buttons 2 | should be ([System.Windows.Forms.DialogResult]::Retry).ToString()
        Show-MessageBox -Message "Hello World" -buttons 2 | should be ([System.Windows.Forms.DialogResult]::Ignore).ToString()

        write-host "Yes No Cancel"
        Show-MessageBox -Message "Hello World" -buttons 3 | should be ([System.Windows.Forms.DialogResult]::Yes).ToString()
        Show-MessageBox -Message "Hello World" -buttons 3 | should be ([System.Windows.Forms.DialogResult]::No).ToString()
        Show-MessageBox -Message "Hello World" -buttons 3 | should be ([System.Windows.Forms.DialogResult]::Cancel).ToString()

        write-host "Yes No"
        Show-MessageBox -Message "Hello World" -buttons 4 | should be ([System.Windows.Forms.DialogResult]::Yes).ToString()
        Show-MessageBox -Message "Hello World" -buttons 4 | should be ([System.Windows.Forms.DialogResult]::No).ToString()

        write-host "Retry Cancel"
        Show-MessageBox -Message "Hello World" -buttons 5 | should be ([System.Windows.Forms.DialogResult]::Retry).ToString()
        Show-MessageBox -Message "Hello World" -buttons 5 | should be ([System.Windows.Forms.DialogResult]::Cancel).ToString()
    }

}


Describe "SaveFileDialog" {
    It "Simple File Save" {
        write-host "Type 'FOO<Enter>'"
        Select-SaveFileDialog  | should match ".*\\foo"
    }

    It "Empty Case " {
        write-host "Type 'FOO<Enter>'"
        Select-SaveFileDialog -DefaultExt "foo" | should match ".*\\foo.foo"
    }

    It "Complex Case " {
        write-host "Type 'FOO<Enter>'"
        Select-SaveFileDialog -Title "Open Log File" -Filter "Text Files (*.log)|*.log|All Files (*.*)|*.*" | should match ".*\\foo"
    }

}

Describe "OpenFileDialog" {
    It "Simple File Open" {
        write-host "Select Any File"
        Select-OpenFileDialog | should exist
    }

    It "Empty Case " {
        write-host "Press Cancel"
        Select-OpenFileDialog | should be $null
    }

    It "Complex Case " {
        write-host "Select Any File"
        Select-OpenFileDialog -Title "Open Log File" -Filter "Text Files (*.log)|*.log|All Files (*.*)|*.*" | should exist
    }

}



