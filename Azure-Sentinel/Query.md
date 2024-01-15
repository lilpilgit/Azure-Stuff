### Multiple authentication failures followed by a successfully login

```kql
search "<user name>"
| summarize by $table

// Search for different type of logins:
// 4624 successfull login
// 4625 failed login

SecurityEvent
| where TimeGenerated >= ago(1d)
| where * contains "<user name>"
| where EventID in (4625, 4624)
| summarize by TimeGenerated, Computer, Activity, IpAddress, LogonTypeName, Status, SubStatus
```

Search for type of substatus (of 4625 EventID):
|Status and Sub Status Codes |	Description (not checked against "Failure Reason:") |
| ------------- | ------------- |
|0xC0000064 |	user name does not exist
|0xC000006A	| user name is correct but the password is wrong
|0xC0000234	| user is currently locked out
|0xC0000072	| account is currently disabled
|0xC000006F	| user tried to logon outside his day of week or time of day restrictions
|0xC0000070	| workstation restriction, or Authentication Policy Silo violation (look for event ID 4820 on domain controller)
|0xC0000193	| account expiration
|0xC0000071	| expired password
|0xC0000133	| clocks between DC and other computer too far out of sync
|0xC0000224	| user is required to change password at next logon
|0xC0000225	| evidently a bug in Windows and not a risk
|0xc000015b	| The user has not been granted the requested logon type (aka logon right) at this machine

Search for IP address:

```kql
SecurityEvent
| where TimeGenerated >= ago(1d)
| where * contains "<user name>"
| where EventID in (4625, 4624)
| where IpAddress in ("<ip1>","<ip2>")
| project TimeGenerated, Computer, Activity, IpAddress, LogonTypeName, Status, SubStatus
```

***
***

Ricerca nelle tabelle che non conosco
```kql
search "elemento_da_cercare"
|  summarize count () by $table
```

Controllo login riusciti utente
```kql
SigninLogs
|  where TimeGenerated >= ago(7d)
|  where * contains "admin-gfu"
|  where ResultType ==0
|  project TimeGenerated, IPAddress, ClientAppUsed, AppDisplayName, AuthenticationRequirement, tostring(DeviceDetail.deviceId), tostring(DeviceDetail.displayName)
|  sort by TimeGenerated
```

Controllo login NON interattivi riusciti da un utente
```kql
AADNonInteractiveUserSignInLogs
|  where * contains "utenza"
|  where ResultType ==0
|  summarize by TimeGenerated,AuthenticationRequirement,ResultDescription,IPAddress,tostring(DeviceDetail)
|  sort by TimeGenerated
```
 
Query controllo cambio password utenza
```kql
AuditLogs
|  where TimeGenerated >= ago(7d)
|  where * contains "Nome_utente_da_cercare"
|  summarize by TimeGenerated, OperationName
```

Query Standard PIM
(Da modificare il campo con la dicitura "NOME_UTENTE_DA_CERCARE") 
```kql
union isfuzzy = true (
//Azure Resources Roles
AuditLogs
|  where TimeGenerated >= ago(7d)
|  where ActivityDisplayName ='Add member to role completed (PIM activation)'
|  where Category == "ResourceManagement"
|  extend Role = tostring(TargetResources[0].displayName)
|  extend User = tostring(TargetResources[2].displayName)
|  where User contains "Nome_utente_da_cercare"
|  project TimeGenerated, User, Role, OperationName, Result, Commento = ResultDescription, IPAddress = tostring(AdditinalDetails[7].value), ExpirationTime = tostring(AdditionalDetails[3].value), InitiatedBy= tostring(InitiatedBy.user.displayName)
|  sort by TimeGenerated), 
(
//Azure AD Roles
AuditLogs
|  where TimeGenerated >= ago(360d)
|  where ActivityDisplayName =~ 'Add member to role completed (PIM activation)'
|  where Category == "RoleManagement"
|  extend Role = tostring(TargetResources[0].displayName)
|  extend User = tostring(TargetResources[2].displayName)
|  where User contains "Nome_Utente_da_ricercare"
|  project TimeGenerated, User, Role, OperationName, Result, Commento = ResultDescription, IPAddress = tostring(AdditionalDetails[8].value), ExpirationTime = tostring(AdditionalDetails[4].value), InitiatedBy = tostring(InitiatedBy.user.displayName)
|  sort by TimeGenerated
)
```
	 
Office activities of a user
```kql
OfficeActivity
|  where TimeGenerated >= ago(1d)
|  where * contains "Nome_utente_da_cercare"
|  project TimeGenerated, Operation, UserId, ClientIP, OfficeObjectId, tostring(todynamic(Parameters)[1])
|  sort by TimeGenerated
```

Controlli su utenza, Job role, etc..
```kql
IdentityInfo
|  where * contains "Nome_utente_da_cercare"
```

Colonne per scoprire l'utenza
(Colonne utili a scoprire l'utenza, quando non si hanno dettagli)
	TargetAccount: sembra sia l'account effettivo che richiede il login.
	SubjectAccount: sembra sia il campo che registra il login di un'utenza
	(Siginlogs sono esterni; SecurityEvent interni)
	

Ottenere dettagli in più sulla base delle sole entità presenti nel Sentinel
```kql
SecurityEvent
|  where TimeGenerated >= ago(5d)
|  where EventID == NUMERO
|  where * contains "qualcosa"
```

Ottenere maggiori informazioni su un utenza
```kql
_GetWatchlist('Admin_users')
|  where * contains "admin-da-ricercare"
```

Access tentative to company VPN with an INVALID username.
```kql
CommonSecurityLog 
|  where Activity contains "GLOBALPROTECT" 
|  where isnotempty(SourceUserName) 
|  where TimeGenerated >= ago(5d)
|  where * contains "marco.lanciano"
|  where SourceUserName !contains "unicatt.it" 
|  where * contains "104.28.192.67" or * contains "169.150.196.4" or * contains "193.201.9.99" or * contains "64.145.79.22" or * contains "91.208.127.13" or * contains "91.92.253.112" or * contains "93.123.12.112"
```





