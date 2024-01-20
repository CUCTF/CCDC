<#	
.SYNOPSIS
	Search for valid certificates in ADCS database.

.DESCRIPTION
	Script searches for valid certificates in specified ADCS database. 
	
	Requirements: Active Directory Certificate Services remote server administration tools.
	
	Sample usage:
		$timeValidX509s = .\Get-Valid-Certificates.ps1 -CAConifgName "server\Corporate CA"
		$timeValidX509s[0]."RawCertificate" contains base64 encoded certificate
		$timeValidX509s[0]."NotAfter" is expiration date of a certificate
		$timeValidX509s[0]."CertificateTemplate" is corresponding certificate template of a certificate
		$timeValidX509s[0]."SerialNumber" is corresponding certificate serial number 
		$timeValidX509s[0]."DistinguishedName" is corresponding certificate distinguished (X.500) name
		$timeValidX509s[0]."DNSSubjectAlternativeNames" DNS name(s) in subject alternative name extension
	
	
.PARAMETER CAConifgName
		
	Default value: none
	Mandatory: Yes
	
.NOTES   
	Author     : Martin Rublik (martin.rublik@gmail.com)
	Created    : 2/3/2015
	Version    : 1.0

	Changelog:
	V 1.0 - alpha version


.EXAMPLE
	.\Get-Valid-Certificates.ps1 -CAConifgName "server\Corporate CA" | fl
	
	displays all valid certificates in Corporate CA database

.EXAMPLE
	.\Get-Valid-Certificates.ps1 -CAConifgName "server\Corporate CA" | Where-Object {$_."CertificateTemplate" -eq "WebServer"} | Select-Object -Property "DistinguishedName","NotAfter","DNSSubjectAlternativeNames" | fl
	
	displays all valid web server certificates in Corporate CA database

#>
[cmdletbinding(ConfirmImpact = 'Low', SupportsShouldProcess=$true)]
param(
		[Parameter(Mandatory=$true)][string]$CAConifgName
)

try
{
	$certs = @()
	$today = get-date -Hour 0 -Minute 0 -Second 0 
	try # Open connection to ADCS database
	{
		$caView = New-Object -Com CertificateAuthority.View.1
		[void]$caView.OpenConnection($CAConifgName)


		$caView.SetResultColumnCount(5)
	
		$col0 = $caView.GetColumnIndex($false, "Binary Certificate")
		$col1 = $caView.GetColumnIndex($false, "Certificate Expiration Date")
		$col2 = $caView.GetColumnIndex($false, "Certificate Template")
		$col3 = $caView.GetColumnIndex($false, "Serial Number")
		$col4 = $caView.GetColumnIndex($false, "Issued Distinguished Name")
		$col0, $col1, $col2, $col3, $col4 | %{ $cAView.SetResultColumn($_)}
	
		$condition0 = $caView.GetColumnIndex($false, "Certificate Expiration Date")        
		$condition1 = $caView.GetColumnIndex($false, "Request Disposition")        
	
	
		# brief disposition code explanation:
		# CVR_SORT_NONE 0
		# CVR_SEEK_EQ	1
		# CVR_SEEK_LT	2
		# CVR_SEEK_GT	16
		
		# Date-of-expiry > $today
		$cAView.SetRestriction($condition0,16,0,$today)
	
		Write-Verbose "Filtering valid certificates, expiry date > $today"

		# brief disposition code explanation:
		# 9 - pending for approval
		# 15 - CA certificate renewal
		# 16 - CA certificate chain
		# 20 - issued certificates
		# 21 - revoked certificates
		# all other - failed requests
		$cAView.SetRestriction($condition1,1,0,20)

		# Dump results
		$rows = $cAView.OpenView()

		while ($rows.Next() -ne -1)
		{            
			try # Process a row
			{
			    $row = New-Object PSObject

				# traverse the columns for this row, fill the PS object
				$columns = $rows.EnumCertViewColumn()
				while($columns.Next() -ne -1)
				{
					$row | Add-Member -MemberType NoteProperty $($columns.GetName()) -Value $($columns.GetValue(1)) -Force
				}

				# try to translate the name
				if (-not ($row.CertificateTemplate -match "^[a-zA-Z0-9]+$"))
				{
					$oid=New-Object System.Security.Cryptography.Oid($row.CertificateTemplate)
					if ($oid.FriendlyName)
					{
						$row.CertificateTemplate = $oid.FriendlyName;
					}
				}
				
				$utf8Encoding = New-Object System.Text.UTF8Encoding
				[byte[]] $byteArray = $utf8Encoding.GetBytes($row."RawCertificate")				
				$x509Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2((,$byteArray))
				$dnsSANs = @();
				
				[System.Security.Cryptography.X509Certificates.X509Extension] $san =  $x509Certificate.Extensions["2.5.29.17"];
				if ($san)
				{
					$nameString=$san.Format($true);
					$names=$nameString.Split("`n",[System.StringSplitOptions]::RemoveEmptyEntries);
					
					$names | ForEach-Object -Process {
						$namePair = $_.Split('=', 2,  [System.StringSplitOptions]::RemoveEmptyEntries);
						if ($namePair.Length -eq 2)
						{
							if ($namePair[0].Trim() -eq "DNS Name")
							{
								# we have DNS SAN
								# print row out
								Write-Verbose "Adding $($namePair[1]) to collection"
								$dnsSANs+=$namePair[1];
							}
						}
					}
				} 
				
				$row | Add-Member -MemberType NoteProperty "DNSSubjectAlternativeNames" -Value $dnsSANs -Force
				$certs+=$row

			}catch
			{
				throw $_.Exception   
			}
		}
		$rows.Reset()
	}catch
	{
		# Log and die
		# We were unable to open view to CA
		throw $_.Exception;
	}
	finally
	{
		$caView = $null
		[GC]::Collect()
	}
	Write-Verbose "Found $($certs.Count) time-valid certificates"
	$certs
}catch
{
	# Log error and die
	throw $_.Exception;
}

