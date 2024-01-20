############################################################################# 
#                                                                           # 
#   This Sample Code is provided for the purpose of illustration only       # 
#   and is not intended to be used in a production environment.  THIS       # 
#   SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT    # 
#   WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT    # 
#   LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS     # 
#   FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, royalty-free    # 
#   right to use and modify the Sample Code and to reproduce and distribute # 
#   the object code form of the Sample Code, provided that You agree:       # 
#   (i) to not use Our name, logo, or trademarks to market Your software    # 
#   product in which the Sample Code is embedded; (ii) to include a valid   # 
#   copyright notice on Your software product in which the Sample Code is   # 
#   embedded; and (iii) to indemnify, hold harmless, and defend Us and      # 
#   Our suppliers from and against any claims or lawsuits, including        # 
#   attorneys' fees, that arise or result from the use or distribution      # 
#   of the Sample Code.                                                     # 
#                                                                           # 
#   Version 1.0         Date Last modified:      16 September 2019          # 
#                                                                           # 
############################################################################# 

<#
.Synopsis
   The script will check for event 4624,4768 and 4769 on the domain controllers and break it down to what Authentication is being used and what type of Kerberos Encryption.

.DESCRIPTION
   The script will check for event 4624,4768 and 4769 on the domain controllers and break it down to what Authentication is being used and what type of Kerberos Encryption. 
   .
.EXAMPLE
    This Example shows how to execute the script with default values
   .\Check-AuthenticationEncryption.ps1

.EXAMPLE
    The following sample will collect information only from the specified domain controller server1.contoso.com
   .\Check-AuthenticationEncryption.ps1 -DomainController server1.contoso.com

.EXAMPLE
  This samle will get events for the last 180 minutes, the default is -60
  .\Check-AuthenticationEncryption.ps1 -last -180
   
.EXAMPLE
  This Example shows how to combine previous collection in the report generation.
  .\Check-AuthenticationEncryption.ps1 -Last -180 -CombineFiles .\Auth-16-09-124254.csv,Auth-16-09-125643.csv


.PARAMETER DomainController
    Overwrite the domain controllers to use, the default is to use all domain controllers in the forest.

.PARAMETER ExcludeDomain
    Exclude a domain controller for the specified domain

.PARAMETER last
 Specify in minutes how far back the logs should be checked. Values should be negative for example, -180 for the last 3 hours.

.PARAMETER CombineFiles
    Combine previous result in the report generation.

.PARAMETER UseAlternatecredentials
   Specify alternate credentials for the execution of the script. You will be prompted to provide credentials

#>

Param([String[]]$DomainController,[string[]]$ExcludeDomain,[int]$Last='-60',[String[]]$CombineFiles,[switch]$UseAlternatecredentials)

$DCs = @()
If ($DomainController -eq '' -or $DomainController -eq $null)
{
$DCs = (get-adforest).domains |?{$_-notin $ExcludeDomain} | %{(Get-ADDomain $_).ReplicaDirectoryServers}
}Else
{
$DCs = $DomainController
}

Function Get-Name
{Param($Value)
Switch ($Value)
{
'0x1' {Return 'DES'}
'0x3' {Return 'DES'}
'0x11' {Return 'AES 128 bit'}
'0x12' {Return 'AES 256 bit'}
'0x17' {Return 'RC4'}
'0x18' {Return 'RC4'}
default {return $Value}
}
}

