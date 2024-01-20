<#----------------------------------------------------------------------------
LEGAL DISCLAIMER 
This Sample Code is provided for the purpose of illustration only and is not 
intended to be used in a production environment.  THIS SAMPLE CODE AND ANY 
RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER 
EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF 
MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a 
nonexclusive, royalty-free right to use and modify the Sample Code and to 
reproduce and distribute the object code form of the Sample Code, provided 
that You agree: (i) to not use Our name, logo, or trademarks to market Your 
software product in which the Sample Code is embedded; (ii) to include a valid 
copyright notice on Your software product in which the Sample Code is embedded; 
and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and 
against any claims or lawsuits, including attorneys’ fees, that arise or result 
from the use or distribution of the Sample Code. 
  
This posting is provided "AS IS" with no warranties, and confers no rights. Use 
of included script samples are subject to the terms specified 
at http://www.microsoft.com/info/cpyright.htm. 

Written by Moti Bani - mobani@microsoft.com - (http://blogs.technet.com/b/motiba/) 
#>
Function Get-WindowsClientFeatures {
    <#
    .SYNOPSIS
    Executes a PowerShell ScriptBlock on a target Windows client using DISM and return the output.
    
    .PARAMETER ComputerName
    Runs the command on the specified computer, the default is the local computer.

    .EXAMPLE
    Get-WindowsClientFeatures -ComputerName WS01.Contoso.com  
    
    #>
    [CmdletBinding()]
    param (    
        [Parameter( Mandatory = $True )]
        [String]
        $ComputerName=$env:COMPUTERNAME
    )
    
    $subject = Invoke-Command -ScriptBlock {&dism /online /Get-Features} -ComputerName $ComputerName
    #concatenate the strings
    $text = [System.String]::Join("`r`n", $subject)
    $regex = [regex] @'
(?im)Feature Name : (.*)
State : (.*)
'@

    $cache = @()    
    $match = $regex.Match($text)
    while ($match.Success) {
        $pso = New-Object -TypeName psobject -Prop @{'Feature'=$match.Groups[1].Value.Trim();
                                       'State'=$match.Groups[2].Value.Trim();
                                       'ComputerName'=$ComputerName}
        
        $cache += $pso
        $match = $match.NextMatch()
    }

    $cache    
}