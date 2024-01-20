Option Explicit 
 
Const HKEY_CURRENT_USER  = &H80000001 
Const HKEY_LOCAL_MACHINE  = &H80000002 
 
Dim StrComputer, ObjNetwork, ObjReg, StrFileName 
Dim ColOS, ObjOS, ESCStatus, Counter, WriteHandle 
Dim StrKeyPath, ArrSubKeys, SubKey, ObjFSO, SubKey2, ArrSubKeys2
 
Set ObjNetwork = CreateObject("WScript.Network") 
StrComputer = Trim(ObjNetwork.ComputerName) 
Set ObjNetwork = Nothing 

On Error Resume Next
 
WScript.Echo:	CheckIE_ESC

WScript.Echo "All Currently Trusted Sites in Internet Explorer" 
WScript.Echo "=================================================" 
WScript.Echo vbNullString
If ESCStatus = True Then
	WScript.Echo vbTab & "IE Enhanced Security Is Turned ON"
Else
	WScript.Echo vbTab & "IE Enhanced Security Is Turned OFF"
End If
WScript.Echo:	WScript.Echo vbTab & "Checking. Please wait ..."

Set ObjFSO = CreateObject("Scripting.FileSystemObject")
StrFileName = Trim(ObjFSO.GetFile(WScript.ScriptFullName).ParentFolder)
If ObjFSO.FileExists(StrFileName & "\IETrustedSiteList.txt") = True Then
	ObjFSO.DeleteFile StrFileName & "\IETrustedSiteList.txt", True
End If
Set WriteHandle = ObjFSO.OpenTextFile(StrFileName & "\IETrustedSiteList.txt", 8, True, 0)
WriteHandle.WriteLine "===============================================================================================" 
WriteHandle.WriteLine "All Currently Trusted Sites in Internet Explorer"
WriteHandle.WriteLine "Reported As On -- " & FormatDateTime(Date, 1) & " At " & FormatDateTime(Now(), 3) 
WriteHandle.WriteLine "===============================================================================================" 
WriteHandle.WriteLine:	WriteHandle.WriteLine:	Counter = 0

WriteHandle.WriteLine "List of All Current User's Trusted Sites In Internet Explorer" 
WriteHandle.WriteLine "----------------------------------------------------------------------------"

On Error Resume Next

	Set ObjReg=GetObject("WinMgmts:{ImpersonationLevel=Impersonate}!\\" & StrComputer & "\Root\Default:StdRegProv")
	StrKeyPath = "Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains"  
	ObjReg.EnumKey HKEY_CURRENT_USER, StrKeyPath, ArrSubKeys 
	For Each Subkey In ArrSubKeys 
		If Trim(Subkey) <> vbNullString Then
			Counter = Counter + 1 
			WriteHandle.WriteLine vbTab & "Current User IE ESC: " & Counter & " -- " & Trim(Subkey)

			ObjReg.EnumKey HKEY_CURRENT_USER, StrKeyPath & "\" & Trim(SubKey), ArrSubKeys2
			For Each SubKey2 In ArrSubKeys2
				If Trim(SubKey2) <> vbNullString Then
					WriteHandle.WriteLine vbTab & vbTab & "Subsite -- " & Trim(Subkey2)
				End If
			Next
		End If
	Next:	Counter = 0
	StrKeyPath = "Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"  
	ObjReg.EnumKey HKEY_CURRENT_USER, StrKeyPath, ArrSubKeys 
	For Each Subkey In ArrSubKeys
		If Trim(Subkey) <> vbNullString Then
			Counter = Counter + 1 
			WriteHandle.WriteLine vbTab & Counter & " -- " & Trim(Subkey)

			ObjReg.EnumKey HKEY_CURRENT_USER, StrKeyPath & "\" & Trim(SubKey), ArrSubKeys2
			For Each SubKey2 In ArrSubKeys2
				If Trim(SubKey2) <> vbNullString Then
					WriteHandle.WriteLine vbTab & vbTab & "Subsite -- " & Trim(Subkey2)
				End If
			Next

		End If
	Next
WriteHandle.WriteLine: 	Counter = 0
	StrKeyPath = "Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains"  
	ObjReg.EnumKey HKEY_LOCAL_MACHINE, StrKeyPath, ArrSubKeys 
	For Each Subkey In ArrSubKeys
		If Trim(Subkey) <> vbNullString Then
			Counter = Counter + 1
			WriteHandle.WriteLine vbTab & "Local Machine IE ESC: " & Counter & " -- " & Trim(Subkey)
			
			ObjReg.EnumKey HKEY_CURRENT_USER, StrKeyPath & "\" & Trim(SubKey), ArrSubKeys2
			For Each SubKey2 In ArrSubKeys2
				If Trim(SubKey2) <> vbNullString Then
					WriteHandle.WriteLine vbTab & vbTab & "Subsite -- " & Trim(Subkey2)
				End If
			Next

		End If
	Next:	Counter = 0
	StrKeyPath = "Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"  
	ObjReg.EnumKey HKEY_LOCAL_MACHINE, StrKeyPath, ArrSubKeys 
	For Each Subkey In ArrSubKeys
		If Trim(Subkey) <> vbNullString Then
			Counter = Counter + 1 
			WriteHandle.WriteLine vbTab & Counter & " -- " & Trim(Subkey)

			ObjReg.EnumKey HKEY_CURRENT_USER, StrKeyPath & "\" & Trim(SubKey), ArrSubKeys2
			For Each SubKey2 In ArrSubKeys2
				If Trim(SubKey2) <> vbNullString Then
					WriteHandle.WriteLine vbTab & vbTab & "Subsite -- " & Trim(Subkey2)
				End If
			Next

		End If
	Next
