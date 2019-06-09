
function Make-Params($index){
    if($index -eq "dhsoc_threat_ioc"){
        $params=@{}
        $params["index"]="dhsoc_threat_ioc"
        $params["source"]="ioc_json"
        $params["sourcetype"]="threat_ioc_json"
        return $params
    } else{
        Write-Host "don't implement now"
    }
}

function Post-to-Splunk($splunk_host, $pass, $index, $json_file){
    <#
        .EXAMPLE
            Post-to-Splunk -index "dhsoc_threat_ioc" -splunk_host "splunk.proshiba.jp" -pass "password" -json_file testdata.json"
            indexは登録対象のログが持つべきindexです。jsonファイル以外には対応していません。
    #>
    . ${env:PSfactory}\general\rest-util.ps1
    $raw_url="https://${splunk_host}:8089/services/receivers/simple"
    Write-Host $raw_url" is post target"
    $params = Make-Params -index $index
    $cred = Get-BasicCreds -user "fireeye" -pass $pass
    $url = Get-Url -url $raw_url -params $params
    Write-Host $url" is full URL."
    return  Post-JsonFile -url $url -cred $cred -filename $json_file
}
