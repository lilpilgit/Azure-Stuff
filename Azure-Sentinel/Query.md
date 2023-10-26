### Multiple authentication failures followed by a successfully login

```
search "Admin-Qlik"
| summarize by $table

SecurityEvent
| where TimeGenerated >= ago(1d)
```