WriteHandle.WriteLine:	WriteHandle.WriteLine:	Counter = 0
WriteHandle.WriteLine "List of All Trusted Sites In Internet Explorer Applied Via Group Policy" 
WriteHandle.WriteLine "----------------------------------------------------------------------------"

	StrKeyPath = "SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap"
	ObjReg.EnumKey HKEY_LOCAL_MACHINE, StrKeyPath, ArrSubKeys 
	For Each Subkey In ArrSubKeys
		If Trim(Subkey) <> vbNullString Then
			Counter = Counter + 1 
			WriteHandle.WriteLine vbTab & Counter & " -- " & Trim(Subkey)

			ObjReg.EnumKey HKEY_CURRENT_USER, StrKeyPath & "\" & Trim(SubKey), ArrSubKeys2
			For Each SubKey2 In ArrSubKeys2
				If Trim(SubKey2) <> vbNullString Then
					WriteHandle.WriteLine vbTab & vbTab & "Subsite -- " & Trim(Subkey2)
				End If
			Next

		End If
	Next
WriteHandle.WriteLine:	WriteHandle.WriteLine:	Counter = 0
	StrKeyPath = "SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey"
	ObjReg.EnumKey HKEY_CURRENT_USER, StrKeyPath, ArrSubKeys 
	For Each Subkey In ArrSubKeys
		If Trim(Subkey) <> vbNullString Then
			Counter = Counter + 1 
			WriteHandle.WriteLine vbTab & Counter & " -- " & Trim(Subkey)

			ObjReg.EnumKey HKEY_CURRENT_USER, StrKeyPath & "\" & Trim(SubKey), ArrSubKeys2
			For Each SubKey2 In ArrSubKeys2
				If Trim(SubKey2) <> vbNullString Then
					WriteHandle.WriteLine vbTab & vbTab & "Subsite -- " & Trim(Subkey2)
				End If
			Next

		End If
	Next
	StrKeyPath = "SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap"
	ObjReg.EnumKey HKEY_CURRENT_USER, StrKeyPath, ArrSubKeys 
	For Each Subkey In ArrSubKeys
		If Trim(Subkey) <> vbNullString Then
			Counter = Counter + 1 
			WriteHandle.WriteLine vbTab & Counter & " -- " & Trim(Subkey)

			ObjReg.EnumKey HKEY_CURRENT_USER, StrKeyPath & "\" & Trim(SubKey), ArrSubKeys2
			For Each SubKey2 In ArrSubKeys2
				If Trim(SubKey2) <> vbNullString Then
					WriteHandle.WriteLine vbTab & vbTab & "Subsite -- " & Trim(Subkey2)
				End If
			Next

		End If
	Next
	StrKeyPath = "SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey"
	ObjReg.EnumKey HKEY_LOCAL_MACHINE, StrKeyPath, ArrSubKeys 
	For Each Subkey In ArrSubKeys
		If Trim(Subkey) <> vbNullString Then
			Counter = Counter + 1 
			WriteHandle.WriteLine vbTab & Counter & " -- " & Trim(Subkey)

			ObjReg.EnumKey HKEY_CURRENT_USER, StrKeyPath & "\" & Trim(SubKey), ArrSubKeys2
			For Each SubKey2 In ArrSubKeys2
				If Trim(SubKey2) <> vbNullString Then
					WriteHandle.WriteLine vbTab & vbTab & "Subsite -- " & Trim(Subkey2)
				End If
			Next

		End If
	Next
	
WriteHandle.Close:	Set WriteHandle = Nothing
Set ObjFSO = Nothing:	Set ObjReg = Nothing
WScript.Echo
WScript.Echo "Checks Completed. Check The Report File: "
WScript.Echo StrFileName & "\IETrustedSiteList.txt"
StrFileName = vbNullString:	WScript.Quit

' ================================================================================================================
 
Private Sub CheckIE_ESC 
    Dim GetHardenVal 
    Set ObjReg = GetObject("WinMgmts:" & "{ImpersonationLevel=Impersonate}\\" & StrComputer & "\Root\Default:StdRegProv") 
    StrKeyPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" 
    ObjReg.GetDWORDValue HKEY_CURRENT_USER,StrKeyPath,"IEHarden",GetHardenVal 
    If Err.Number <> 0 Then 
        Err.Clear:    ESCStatus = False 
    End If 
    If GetHardenVal = 1 And Err.Number = 0 Then 
        ' -- IE ESC is Set To ON For the current user." 
        ESCStatus = True 
    Else 
        ' -- IE ESC is set to OFF For the current user." 
        ESCStatus = False     
    End If 
    Set ObjReg = Nothing:    StrKeyPath = vbNullString 
End Sub