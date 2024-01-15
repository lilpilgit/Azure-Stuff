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

### Search for IP address

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

### Searching the tables I don't know
```kql
search "elemento_da_cercare"
|  summarize count () by $table
```
***
***

### Successful user login check
```kql
SigninLogs
|  where TimeGenerated >= ago(7d)
|  where * contains "admin-gfu"
|  where ResultType ==0
|  project TimeGenerated, IPAddress, ClientAppUsed, AppDisplayName, AuthenticationRequirement, tostring(DeviceDetail.deviceId), tostring(DeviceDetail.displayName)
|  sort by TimeGenerated
```
***
***

### Checking NON-interactive logins succeeded by a user
```kql
AADNonInteractiveUserSignInLogs
|  where * contains "utenza"
|  where ResultType ==0
|  summarize by TimeGenerated,AuthenticationRequirement,ResultDescription,IPAddress,tostring(DeviceDetail)
|  sort by TimeGenerated
```
***
***

### Checking attempts to change a user's password
```kql
AuditLogs
|  where TimeGenerated >= ago(7d)
|  where * contains "Nome_utente_da_cercare"
|  summarize by TimeGenerated, OperationName
```
***
***

### Azure PIM Alert
_(To be changed to the field labeled "User_name_to_seek") _
```kql
union isfuzzy = true (
//Azure Resources Roles
AuditLogs
|  where TimeGenerated >= ago(7d)
|  where ActivityDisplayName ='Add member to role completed (PIM activation)'
|  where Category == "ResourceManagement"
|  extend Role = tostring(TargetResources[0].displayName)
|  extend User = tostring(TargetResources[2].displayName)
|  where User contains "User_name_to_seek"
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
***
***
	 
### Office activities of a user
```kql
OfficeActivity
|  where TimeGenerated >= ago(1d)
|  where * contains "Nome_utente_da_cercare"
|  project TimeGenerated, Operation, UserId, ClientIP, OfficeObjectId, tostring(todynamic(Parameters)[1])
|  sort by TimeGenerated
```
***
***
### User controls, Job role, etc.
```kql
IdentityInfo
|  where * contains "Nome_utente_da_cercare"
```

⚠️Columns for discovering users
_Useful columns for discovering the user, when you don't have details_
- TargetAccount: seems to be the actual account that requires login.
- SubjectAccount: appears to be the field that records a user's login.
- Signinlogs are external; SecurityEvents are internal

***
***

### Getting extra details based only on the entities in the Sentinel
```kql
SecurityEvent
|  where TimeGenerated >= ago(5d)
|  where EventID == NUMERO
|  where * contains "qualcosa"
```
***
***
### Getting more information about a user
```kql
_GetWatchlist('Admin_users')
|  where * contains "admin-da-ricercare"
```
***
***
### Access tentative to company VPN with an INVALID username.
```kql
CommonSecurityLog 
|  where Activity contains "GLOBALPROTECT" 
|  where isnotempty(SourceUserName) 
|  where TimeGenerated >= ago(5d)
|  where * contains "marco.lanciano"
|  where SourceUserName !contains "unicatt.it" 
|  where * contains "104.28.192.67" or * contains "169.150.196.4" or * contains "193.201.9.99" or * contains "64.145.79.22" or * contains "91.208.127.13" or * contains "91.92.253.112" or * contains "93.123.12.112"
```





