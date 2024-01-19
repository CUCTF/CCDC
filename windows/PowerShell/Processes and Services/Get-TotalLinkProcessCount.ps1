﻿<# 
.SYNOPSIS
    Gets a count of files that have a link between a process and a data file. This indicates that the file participates in the execution of the process.

#>

write-host "Input the path the file containing names\IPs or input a single IP" -ForegroundColor Cyan
$computers = read-host " "

$current_user = [Environment]::UserName  
$newline = "`r`n" 

foreach($cpu in $computers)
    {
    $ProcExes = Get-WmiObject -Namespace root\cimv2 -Class CIM_ProcessExecutable -ComputerName $cpu
    $combined += $cpu + '+' + $ProcExes.Count + $newline
    }

Add-content -Path "c:\users\$current_user\desktop\total_exe.txt" -Value ($combined)  
    
Import-csv "c:\users\$current_user\desktop\total_exe.txt" -Delimiter '+' -Header 'System', 'Count' | export-csv c:\users\$current_user\desktop\Total_Link_Process_Count.csv

remove-item "c:\users\$current_user\desktop\total_exe.txt"
Remove-Variable combined, ProcExes