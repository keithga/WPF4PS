
<#
.SYNOPSIS
WPF4PS framework Examples

.DESCRIPTION
How to call the XAML functions

.NOTES
Copyright Keith Garner, All rights reserved.

#>

import-module $PSScriptRoot\WPF4PS -force


Show-MessageBox "Hello World"
"Hello World" | Show-MessageBox
(Show-MessageBox "Do you like Ice Cream?" -Buttons 4) -eq 6

Select-SaveFileDialog
Select-SaveFileDialog -Title "Save Log File" -Filter "Text Files (*.log)|*.log|All Files (*.*)|*.*" -DefaultExt "log"

Select-OpenFileDialog
Select-OpenFileDialog -Title "Open Log File" -Filter "Text Files (*.log)|*.log|All Files (*.*)|*.*" 

