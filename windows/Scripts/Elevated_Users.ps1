#Script:	Elivated Users.ps1
#Purpose:  Search ActiveDirectory Groups for all elivated users
#Author:   Paperclips	
#Email:	pwd9000@hotmail.co.uk
#Date:     Oct 2013
#Comments: 
#Notes:  

function Get-ElevatedUsers {
    $GroupType = "-2147483643"
    $ElevatedGroups = Get-ADGroup -Filter {grouptype -eq $GroupType} -Properties members
    $Elevatedgroups = $ElevatedGroups | Where-Object {($_.Name -ne 'Guests') -and ($_.Name -ne 'Users')}
    foreach ($ElevatedGroup in $ElevatedGroups) {
        $Members = $ElevatedGroup | Select-Object -ExpandProperty members
        foreach ($Member in $Members) {
            $Status = $true
            try {
                $MemberIsUser = Get-ADUser $Member -ErrorAction silentlycontinue
            } catch { $Status = $false}
            if ($Status -eq $true) {
                $Object = New-Object -TypeName PSObject
                $Object | Add-Member -MemberType noteproperty -Name 'Group' -Value $ElevatedGroup.Name
                $Object | Add-Member -MemberType noteproperty -name 'User' -Value $MemberIsUser.Name
                $Object
            } else {
                $Status = $true
                try {
                    $GroupMembers = Get-ADGroup $Member -ErrorAction silentlycontinue | Get-ADGroupMember -Recursive -ErrorAction silentlycontinue
                } catch { $Status = $false }
                if ($Status -eq $true) {
                    foreach ($GroupMember in $GroupMembers) {
                        $Object = New-Object -TypeName PSObject
                        $Object | Add-Member -MemberType noteproperty -Name 'Group' -Value $ElevatedGroup.Name
                        $Object | Add-Member -MemberType noteproperty -Name 'User' -Value $GroupMember.Name
                        $Object
                    }
                }
            }
        }
    }
}

Get-ElevatedUsers