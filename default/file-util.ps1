function is-Directory(){
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [System.IO.FileSystemInfo]
        $tgt
    )
    return $tgt.PSIsContainer
}


function get-PSScriptsName($dir){
    if($dir -is [String] -or $dir -is [String[]]){
        $dir = (dir $dir)
    }
    $results=@()
    foreach( $each in ${dir} ){
        $eachname=$each.FullName
        if($eachname.EndsWith("ps1")){
            $results += $eachname
        }
    }
    return $results
}

function get-tail(){
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        $file,

        [Parameter(Mandatory=$true)]
        $num
    )
    Get-Content $file -Tail $num
}

# by basic function
Set-Alias is-exist test-path

# by custom function
Set-Alias isdir is-Directory
Set-Alias tail get-tail
