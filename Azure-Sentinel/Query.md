### Multiple authentication failures followed by a successfully login

```kql
search "<user name>"
| summarize by $table

# 4624 successfull login
# 4624 failed login

SecurityEvent
| where TimeGenerated >= ago(1d)
| where * contains "<user name>"
| where EventID in (4625, 4624)
| summarize by Computer, 

```
