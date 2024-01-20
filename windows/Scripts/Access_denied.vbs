' Script:	Access_Denied.vbs
' Purpose:  This script will only allow access to specified user defined on line 20
' Author:   Paperclips
' Email:	Pwd9000@hotmail.co.uk
' Date:     Jul 2015
' Comments: Script will look at user logging on and if it does not match specific user then commit shutdown
' Notes:    
'			- Script must be added to this folder 'c:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp

'Get Current logged on User
'--------------------------
On Error Resume Next
Set wshNetwork = CreateObject("WScript.Network")
	strUser = wshNetwork.Username

'Kick if not match
'------------------

If strUser <> "username" Then
	Set Shell = CreateObject("Wscript.Shell") 
	Shell.Run "shutdown -l -f"     	 
End If 