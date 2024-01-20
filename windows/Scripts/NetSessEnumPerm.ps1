################################################################################################
# NetSessEnumPerm.ps1
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
<#-------------------------------------------------------------------------------
!! Version 1.0
17 October, 2016


-------------------------------------------------------------------------------#> 

Param
(
    # Param 1 remote computer name
    [Parameter(Mandatory=$false, 
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true, 
                ValueFromRemainingArguments=$false, 
                Position=0,
                ParameterSetName='Parms')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [String] 
    $Computer="",
    # Param 2 Show UI
    [Parameter(Mandatory=$false, 
                ValueFromPipeline=$false,
                ValueFromPipelineByPropertyName=$false, 
                ValueFromRemainingArguments=$false, 
                Position=1,
                ParameterSetName='Parms')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [Switch] 
    $Gui)

begin
{

$pshost = get-host

$pswindow = $pshost.ui.rawui


$newsize = $pswindow.buffersize

$newsize.height = 3000

$newsize.width = 190

$pswindow.buffersize = $newsize



#Load Presentation Framework
Add-Type -Assembly PresentationFramework

$global:dicWellKnownSids = @{"S-1-0"="Null Authority";`
"S-1-0-0"="Nobody";`
"S-1-1"="World Authority";`
"S-1-1-0"="Everyone";`
"S-1-2"="Local Authority";`
"S-1-2-0"="Local ";`
"S-1-2-1"="Console Logon ";`
"S-1-3"="Creator Authority";`
"S-1-3-0"="Creator Owner";`
"S-1-3-1"="Creator Group";`
"S-1-3-2"="Creator Owner Server";`
"S-1-3-3"="Creator Group Server";`
"S-1-3-4"="Owner Rights";`
"S-1-4"="Non-unique Authority";`
"S-1-5"="NT Authority";`
"S-1-5-1"="Dialup";`
"S-1-5-2"="Network";`
"S-1-5-3"="Batch";`
"S-1-5-4"="Interactive";`
"S-1-5-6"="Service";`
"S-1-5-7"="Anonymous";`
"S-1-5-8"="Proxy";`
"S-1-5-9"="Enterprise Domain Controllers";`
"S-1-5-10"="Principal Self";`
"S-1-5-11"="Authenticated Users";`
"S-1-5-12"="Restricted Code";`
"S-1-5-13"="Terminal Server Users";`
"S-1-5-14"="Remote Interactive Logon";`
"S-1-5-15"="This Organization";`
"S-1-5-17"="IUSR";`
"S-1-5-18"="Local System";`
"S-1-5-19"="NT Authority";`
"S-1-5-20"="NT Authority";`
"S-1-5-22"="ENTERPRISE READ-ONLY DOMAIN CONTROLLERS BETA";`
"S-1-5-32-544"="Administrators";`
"S-1-5-32-545"="Users";`
"S-1-5-32-546"="Guests";`
"S-1-5-32-547"="Power Users";`
"S-1-5-32-548"="BUILTIN\Account Operators";`
"S-1-5-32-549"="Server Operators";`
"S-1-5-32-550"="Print Operators";`
"S-1-5-32-551"="Backup Operators";`
"S-1-5-32-552"="Replicator";`
"S-1-5-32-554"="BUILTIN\Pre-Windows 2000 Compatible Access";`
"S-1-5-32-555"="BUILTIN\Remote Desktop Users";`
"S-1-5-32-556"="BUILTIN\Network Configuration Operators";`
"S-1-5-32-557"="BUILTIN\Incoming Forest Trust Builders";`
"S-1-5-32-558"="BUILTIN\Performance Monitor Users";`
"S-1-5-32-559"="BUILTIN\Performance Log Users";`
"S-1-5-32-560"="BUILTIN\Windows Authorization Access Group";`
"S-1-5-32-561"="BUILTIN\Terminal Server License Servers";`
"S-1-5-32-562"="BUILTIN\Distributed COM Users";`
"S-1-5-32-568"="BUILTIN\IIS_IUSRS";`
"S-1-5-32-569"="BUILTIN\Cryptographic Operators";`
"S-1-5-32-573"="BUILTIN\Event Log Readers ";`
"S-1-5-32-574"="BUILTIN\Certificate Service DCOM Access";`
"S-1-5-32-575"="BUILTIN\RDS Remote Access Servers";`
"S-1-5-32-576"="BUILTIN\RDS Endpoint Servers";`
"S-1-5-32-577"="BUILTIN\RDS Management Servers";`
"S-1-5-32-578"="BUILTIN\Hyper-V Administrators";`
"S-1-5-32-579"="BUILTIN\Access Control Assistance Operators";`
"S-1-5-32-580"="BUILTIN\Remote Management Users";`
"S-1-5-33"="Write Restricted Code";`
"S-1-5-64-10"="NTLM Authentication";`
"S-1-5-64-14"="SChannel Authentication";`
"S-1-5-64-21"="Digest Authentication";`
"S-1-5-65-1"="This Organization Certificate";`
"S-1-5-80"="NT Service";`
"S-1-5-84-0-0-0-0-0"="User Mode Drivers";`
"S-1-5-113"="Local Account";`
"S-1-5-114"="Local Account And Member Of Administrators Group";`
"S-1-5-1000"="Other Organization";`
"S-1-15-2-1"="All App Packages";`
"S-1-16-0"="Untrusted Mandatory Level";`
"S-1-16-4096"="Low Mandatory Level";`
"S-1-16-8192"="Medium Mandatory Level";`
"S-1-16-8448"="Medium Plus Mandatory Level";`
"S-1-16-12288"="High Mandatory Level";`
"S-1-16-16384"="System Mandatory Level";`
"S-1-16-20480"="Protected Process Mandatory Level";`
"S-1-16-28672"="Secure Process Mandatory Level";`
"S-1-18-1"="Authentication Authority Asserted Identityl";`
"S-1-18-2"="Service Asserted Identity"}
#==========================================================================
# Function		: ConvertTo-ObjectArrayListFromPsCustomObject  
# Arguments     : Defined Object
# Returns   	: Custom Object List
# Description   : Convert a defined object to a custom, this will help you  if you got a read-only object 
# 
#==========================================================================
function ConvertTo-ObjectArrayListFromPsCustomObject 
{ 
     param ( 
         [Parameter(  
             Position = 0,   
             Mandatory = $true,   
             ValueFromPipeline = $true,  
             ValueFromPipelineByPropertyName = $true  
         )] $psCustomObject
     ); 
     
     process {
 
        $myCustomArray = New-Object System.Collections.ArrayList
     
         foreach ($myPsObject in $psCustomObject) { 
             $hashTable = @{}; 
             $myPsObject | Get-Member -MemberType *Property | ForEach-Object { 
                 $hashTable.($_.name) = $myPsObject.($_.name); 
             } 
             $Newobject = new-object psobject -Property  $hashTable
             [void]$myCustomArray.add($Newobject)
         } 
         return $myCustomArray
     } 
 } 

[xml]$xamll =@"
<Window x:Class="WpfApplication1.NetSessEnumPerm"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication1"

        Title="Default Net Session Info ACLs"  WindowStartupLocation="CenterScreen" Height="250" Width="820" ResizeMode="CanResizeWithGrip" WindowState="Normal" >
    <Grid Background="black">
        <StackPanel Orientation="Vertical" >
        <Label x:Name="lbl1" Margin="2,0,0,0"  Content="Net Session Enumeration Permissions:" FontWeight="Normal" Width="700" Height="35" FontSize="20"  HorizontalAlignment="LEft" Foreground="#FFFFFF"/>
        <DataGrid Name="dg_Log" Margin="2,0,0,0" Width="790" HorizontalAlignment="Center" >
          <DataGrid.Columns>
            <DataGridTextColumn Header="Host" Binding="{Binding Host}" Width="SizeToCells" />            
            <DataGridTextColumn Header="Object" Binding="{Binding Object}" Width="SizeToCells" />
            <DataGridTextColumn Header="IdentityReference" Binding="{Binding IdentityReference}" Width="SizeToCells" />
            <DataGridTextColumn Header="Rights" Binding="{Binding FSRights}" Width="SizeToCells" />
          </DataGrid.Columns>
        </DataGrid>
        <Button x:Name="btnExit" Content="Exit" HorizontalAlignment="Center" Margin="0,0,0,0" VerticalAlignment="Top" Width="75"/>
        </StackPanel>
    </Grid>
</Window>
"@


$xamll.Window.RemoveAttribute("x:Class")  
  
$reader=(New-Object System.Xml.XmlNodeReader $xamll)
$Window=[Windows.Markup.XamlReader]::Load( $reader )
$btnExit = $Window.FindName("btnExit")
$dg_Log = $Window.FindName("dg_Log")

#### Varaibles ######
$global:bolConnectToReg = $false
$KeyRoot = "SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\DefaultSecurity"
$Key = "SrvsvcSessionInfo"
####################

if($Computer -eq "")
{
    $Reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey("LocalMachine","Default")
    $global:bolConnectToReg =  $true
    $Computer = "Local"
}
else
{
    Try
    {
        $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $computer)
        $global:bolConnectToReg = $true
    }
    catch
    {
        $_.Exception
        $global:bolConnectToReg = $false
    }
}
#If connected to a registry continue else quit
if($global:bolConnectToReg -eq $false)
{
    break
}
}
Process
{



$RegKey= $Reg.OpenSubKey($KeyRoot)
$RegData = $RegKey.GetValue($Key)

$sec = New-Object System.Security.AccessControl.FileSecurity
$sec.SetSecurityDescriptorBinaryForm($RegData)
$defSD = $sec.GetAccessRules($true, $false, [System.Security.Principal.NTAccount])  

$FSSecurity = (ConvertTo-ObjectArrayListFromPsCustomObject  $defSD)
$i= 0
Foreach ($id in $FSSecurity)
{
    #Translate Sids of WellKnown groups
    if($id.IdentityReference -match "s-1-5")
    {
	    If ($dicWellKnownSids.ContainsKey($id.IdentityReference.value))
	    {
		    $FSSecurity[$i].IdentityReference = $dicWellKnownSids.Item($id.IdentityReference.value)
	    }
    
    }
    #Add Object name property
    Add-Member -InputObject $FSSecurity[$i] Host $Computer
    #Add Object name property
    Add-Member -InputObject $FSSecurity[$i] Object $Key
    $i++

}
Foreach ($ACE in $FSSecurity)
{
    $row= New-Object PSObject
    Add-Member -inputObject $row -memberType NoteProperty -name "Host" -value $ACE.Host
    Add-Member -inputObject $row -memberType NoteProperty -name "Object" -value $ACE.Object
    Add-Member -inputObject $row -memberType NoteProperty -name "IdentityReference" -value $ACE.IdentityReference
    Add-Member -inputObject $row -memberType NoteProperty -name "FSRights" -value $ACE.FileSystemRights
    $dg_Log.AddChild($row)
}


$btnExit.add_Click( 
{
    $Window.close()
})
}
End
{
if($Gui)
{
    $Window.ShowDialog() | Out-Null
}
else
{
    Write-Host "`nNet Session Enumeration Permissions:" -ForegroundColor Yellow -NoNewline
    $FSSecurity | Select-Object -Property Host,Object,IdentityReference,FileSystemRights 
}

}
