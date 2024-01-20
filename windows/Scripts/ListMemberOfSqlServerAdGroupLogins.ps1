<#
  .SYSNOPSIS
    List Member of Sql Server AD Group Logins

  .DESCRIPTION
    Using AD groups instead of single user account is a good and easy instrument to manage SQL Server security.
    IT deparment can add new users to the AD group to give them predefined permission rights to SQL Server, without
    that IT must have security admin permission in SQL Server itself.
    On the other hand, do you as the DBA know all currently members of all AD groups having acces to SQL Server?
    You could look it up manually, but that's annoying work. You could ad a LinkedServer to ADS to query the
    information. Or you could use this little Powershell script.
    This Powershell script queries all AD groups from SQL server having access rights and list then all members
    of the group from ADS.

  .REMARKS
    Works only with AD groups, not for local groups.
    Works only in a domain enviroment.

  .PARAMETERS
    $server = The name of the SQL Server instance.

  .NOTES
    Author : Olaf Helper
    Version: 1
    Release: 2011-12-21

  .REQUIREMENTS
    PowerShell Version 1.0
#>

# Configuration data
[string] $server   = "ServerName\InstanceName";

Add-Type -AssemblyName  System.DirectoryServices.AccountManagement;
Clear-Host;

# Open ADO.NET Connection with Windows authentification.
$con = New-Object Data.SqlClient.SqlConnection;
$con.ConnectionString = "Data Source=$server;Initial Catalog=master;Integrated Security=True;";
$con.open();

# Select-Statement for AD group logins
$sql = "SELECT [loginname]
        FROM sys.syslogins
        WHERE [isntgroup] = 1
              AND [hasaccess] = 1
			  AND [loginname] <> 'BUILTIN\Administrators'
        ORDER BY [loginname]";

# New command and reader.
$cmd = New-Object Data.SqlClient.SqlCommand $sql, $con;
$rd = $cmd.ExecuteReader();

$ads = [System.DirectoryServices.AccountManagement.ContextType]::Domain;

while ($rd.Read())
{
	[string] $groupName = $rd.GetString(0);
	$group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($ads, $groupName);
	if ($group)
    {
		Write-Host "Members of AD Group: $groupName" -ForegroundColor DarkBlue;
		$group.GetMembers($true) `
		    | Sort-Object UserPrincipalName `
		    | Format-Table -Property UserPrincipalName, DisplayName, EmailAddress -AutoSize;
	}
}

# Close & Dispose all .NET objects.
$rd.Close();
$rd.Dispose();
$cmd.Dispose();
$con.Close();
$con.Dispose();
Write-Host "`nFinished";