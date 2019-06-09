function show-allHistory($line=0){
    if($line -eq 0){
        Get-Content (Get-PSReadlineOption).HistorySavePath
    } else {
        Get-Content (Get-PSReadlineOption).HistorySavePath -tail $line
    }
}

function get-sha256(){
    Param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [String[]]
        $file
    )
    return Get-FileHash $file -Algorithm SHA256
}

function get-MD5(){
    Param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [String[]]
        $file
    )
    return Get-FileHash $file -Algorithm MD5
}

function show-version { echo ${PSVersionTable} }

Set-Alias history-all show-allHistory
Set-Alias ver show-version
