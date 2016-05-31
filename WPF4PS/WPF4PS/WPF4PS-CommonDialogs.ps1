
<#
.SYNOPSIS 
WPF4PS PowerShell Library

.DESCRIPTION
Windows Presentation Framework for PowerShell Module Library
    Support routines for Common Dialog Boxes

.NOTES
Copyright Keith Garner (KeithGa@DeploymentLive.com), All rights reserved.

.LINK
https://github.com/keithga/WPF4PS

#>

function script:Get-WindowOwner
{
<#
 .SYNOPSIS
Get the Window Owner

.DESCRIPTION
Get the Window handle of the parent $host process
Otherwise a DialogBox can appear in the background. 

.LINK
http://poshcode.org/2002

#>

Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;

public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    
    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}
"@ -ReferencedAssemblies "System.Windows.Forms.dll"

New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle) | write-output

}

function Select-SaveFileDialog
{
<#
 .SYNOPSIS
Display a SaveFileDialog()

.DESCRIPTION
Display a File Save Dialog

.PARAMETER Title
    Caption of File Dialog

.PARAMETER Filter
    Gets or sets a filter string that specifies the files types and descriptions to display in the SaveFileDialog.

    Examples:
        Image Files (*.bmp, *.jpg)|*.bmp;*.jpg
        Text Files (*.txt)|*.txt|All Files (*.*)|*.*

.PARAMETER DefaultExt
    Gets or sets the default file name extension applied to files that are saved with the SaveFileDialog.

.OUTPUTS
    Returns the path to the saved file.

.EXAMPLE
    $OutFile = Select-SaveFileDialog

.EXAMPLE
    $OutFile = Select-SaveFileDialog -Title "Save Log File" -Filter "Text Files (*.log)|*.log|All Files (*.*)|*.*" -DefaultExt "log"

#>
    param(
        [String] $Title  = $null,
        [string] $Filter = 'All files (*.*)|*.*',
        [string] $DefaultExt = ''

    )

    $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    #$SaveFileDialog.OverwritePrompt = $true
    $SaveFileDialog.Title = $Title
    $SaveFileDialog.Filter = $Filter
    $SaveFileDialog.DefaultExt = $DefaultExt
    if ( $SaveFileDialog.ShowDialog((Get-WindowOwner)) -eq [System.Windows.Forms.DialogResult]::OK )
    {
        $SaveFileDialog.FileName | Write-Output
    }
   
}

function Select-OpenFileDialog
{
<#
 .SYNOPSIS
Display a OpenFileDialog()

.DESCRIPTION
Display a File Open Dialog

.PARAMETER Title
    Caption of File Dialog

.PARAMETER MultiSelect
    More than one file can be opened

.PARAMETER Filter
    Gets or sets a filter string that specifies the files types and descriptions to display in the SaveFileDialog.

    Examples:
        Image Files (*.bmp, *.jpg)|*.bmp;*.jpg
        Text Files (*.txt)|*.txt|All Files (*.*)|*.*

.PARAMETER DefaultExt
    Gets or sets the default file name extension applied to files that are saved with the SaveFileDialog.

.OUTPUTS
    Returns the path to the saved file.

.EXAMPLE
    $OpenFile = Select-OpenFileDialog

.EXAMPLE
    $OpenFile = Select-OpenFileDialog -Title "Open Log File" -Filter "Text Files (*.log)|*.log|All Files (*.*)|*.*" 

#>
    param(
        [String] $Title  = $null,
        [string] $Filter = 'All files (*.*)|*.*',
        [switch] $MultiSelect

    )

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = $Title
    $OpenFileDialog.Filter = $Filter
    $OpenFileDialog.Multiselect = $MultiSelect
    if ( $OpenFileDialog.ShowDialog((Get-WindowOwner)) -eq [System.Windows.Forms.DialogResult]::OK )
    {
        $OpenFileDialog.FileName | Write-Output
    }
   
}

function Show-MessageBox
{
<#
 .SYNOPSIS
Display a MessageBox()

.DESCRIPTION
Display a message box with various parameters

.PARAMETER Message
    Body of Messagebox text

.PARAMETER Title
    Caption of Messagebox

.PARAMETER Buttons
    Type of buttons

    0 OK button only 
    1 OK and Cancel buttons 
    2 Abort, Retry, and Ignore buttons 
    3 Yes, No, and Cancel buttons 
    4 Yes and No buttons 
    5 Retry and Cancel buttons 

.PARAMETER Icon
    Type of Icon, one of:

    16 Stop sign 
    32 Question mark 
    48 Exclamation point 
    64 Information (i) icon 

.OUTPUTS
    Returns a [System.Windows.Forms.DialogResult] object, can be one of:

    1 OK 
    2 Cancel 
    3 Abort 
    4 Retry 
    5 Ignore 
    6 Yes 
    7 No 

.EXAMPLE
    Show-MessageBox "Hello World"

.EXAMPLE
    (Show-MessageBox "Do you like Ice Cream?" -Buttons 4) -eq 6

.NOTES
Copyright Keith Garner, All rights reserved.

#>

    Param(
        [parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [String] $Message,
        [String] $Title,
        [ValidateRange(0,5)]
        [int] $Buttons = 0,
        [ValidateRange(16,64)]
        [int] $Icons = 0
    )

    Write-verbose "MessageBox('$Message','$Title')"
    [System.Windows.Forms.MessageBox]::Show((Get-WindowOwner),$Message,$Title,$Buttons,$Icons) | Write-Output
    
}
