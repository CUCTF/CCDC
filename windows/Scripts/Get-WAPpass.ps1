Function Get-WAPpass { 
<# 
  .SYNOPSIS 
  Function "Get-WAPpass" to extract Wireless Access Point Names and Passwords from a device. 
 
  .DESCRIPTION 
  Author: Pwd9000 (Pwd9000@hotmail.co.uk) 
  PSVersion: 5.1 
 
  This function will extract all wireless access point profiles stored on a device. 
 
  .EXAMPLE 
  Get-WAPpass

  Will output WiFi name and password in session console.

  .EXAMPLE 
  Get-WAPpass -Export C:\Temp\WAPpass.txt

  Will export WiFi name and password to given file and location e.g: "C:\Temp\WAPpass.txt".

  .PARAMETER Export 
  Specify a filename and path as parameter (optional) <String> 
#> 
 
[CmdletBinding()] 
param( 
    [Parameter(
    Mandatory = $False, 
    ValueFromPipeline = $True, 
    HelpMessage = 'Specify a filename and path to export the WiFi data captured to a file e.g. "C:\Temp\WAPpass.txt"')] 
    [string]$Export 
) 

$WiFi = netsh wlan show profiles | Select-String "\:(.+)$" | 
        Foreach-Object {
            $name=$_.Matches.Groups[1].Value.Trim(); $_
            } | 
        ForEach-Object { 
            (netsh wlan show profile name="$name" key=clear)
            }  | Select-String "Key Content\W+\:(.+)$" | 
        ForEach-Object { 
            $pass=$_.Matches.Groups[1].Value.Trim(); $_
            } | 
        ForEach-Object { 
            [PSCustomObject]@{ WiFi_Name=$name; Password=$pass }
            } | 
        Format-Table -AutoSize

Write-Output "Wireless access point data captured from [$env:COMPUTERNAME]"
Write-Output "-----------------------------------------------------------"
$WiFi

If ($Export) {
    Write-Output "Wireless access point data captured from [$env:COMPUTERNAME]" | out-file -FilePath "$Export"
    Write-Output "-------------------------------------------------------" | out-file -FilePath "$Export" -Append
    $WiFi | out-file -FilePath "$Export" -Append
    Write-Output "Wireless access point data exported to file: [$Export]"
    }
}