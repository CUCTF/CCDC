# Script:	DAG_Health.ps1
# Purpose:  This script can be set as a scheduled task to run every 2hours and will check the health of an Excahneg 2010 DAG
# Email:	pwd9000@hotmail.co.uk
# Date:     oct 2011
# Comments: The script will mail the intended parties to notify if a DAG copy is not where it should be including the DB name, 
#			server its on and the server it should be on.
# Notes:    
#			- tested with Exchange 2010 SP3 (Latest RU)
#			- Also does SITE failover checks

$s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ExchangeServer1.contoso.local/PowerShell/ -Authentication Kerberos
Import-PSSession $s -AllowClobber

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
. $env:ExchangeInstallPath\bin\RemoteExchange.ps1
Connect-ExchangeServer ExchangeServer1.contoso.local

Function sendEmail ([String] $body)
{
	$MailMessage = New-Object System.Net.Mail.MailMessage
	$MailMessage.From = "Exch2010DAG@contoso.local"
	$MailMessage.To.Add("User1@contoso.local")
	$MailMessage.To.Add("User2@contoso.local")
	$MailMessage.To.Add("User3@contoso.local")
	$MailMessage.Subject = "A DAG was detected as not Healthy! - Check database locations!"
	$MailMessage.Body = $body
	$MailMessage.Priority = "High"

	$SMTPClient = New-Object System.Net.Mail.SMTPClient
	$SMTPClient.Host = "192.168.2.2"
	$SMTPClient.Send($MailMessage)
}

Function getExchangeServerADSite ([String] $excServer)
{
	$configNC=([ADSI]"LDAP://RootDse").configurationNamingContext
	$search = new-object DirectoryServices.DirectorySearcher([ADSI]"LDAP://$configNC")
	$search.Filter = "(&(objectClass=msExchExchangeServer)(name=$excServer))"
	$search.PageSize = 4000
	[Void] $search.PropertiesToLoad.Add("msExchServerSite")

	Try {
		$adSite = [String] ($search.FindOne()).Properties.Item("msExchServerSite")
		Return ($adSite.Split(",")[0]).Substring(3)
	} Catch {
		Return $null
	}
}

[Bool] $bolFailover = $False
[String] $errMessage = $null

Get-MailboxDatabase | Sort Name | ForEach {
	$db = $_.Name
	$curServer = $_.Server.Name
	$ownServer = $_.ActivationPreference | ? {$_.Value -eq 1}

	# Compare the server where the DB is currently active to the server where it should be
	If ($curServer -ne $ownServer.Key)
	{
		# Compare the AD sites of both servers
		$siteCur = getExchangeServerADSite $curServer
		$siteOwn = getExchangeServerADSite $ownServer.Key
		
		If ($siteCur -ne $null -and $siteOwn -ne $null -and $siteCur -ne $siteOwn)
		{
			$errMessage += "`n$db on $curServer should be on $($ownServer.Key) (DIFFERENT AD SITE: $siteCur)!"	
		}
		Else
		{
			$errMessage += "`n$db on $curServer should be on $($ownServer.Key)!"
		}

		$bolFailover = $True
	}
}

$errMessage += "`n`n"

Get-MailboxServer | Get-MailboxDatabaseCopyStatus | ForEach {
	If ($_.Status -notmatch "Mounted" -and $_.Status -notmatch "Healthy" -or $_.ContentIndexState -notmatch "Healthy")
	{
		$errMessage += "`n$($_.Name) - Status: $($_.Status) - Index: $($_.ContentIndexState)"
		$bolFailover = $True
	}
}

If ($bolFailover)
{
	sendEmail $errMessage
}