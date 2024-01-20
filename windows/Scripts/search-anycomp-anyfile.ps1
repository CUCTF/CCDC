#$computers  = Get-ADComputer -filter * | %{$_.Name} 
$computers = Get-Content C:\Temp\comp.txt
write-output "Starting scan of all Computers in EU " > c:\temp\scan.txt
write-output "=====================================" >> c:\temp\scan.txt
Write-output "" >> c:\temp\scan.txt
foreach($computer in $Computers){
	write-output $computer >> c:\temp\scan.txt
	Get-WMIObject CIM_DataFile -filter "FileName='proxy-settings-cc'" -computer $computer >> c:\temp\scan.txt
  }
Write-output "" >> c:\temp\scan.txt