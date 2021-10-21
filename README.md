# storagenode_win_log_rotate
Windows GUI storagenode log rotation script (does not compatible with logrotate)

## Allow PowerShell scripts execution
In the elevated PowerShell
```
Set-ExecutionPolicy RemoteSigned
```
If it would be not enought, then
```
Set-ExecutionPolicy Unrestricted
```

## Usage
Run it in the elevated Powershell:

```
.\storagenode_logrotate.ps1
```

It will zip the log, if it greater than 1GB.
You can configure values in the script for your setup.
