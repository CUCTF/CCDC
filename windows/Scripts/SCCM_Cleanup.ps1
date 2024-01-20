#SCCM-Cleanup
#Author: Alvaro Saenz
#Creation Date: 18/July/2019

#This script will do the following actions:
#1.- Get a computer list from a collection in SCCM
#2.- Validate all of the computers inside that collection to see if they exist in AD
#3.- If a computer does not exist in AD it will be deleted in SCCM
#4.- If  computer does exist in AD but is disabled it will write out a warning
#5.- Creates a log with all the transactions

# Log Time Variables
$Date = Get-Date -UFormat %b-%d-%Y
$Hour = (Get-Date).Hour
$Minuntes = (Get-Date).Minute
$Log = "C:\Scripts\SCCM-Cleanup" + $Date + "-" + $Hour + "-" + $Minuntes + ".log"

#Creates a log file for this process
Start-Transcript -Path $Log  -Force

#Type the name of the collection in SCCM that is going to be validated against AD
$Collection = 'MX1 - All systems in SCCM'

#List of computers to be check using the colletion name from SCCM that you specified on the $Collection variable
(Get-CMCollectionMember -CollectionName $Collection).Name | ForEach-Object {

Write-Host "Validating computer $_" -ForegroundColor White

#Validates if the computer exist in Active Directory
$AD_Validation = Try {
(Get-ADComputer -Identity $_ -ErrorAction Stop).Name
$ResultAD = $true }
Catch {
$ResultAD = $False }      
        
#If the computer does not exist in AD it will be removed from SCCM
if($ResultAD -eq $False) {
Write-Warning -Message "Computer $_ not found in AD removing from SCCM"
Remove-CMDevice -DeviceName "$_" -Force -Verbose }

#If the computer does exist then it will check if the computer is enabled in AD
if($ResultAD -eq $true) { 
$Enabled = (Get-ADComputer -Identity $_).Enabled

#If the computer is enabled in AD it will only display a green message
if($Enabled -eq $true) {
Write-Host "Computer $_ exists in AD and its enabled" -ForegroundColor Green }

#If the computer is disabled it will write out a warning and then remove the computer from SCCM
Else {
Write-Warning -Message "Computer $_ exists in AD but is disabled" }
}}

#Passes all the information of the operations made into the log file
Stop-Transcript