$cmd = { #Start Remote ScriptBlock

$Result = @()

Foreach ($Event in (Get-EventLog -LogName Security -After (Get-date).AddMinutes($args[0]) | ?{$_.EventID -in @('4624','4768','4769')}))
{
    $obj = @{}

    If ($Event.EventID -eq '4624')
    {
        $Obj.EventID        = '4624'
        $Obj.MachineName    = $Event.MachineName
        $Obj.EntryType      = $Event.EntryType
        $Obj.TimeGenerated  = $Event.TimeGenerated
        $Obj.TimeWritten    = $Event.TimeWritten

        $Message = ($Event.Message -split [char]10)



        if  (($Message[37] -split ':')[-1].trim() -notlike '*The subject fields indicate*' )
        {
            $Obj.AccountName    = ($Message[18] -split ':')[-1].trim()
            $Obj.Address        = $Message[32].trim() 
            $Obj.Authentication = ($Message[37] -split ':')[-1].trim()                      #0x1 & 0x3 = DES | 0x11 AES 128-bit | 0x12 AES 256 bit | 0x17 en 0x18 RC4
        
            $obj.Host           = $Message[31].trim()
            $Result += [PSCustomObject]$obj
        }else
        {
            $Obj.AccountName    = ($Message[14] -split ':')[-1].trim()
            $Obj.Address        = $Message[25].trim() 
            $Obj.Authentication = ($Message[30] -split ':')[-1].trim()                      #0x1 & 0x3 = DES | 0x11 AES 128-bit | 0x12 AES 256 bit | 0x17 en 0x18 RC4
        
            $obj.Host           = $Message[4].trim()
            $Result += [PSCustomObject]$obj
        
        }
        
    }

    If ($Event.EventID -eq '4768')
    {
        $Obj.EventID        = '4768'
        $Obj.MachineName    = $Event.MachineName
        $Obj.EntryType      = $Event.EntryType
        $Obj.TimeGenerated  = $Event.TimeGenerated
        $Obj.TimeWritten    = $Event.TimeWritten

        $Message = ($Event.Message -split [char]10)

        $Obj.AccountName    = $Message[3].trim()
        $Obj.Address        = $Message[12].trim() 
        $Obj.Authentication = ($Message[18] -split ':')[-1].trim()                       #0x1 & 0x3 = DES | 0x11 AES 128-bit | 0x12 AES 256 bit | 0x17 en 0x18 RC4
        $obj.Host           = ''

        if  ($obj.Authentication -notlike '*The subject fields indicate*' )
        {
        $Result += [PSCustomObject]$obj
        }
       
    }

    If ($Event.EventID -eq '4769')
    {
        $Obj.EventID        = '4769'
        $Obj.MachineName    = $Event.MachineName
        $Obj.EntryType      = $Event.EntryType
        $Obj.TimeGenerated  = $Event.TimeGenerated
        $Obj.TimeWritten    = $Event.TimeWritten

        $Message = ($Event.Message -split [char]10)

        $Obj.AccountName    = $Message[3].trim()
        $Obj.Address        = $Message[12].trim() 
        $Obj.Authentication = ($Message[17] -split ':')[-1].trim()              #0x1 & 0x3 = DES | 0x11 AES 128-bit | 0x12 AES 256 bit | 0x17 en 0x18 RC4
        $obj.Host           = ''

        
        if  ($obj.Authentication -notlike '*The subject fields indicate*' )
        {
        $Result += [PSCustomObject]$obj
        }

    }
}
$Result  
    } #End remote ScriptBlock

if ([switch]$UseAlternatecredentials)
{
$credentials = Get-Credential -Message "Please provide Credentials to query domain contoller using remote powershell."
Invoke-Command -ScriptBlock $cmd -ComputerName $DCs -ArgumentList $Last -AsJob -JobName EventCollection -Credential $credentials -ErrorAction SilentlyContinue
}
else
{
Invoke-Command -ScriptBlock $cmd -ComputerName $DCs -ArgumentList $Last -AsJob -JobName EventCollection  -ErrorAction SilentlyContinue
}
Do   {
        cls
        (Get-Job -Name EventCollection -ErrorAction SilentlyContinue ).ChildJobs|?{$_.State -eq 'Running'}
        Write-host "Waiting for task to complete. Will check every 15 seconds." -ForegroundColor Yellow
        Start-sleep 15;
    }   while 
    ((Get-Job -Name EventCollection ).State -eq 'running')

Write-host "All jobs Completed. " -ForegroundColor Green

$Export = @()

Foreach ($Job in (Get-job -Name EventCollection).ChildJobs)
{
    if ($Job.state -Ne 'failed')
    {
    $Export += $job | receive-job -ErrorAction SilentlyContinue | select EventID,MachineName,EntryType,TimeWritten,TimeGenerated,Address,Host,AccountName,Authentication
    }else
    {
    
    $job | receive-job -ErrorAction SilentlyContinue -ErrorVariable Er
    Write-Host "Collection to $($Job.location) failed - With error - $($Er.Errordetails)" -ForegroundColor red 
    }
}
Get-job -Name EventCollection | remove-job

