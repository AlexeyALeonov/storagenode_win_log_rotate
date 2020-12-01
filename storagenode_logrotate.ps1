$d = Get-Date -Format "yyyy-MM-dd-hh-mm"
$storagenodes = @(
    @{
        log = "X:\storagenode3\node.log";
        serviceName = "storagenode";
        timeout = 10;
    },
    @{
        log = "X:\storagenode3\storagenode-updater.log";
        serviceName = "storagenode-updater";
        timeout = 5;
    },
    @{
        log = "Y:\storagenode2\storagenode.log";
        serviceName = "storagenode2"
        timeout = 300;
        docker = $true;
    },
    @{
        log = "w:\storagenode5\storagenode.log";
        serviceName = "storagenode5";
        timeout = 300;
        docker = $true;
    }
)

# Compress-Archive have a limit of 2GB, so the threshold could not be greater than that
$threshold = 1GB
$keep_logs = 10

foreach ($service in $storagenodes) {
    if ( (Get-Item $service.log).Length -ge $threshold ) {
        if ($service.docker) {
            docker stop -t $service.timeout $service.serviceName
        } else {
            Stop-Service $service.serviceName;
            Start-Sleep $service.timeout;
        }
        Compress-Archive -Path $service.log -Destination ($service.log + "-" + $d + ".zip");
        Remove-Item $service.log;
        if ($service.docker) {
            docker start $service.serviceName
        } else {
            Start-Service $service.serviceName;
        }
    }

    $list_of_logs = Get-ChildItem -File ($service.log + "*.zip");
    $number_of_logs = $list_of_logs.Count;
    if ( $number_of_logs -gt $keep_logs ) {
        $list_of_logs | Sort-Object -Property LastWriteTime `
            | Select-Object -First ($keep_logs - $number_of_logs) `
            | ForEach-Object{ Remove-Item $_.FullName -Force }
    }
}
