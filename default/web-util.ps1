function get-webstring(){
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [String[]]
        $url
    )
    $tgt_url = [String] $url
    $wc = New-Object System.Net.WebClient
    return $wc.downloadstring($tgt_url)
}
function download-webfile(){
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [String[]]
        $url,
        [Parameter(Mandatory=$true)]
        [String[]]
        $name
    )
    $wc = New-Object net.webclient
    $wc.DownloadFile($url, $name)
}

function get-CommandOfEnableTls2(){
    return '[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12'
}

Set-Alias webstr get-webstring
