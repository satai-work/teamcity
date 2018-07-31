# Enter your own credential to mount HA cluster domain share
$password = "PASSWORD!!!" | ConvertTo-SecureString -asPlainText -Force
$username = "USER!!!" 

function coalesce($a, $b) { if ($a -ne $null) { $a } else { $b } }

function remove_last_dir ($a) {
    $a = $a.split('\') 
    $a = $a[0..($a.Length-2)]
    [string]::join('\',$a)  
}

$cred = New-Object System.Management.Automation.PSCredential($username,$password)
New-PSDrive -name P -psprovider "filesystem" -root "\\nsk-clu-fs-tst\share" -credential $cred

[System.IO.Directory]::Delete($env:TEAMCITY_LOGS,$true)
[System.IO.Directory]::Delete($env:TEAMCITY_DATA_PATH,$true)

$dest = remove_last_dir $env:TEAMCITY_LOGS
New-item -ItemType SymbolicLink -Path $dest -Name Logs -Target P:\teamcity\logs

$dest = remove_last_dir $env:TEAMCITY_DATA_PATH
New-item -ItemType SymbolicLink -Path $dest -Name TeamCity -Target P:\teamcity\data

Write-Host @"

 Welcome to TeamCity Server Docker container

 * Installation directory: $Env:TEAMCITY_DIST
 * Logs directory:         $Env:TEAMCITY_LOGS
 * Data directory:         $Env:TEAMCITY_DATA_PATH

"@

# Setting default values if variables not present
$TEAMCITY_DIST = coalesce $Env:TEAMCITY_DIST 'C:\TeamCity'
$TEAMCITY_CONTEXT = coalesce $Env:TEAMCITY_CONTEXT 'ROOT'
$TEAMCITY_STOP_WAIT_TIME = coalesce $Env:TEAMCITY_STOP_WAIT_TIME 60
$TEAMCITY_SERVER_SCRIPT = ('{0}\bin\teamcity-server.bat' -f $TEAMCITY_DIST)
$Env:TEAMCITY_LOGS = coalesce $Env:TEAMCITY_LOGS ('{0}\logs' -f $TEAMCITY_DIST)

if (Test-Path -Path $Env:TEAMCITY_LOGS) {
    Get-ChildItem $Env:TEAMCITY_LOGS -Filter "*.pid" | ForEach-Object { Remove-Item $_.FullName -Force }
}

if ($TEAMCITY_CONTEXT -ne 'ROOT') {
    $current = Get-ChildItem ('{0}\webapps' -f $TEAMCITY_DIST) -Depth 0 -Name
    if ($current -ne $TEAMCITY_CONTEXT) {
        $currentPath = ('{0}\webapps\{1}' -f $TEAMCITY_DIST, $current)
        $destinationPath = ('{0}\webapps\{1}' -f $TEAMCITY_DIST, $TEAMCITY_CONTEXT)
        Move-Item -Path $currentPath -Destination $destinationPath
    }
}

# Set traps to gently shutdown server on `docker stop`, `docker restart` or `docker kill -s 15`
Trap {
    &$TEAMCITY_SERVER_SCRIPT stop $TEAMCITY_STOP_WAIT_TIME -force
    exit $LastExitCode
}

# Start and wait for exit
&$TEAMCITY_SERVER_SCRIPT run
exit $LastExitCode
