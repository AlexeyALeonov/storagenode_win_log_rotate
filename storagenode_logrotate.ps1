$d = Get-Date -Format "yyyy-MM-dd-hh-mm"
$storagenodes = @(
    @{
        # Path to the log
        log = "X:\storagenode2\storagenode.log";
        # Name of the service
        serviceName = "storagenode2";
        # Timeout to stop the service
        timeout = 300;
        # flag to lets know the script that it's a docker container
        # if missed or $false - assume that it's a usual Windows Service
        docker = $true;
    },
    @{
        log = "C:\Program Files\Storj\Storage Node\storagenode-updater.log";
        serviceName = "storagenode-updater";
        timeout = 5;
    },
    @{
        log = "Y:\storagenode3\storagenode.log";
        serviceName = "storagenode"
        timeout = 10;
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
