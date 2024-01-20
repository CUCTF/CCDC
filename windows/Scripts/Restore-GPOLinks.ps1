param( [string]$GPOID, [parameter(Mandatory=$false)] [string]$GPLinkCSVFile ,[switch]$All,[switch]$help )
$ScriptName = $MyInvocation.InvocationName.Split("\")[-1]
function funHelp()
{
clear
$helpText=@"
################################################################################################
# $ScriptName
# 
# AUTHOR: Robin Granberg (robin.granberg@microsoft.com)
#
# THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
# FITNESS FOR A PARTICULAR PURPOSE.
#
# This sample is not supported under any Microsoft standard support program or service. 
# The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
# implied warranties including, without limitation, any implied warranties of merchantability
# or of fitness for a particular purpose. The entire risk arising out of the use or performance
# of the sample and documentation remains with you. In no event shall Microsoft, its authors,
# or anyone else involved in the creation, production, or delivery of the script be liable for 
# any damages whatsoever (including, without limitation, damages for loss of business profits, 
# business interruption, loss of business information, or other pecuniary loss) arising out of 
# the use of or inability to use the sample or documentation, even if Microsoft has been advised 
# of the possibility of such damages.
################################################################################################
DESCRIPTION:
NAME: $ScriptName
Restore Group Policy links from CSV file including link order, Enabled status and Enforce status.

To create such CSV file use Backup-GPOLinks.ps1.

INFO: This script will not update existing links only create new links if it's missing!


PARAMETERS:

-GPLinkCSVFile  GPO Link CSV file (Required).
-GPOID          Restore specific GPO by GPO ID.
-All            Restore all links in file.
-help           Prints the HelpFile (Optional).

SYNTAX:

Example 1:

.\$ScriptName  -GPLinkCSVFile C:\GPOBackup\GPOLinkBackup.csv -All

This command will restore all GPO Links including link order, Enabled status and Enforce status.

Example 2:

.\$ScriptName  -GPLinkCSVFile C:\GPOBackup\GPOLinkBackup.csv -GPOID 25bc527d-0351-40a2-b4d6-0b70c0357af1 

This command will restore all GPO Links for one specified GPO including link order, Enabled status and Enforce status.

Example 3:

.\$ScriptName -help

Displays the help topic for the script


"@
write-host $helpText -foregroundcolor white
exit
}

if ($help) {
	funHelp

}
if (($All) -and ($GPOID)) {funHelp} 
if ((!($GPLinkCSVFile) -or !($GPOID)) -and (!($GPLinkCSVFile) -or !($All))) {funHelp}
if (($GPLinkCSVFile -eq "")) {funHelp}
$ErrorActionPreference = "SilentlyContinue"
If((!$All))
{
    &{#Try
    $strReslt = [guid]$GPOID
    }
    Trap [SystemException]
    {
        Write-host "Inccorect value! This is not a correct GUID string:$GPOID "
        Exit
    }
}
$CurrentFSPath = split-path -parent $MyInvocation.MyCommand.Path
if($GPLinkCSVFile.Split("\").Count -gt 1)
{
    if($GPLinkCSVFile.Remove(2,$GPLinkCSVFile.Length -2) -eq ".\")
    {
    $GPLinkCSVFile = "$CurrentFSPath$($GPLinkCSVFile.Remove(0,1))"
    }
}
If(!(Test-Path $GPLinkCSVFile)){Write-host "Could not locate the CSV file:$GPLinkCSVFile" ;Exit}
$GPLinkCSVImport = ""
$GPLinkCSVImport = Import-Csv -Path $GPLinkCSVFile | Sort-Object -Property Order
$colHeaders = ( $GPLinkCSVImport | Get-member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name')
If(!($colHeaders.Contains("DisplayName") -and $colHeaders.Contains("GpoId")  -and $colHeaders.Contains("Enabled")  -and $colHeaders.Contains("Enforced") -and $colHeaders.Contains("Target") -and $colHeaders.Contains("GpoDomainName")))
{
    "The CSV file is in the wrong format!"
    Exit
}

$arrLinks = ""
if($All)
{
    $arrLinks = $GPLinkCSVImport| where{$_.gpoID -like "*"} 
}
else
{
    $arrLinks = Import-Csv -Path $GPLinkCSVFile | where{$_.gpoID -eq "$GPOID"}
}

# Check for GroupPolicy powershell module
if ($(Get-Module -name GroupPolicy -ListAvailable) -eq $null)
{
    Write-host "This script requires the GroupPolicy Powershell module to be available" -ForegroundColor Red
    Exit
}
else
{
    if ($(Get-Module -name GroupPolicy) -eq $null)
    {
        #Load ActiveDirectory Module
        Import-Module -Name GroupPolicy
        Write-host  "GroupPolicy Powershell module imported" 
    }

}

ForEach($Link in $arrLinks)
{
    if($Link.Enabled -eq "True"){$strLinkEnabled = "Yes"}else{$strLinkEnabled = "No"}

    if($Link.Enforced -eq "True"){$strEnforced = "Yes"}else{$strEnforced = "No"}

    &{#Try
        
        New-GPlink -Guid $Link.GPOID -Target $Link.Target -Order $Link.Order -Enforced $strEnforced -LinkEnabled $strLinkEnabled -ErrorAction Stop
    }
    Trap [SystemException]
    {

        if($_ -like "Value does not fall within the expected range.")
        {
            write-host "Could not restore link order due to missing links for the GPO named '$($Link.DisplayName)' with Link Order $($Link.Order)." -ForegroundColor Red
        
	        Write-Host "Do you want to link GPO without correct link order?" -ForegroundColor Yellow
	        $a = Read-Host "Do you want to continue? Press Y[Yes] or N[NO]:"
	        If (!($a -eq "Y"))
	        {
		    
	        }   
            Else
            {     
                &{#Try
        
                    New-GPlink -Guid $Link.GPOID -Target $Link.Target  -Enforced $strEnforced -LinkEnabled $strLinkEnabled -ErrorAction Stop
                }
                Trap [SystemException]
                {
                    Write-host $_ -ForegroundColor Red
            
                }
            }
        }
        else
        {
         Write-host $_ -ForegroundColor Red
        }
    }

}

