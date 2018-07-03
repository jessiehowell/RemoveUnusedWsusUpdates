$scriptDir = Split-Path -parent $PSCommandPath
$count = $args[0]

$sqlBin = "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn"
$sqlServer = "\\.\pipe\MICROSOFT##WID\tsql\query"
$sqlDatabase = "SUSDB"
$sqlGetQuery = "exec dbo.spGetObsoleteUpdatesToCleanup"
$sqlDelQuery = "exec spDeleteUpdate @localUpdateID=" 

cd $sqlBin

$updates = & sqlcmd -S $sqlServer -d $sqlDatabase -Q $sqlGetQuery

if (!$count) {
    $count = ($updates.length - 1)
}

Write-Host "$($updates.Length) updates to remove."

foreach ($update in $updates[0..$count]) {
    $intRef = $null
    if ([int]::TryParse($update.Trim(), [ref]$intRef)) {
		$out = & sqlcmd -S $sqlServer -d $sqlDatabase -Q $sqlDelQuery$update
        if ($out) {
            Write-Host "$($updates.IndexOf($update)): $out"
        }
        else {
            Write-Host "$($updates.IndexOf($update)): success" 
	}
    }
}

<#
#Remove Last Update only
$intRef = $null
$lastUpdate = $updates[$updates.length-1].Trim()
if ([int]::TryParse($lastUpdate, [ref]$intRef)) {
    $out = & sqlcmd -S $sqlServer -d $sqlDatabase -Q $sqlDelQuery$lastUpdate
    Write-Host "SQL Result: $out"
}
#>

cd $scriptDir

