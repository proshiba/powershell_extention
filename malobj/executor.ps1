
function Loop-Exec(){
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("File", "Reg", "Env")]
        $ExecType,
        [Parameter(Mandatory=$true)]
        $SrcObj,
        [Parameter(Mandatory=$true)]
        $DstObj,
        [ValidateRange(1,10)]
        [Int]
        $interval = 2,
        [String]
        $exitFlag = "exit"
    )
    echo $ExecType
}


function exec-file(){
    param(
        [Parameter(Mandatory=$true)]
        $SrcObj,
        [Parameter(Mandatory=$true)]
        $DstObj
    )
    if(Test-Path $SrcObj){
        cat $SrcObj | IEX | sv res
        echo $res
    }
}

function exec-registry(){
}

function exec-env(){
}