$FileName = ".\$('Auth-')$(Get-date -f dd-MM-hhmmss).csv"
$Export | export-csv -LiteralPath ".\$('Auth-')$(Get-date -f dd-MM-hhmmss).csv" -NoClobber -NoTypeInformation

If ($CombineFiles.count -gt 0)
{
    Foreach ($File in $CombineFiles)
    {
        If (Test-Path $File)
        {
        $Export += Import-Csv $File
        }
    }

}

$Kerberos = $Export |?{$_.EventID -in @('4769','4768') -and $_.Authentication -notlike '*The subject fields indicate*'} | Select @{N='Encryption' ;e={[string](Get-Name -Value $_.Authentication)}} | Group-Object -Property Encryption
$AutTypes = $Export |?{$_.EventID -in @('4624') -and $_.Authentication -notlike '*The subject fields indicate*'}  | Select @{N='AuthType' ;e={[string](Get-Name -Value $_.Authentication)}} | Group-Object -Property AuthType

Function DrawChart
{Param($Data,$Description)
# load the appropriate assemblies 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

# create chart object 
$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 
$Chart.Width = 500 
$Chart.Height = 400 

# create a chartarea to draw on and add to chart 
$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea 
$Chart.ChartAreas.Add($ChartArea)

# add data to chart 


$Tot = $Data | Measure-Object -Property Count -Sum
$EncNames = @(foreach($Enc in $Data){$Enc.Name + " " + [Math]::Round((($Enc.Count/$Tot.Sum)*100), 2) + "%"}) 
$EncCounts = @(foreach($Enc in $Data){$Enc.Count}) 

# set chart type
[void]$Chart.Series.Add("Data") 
$Chart.Series["Data"].Points.DataBindXY($EncNames, $EncCounts)
$Chart.Series["Data"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Pie

# set chart options 
$Chart.Series["Data"]["PieLabelStyle"] = "Outside" 
$Chart.Series["Data"]["PieLineColor"] = "Black" 
$Chart.Series["Data"]["PieDrawingStyle"] = "Concave" 
($Chart.Series["Data"].Points.FindMaxByValue())["Exploded"] = $true

# add title and axes labels 
[void]$Chart.Titles.Add("$Description") 
$ChartArea.Area3DStyle.Enable3D = $true
# Save image
$Chart.SaveImage((Get-location).path + "\$Description.png", "PNG")

}

Try {
DrawChart -Data $Kerberos -Description Kerberos
DrawChart -Data $AutTypes -Description AuthenticationTypes}
Catch {$_}

$Html = @"
<html>
<head>
<Title>Domain Authentication</Title>
<Style>
th {
	font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	color: #FFFFFF;
	border-right: 1px solid #C1DAD7;
	border-bottom: 1px solid #C1DAD7;
	border-top: 1px solid #C1DAD7;
	letter-spacing: 2px;
	text-transform: uppercase;
	text-align: left;
	padding: 6px 6px 6px 12px;
	background: #5F9EA0;
}
td {
	font: 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	border-right: 1px solid #C1DAD7;
	border-bottom: 1px solid #C1DAD7;
	background: #fff;
	padding: 6px 6px 6px 12px;
	color: #6D929B;
}
</Style>
</head>
<body>
<table border=0>
<tr><th>Authentication Types</th><th>Kerberos Encryption</th>
</tr>
<tr>
    <td><img src="AuthenticationTypes.png"></td>
    <td><img src="Kerberos.png"></td>
</tr>
<tr>
    <td><table>$($AutTypes |select @{N='AuthType';e={$_.Name}},Count|%{"<tr><td>$($_.AuthType)</td><td>$($_.Count)</td></tr>"})</table></td>
    <td><table>$($Kerberos |select @{N='Encryption';e={$_.Name}},Count|%{"<tr><td>$($_.Encryption)</td><td>$($_.Count)</td></tr>"})</table></td>
</tr>
</table>
</body>
</html>
"@

 $html |out-file .\report.html