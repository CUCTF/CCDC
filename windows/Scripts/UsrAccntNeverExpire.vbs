' =================================================================================================================================
' List All User-Accounts in The Domain Whose Password is Set To Never Expire
' Usage: CScript UsrAccntNeverExpire.vbs > Result.txt

' LDAP Filters -- http://social.technet.microsoft.com/wiki/contents/articles/5392.active-directory-ldap-syntax-filters.aspx
' =================================================================================================================================

Option Explicit

Dim StrSQL, ObjConn, ObjRS
Dim Counter, ObjRootDSE, StrDomName

On Error Resume Next

Set ObjRootDSE = GetObject("LDAP://RootDSE")
StrDomName = Trim(ObjRootDSE.Get("DefaultNamingContext"))
Set ObjRootDSE = Nothing
StrSQL = "<LDAP://" & StrDomName & ">;(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=65536));SAMAccountName,UserPrincipalName;Subtree"
Set ObjConn = CreateObject("ADODB.Connection")
ObjConn.Provider = "ADsDSOObject":	ObjConn.Open "Active Directory Provider"
Set ObjRS = CreateObject("ADODB.Recordset")
ObjRS.Open StrSQL, ObjConn
ObjRS.MoveLast:	ObjRS.MoveFirst
WScript.Echo "Total No of User Accounts: " & ObjRS.RecordCount
WScript.Echo "====================================" & VbCrLf
While Not ObjRS.EOF
	WScript.Echo Trim(ObjRS.Fields("SAMAccountName").Value) & vbTab & " --> " & Trim(ObjRS.Fields("UserPrincipalName").Value)
	Counter = Counter + 1
	ObjRS.MoveNext
Wend
ObjRS.Close:	Set ObjRS = Nothing
ObjConn.Close:	Set ObjConn = Nothing
WScript.Echo vbNullString
WScript.Echo "Total No of User Accounts: " & Counter
WScript.Echo "===================================="
WScript.Quit