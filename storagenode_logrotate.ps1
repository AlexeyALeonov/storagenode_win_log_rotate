$d = Get-Date -Format "yyyy-MM-dd-hh-mm"
$storagenode = @{
    log = "C:\Program Files\Storj\Storage Node\storagenode.log";
    serviceName = "storagenode"
    timeout = 10
}

$storagenode_updater = @{
    log = "C:\Program Files\Storj\Storage Node\storagenode-updater.log";
    serviceName = "storagenode-updater";
    timeout = 5
}

# Compress-Archive have a limit of 2GB, so the threshold could not be greater than that
$threshold = 1GB
$keep_logs = 10

foreach ($service in $storagenode, $storagenode_updater) {
    if ( (Get-Item $service.log).Length -ge $threshold ) {
        Stop-Service $service.serviceName;
        Start-Sleep $service.timeout;
        Compress-Archive -Path $service.log -Destination ($service.log + "-" + $d + ".zip");
        Remove-Item $service.log;
        Start-Service $service.serviceName;
    }

    $list_of_logs = Get-ChildItem -File ($service.log + "*.zip");
    $number_of_logs = $list_of_logs.Count;
    if ( $number_of_logs -gt $keep_logs ) {
        $list_of_logs | Sort-Object -Property LastWriteTime `
            | Select-Object -First ($keep_logs - $number_of_logs) `
            | ForEach-Object{ Remove-Item $_.FullName -Force }
    }
}
