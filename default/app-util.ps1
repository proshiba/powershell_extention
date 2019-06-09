function set-editor(){
    if($env:EDITOR -eq $null){
        $global:editor = Read-Host "Please set Full path of your editor"
        if(!(test-path $global:editor)){
            echo "this editor path is not exist! please set correct path at `$editor by yourself"
        }
    } else {
        $global:editor = $env:EDITOR
    }
}

function fox($url=$null) {
    if($url){
        Start-Process "C:\Program Files\Mozilla Firefox\Firefox.exe" -Args $url
    } else {
        Start-Process "C:\Program Files\Mozilla Firefox\Firefox.exe"
    }
}

function start-GVim() {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        $homedir
    )
    Start-Process $editor -Args $homedir
}

function modify-historyfile(){
    start-GVim  (Get-PSReadlineOption).HistorySavePath
}

function modify-Profile{
  start-GVim $PROFILE
}

set-editor

Set-Alias vi start-GVim
Set-Alias mod-history modify-historyfile
Set-Alias mod-pf modify-Profile
