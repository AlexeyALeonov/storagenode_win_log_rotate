# storagenode_win_log_rotate
Windows GUI storagenode log rotation script (doesn't compatible with logrotate)

Run it in the elevated Powershell:

```
.\storagenode_logrotate.ps1
```

It will zip the log, if it greater than 1GB.
You can configure values in the script for your setup.
