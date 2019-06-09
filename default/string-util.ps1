function encode-To-PsEnc64(){
<#
.SYNOPSIS
encode base64 with Unicode. this encoding using for powershell encodedcommand.

.EXAMPLE
c:\> encode-from-psenc64 get-date
# RwBlAHQALQBkAGEAdABlAA==

.PARAMETER txt
can be used the pipeline at this arg.
decode target.

#>

    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [String[]]
        $txt
    )
    $command = [String] $txt
    $byte = [System.Text.Encoding]::Unicode.GetBytes($command)
    return [System.Convert]::ToBase64String($byte)
}

function decode-From-PsEnc64(){
<#
.SYNOPSIS
decode base64 with Unicode. this encoding using for powershell encodedcommand.

.EXAMPLE
c:\> decode-from-psenc64 ZwBlAHQALQBkAGEAdABlAA==
# get-date

.PARAMETER txt
can be used the pipeline at this arg.
decode target.

#>
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [String[]]
        $txt
    )
    $b64_txt = [String] $txt
    $byte = [System.Convert]::FromBase64String($b64_txt)
    return [System.Text.Encoding]::Unicode.GetString($byte)
}

function grep-string(){
<#
.SYNOPSIS
Like a linux grep function.(but only grep at string)

.EXAMPLE
c:\> echo "test-string" | grep "^test"
# "test-string"

.EXAMPLE
c:\> Get-ChildItem | foreach-object { grep "test" $_ }
# return file(directory) name if it has test in name

.EXAMPLE
c:\> Get-ChildItem | foreach-object { grep "test" $_ -F }
# return file contents has "test"

.PARAMETER txt
can be used the pipeline at this arg.
matching test target

.PARAMETER pt
pattern string for matching(you can use regexp)

.PARAMETER file
if you set this param, matching by file contents

.PARAMETER casesensitive
if you set this param, matching with casesensitive

.PARAMETER exclude
if you set this param, output without matching

#>
    param(
        [Parameter(Mandatory=$true)]
        $pt,

        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        $txt,

        [switch] $file,
        [switch] $exclude,
        [switch] $casesensitive
    )
    if($file.IsPresent){
        if($casesensitive.IsPresent){
            if($exclude.IsPresent){
                return Select-String $pt $txt -CaseSensitive -NotMatch
            } else {
                return Select-String $pt $txt -CaseSensitive
            }
        } else {
            if($exclude.IsPresent){
                return Select-String $pt $txt -NotMatch
            } else {
                return Select-String $pt $txt
            }
        }
    } else {
        if($txt -is [System.IO.FileSystemInfo]){
            $txt = $txt.Name
        }elseif($txt -is [Array]){
        } else {
            $txt = [String] $txt
        }
        if($casesensitive.IsPresent){
            if($exclude.IsPresent){
                if(!($txt -cmatch $pt)){ return $txt }
            } else {
                if($txt -cmatch $pt){ return $txt }
            }
        } else {
            if($exclude.IsPresent){
                if(!($txt -match $pt)){ return $txt }
            } else {
                if($txt -match $pt){ return $txt }
            }
        }
        return $null
    }
}

function split-string(){
<#
.SYNOPSIS
string split to array by delim.

.EXAMPLE
c:\> split-string -delim "-" -txt "test-string"
# ["test", "string"]

.EXAMPLE
c:\> echo "  foo`tbar  " | split-string
# ["  foo", "bar  "]

.EXAMPLE
c:\> echo "  foo,bar  .mof," | split-string -d "[,|.]" -trim
# ["foo", "bar", "mof", ""]

.EXAMPLE
c:\> echo "  foo,bar  .mof," | split-string -d "[,|.]" -trim -ignoreBlank
# ["foo", "bar", "mof"]

.PARAMETER txt
can be used the pipeline at this arg.
split target

.PARAMETER delim
split pattern. this word is delete at return.

.PARAMETER trim
if you set this param, each element's blank at head or tail is trimmed.

.PARAMETER ignoreBlank
if you set this param, delete element if it is blank.

#>
    param(
        [Parameter()]
        [String]
        $delim="`t",

        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [String]
        $txt,

        [switch] $trim,
        [switch] $ignoreBlank
    )
    $result=@()
    $txt -split $delim | ForEach-Object {
        if($trim.IsPresent){
            $each = $_.Trim()
        } else {
            $each = $_
        }
        if($ignoreBlank.IsPresent){
            if(!($each.Length -eq 0)){
                $result += $each
            }
        }
    }
    return $result
}

function cut-string(){
<#
.SYNOPSIS
like a linux cut command.
This function use split-string, and almost work is same of this.

.EXAMPLE
c:\> cut-string -delim "-" -txt "test-string"
# test

.EXAMPLE
c:\> cut-string -delim "-" -txt "test-string" -F 2
# string

.EXAMPLE
c:\> echo "  foo`tbar  " | cut-string
# "  foo"

.EXAMPLE
c:\> echo "  foo,bar  .mof," | cut-string -d "[,|.]" -trim
# foo

.EXAMPLE
c:\> echo "  foo,,,bar  ,.mof," | cut-string -d "[,|.]" -trim -ignoreBlank -F 2
# bar

.PARAMETER txt
can be used the pipeline at this arg.
split target

.PARAMETER delim
split pattern. this word is delete at return.

.PARAMETER F
position of wanted element. it is one-based.
if you want to get the 3rd element, you put the 3 at this args.

.PARAMETER trim
if you set this param, each element's blank at head or tail is trimmed.

.PARAMETER ignoreBlank
if you set this param, delete element if it is blank.

#>
    param(
        [Parameter()]
        [String]
        $delim="`t",

        [Parameter()]
        [int]
        $F=0,

        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        $txt,

        [switch] $ignoreBlank,
        [switch] $trim
    )
    $arg_ignoreblank=""
    $arg_trim=""
    if($ignoreBlank.IsPresent -and $trim.IsPresent){
        $ary = split-string -delim $delim -txt $txt -trim -ignoreBlank
    } elseif($ignoreBlank.IsPresent){
        $ary = split-string -delim $delim -txt $txt -ignoreBlank
    } elseif($trim.IsPresent){
        $ary = split-string -delim $delim -txt $txt -trim
    } else {
        $ary = split-string -delim $delim -txt $txt
    }
    if($f -gt $ary.length){
        return $ary[-1]
    }elseif($f -lt 1){
        return $ary[0]
    }else{
        return $ary[$f-1]
    }
}

function randomize-UpperLowerAtParam(){
<#
.SYNOPSIS
randomizing change Upper/Lower case at all variable.

.EXAMPLE
c:\> randomize-UpperLowerAtParam "$fuga.hoge"
# $fuGa.HoGe"

.PARAMETER txt
can be used the pipeline at this arg.
String object. randomizing change ofcase at all variable name and call function.
#>

    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [String]
        $txt
    )
    $result = ""
    $prev =  $null
    $curr = $null
    $isParam = $false
    $txt.GetEnumerator() | ForEach-Object {
        $curr = $_
        if($isParam){
            if($curr -match "[a-z]"){
                $curr = [String] $curr
                if((Get-Random 2) -eq 0){
                    $curr = $curr.ToLower()
                } else {
                    $curr = $curr.ToUpper()
                }
            } elseif(!($curr -match "[0-9|_|.]")) {
                $isParam = $false
            }
        }elseif($curr -eq "$" -and !($prev -eq "``")){
            $isParam = $true
        }
        $prev = $curr
        $result += $curr
    }
    return $result
}

function reverse-UpperLowerCase(){
<#
.SYNOPSIS
all Upper Case char toLower and Lower Case char toUpper.

.EXAMPLE
c:\> reverse-UpperLowerCase "hoge with -- MOF"
# HOGE WITH -- mof

.EXAMPLE
c:\> echo "fuga--HOGE" | reverse-UpperLowerCase
# FUGA--hoge

.PARAMETER txt
can be used the pipeline at this arg.
String object. rever all case at alphabet.
#>
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [String]
        $txt
    )
    $result = ""
    $txt.GetEnumerator() | ForEach-Object {
        $curr = [String] $_
        if($curr -cmatch "[a-z]"){
            $curr = $curr.ToUpper()
        } elseif($curr -cmatch "[A-Z]"){
            $curr = $curr.ToLower()
        }
        $result += $curr
    }
    return $result
}

function test-ary(){
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        $tgt
    )
    echo $tgt
}

function get-substring(){
<#
.SYNOPSIS
get substring of txt.

.EXAMPLE
c:\> xxxxxx
# yyyyy

.EXAMPLE
c:\> xxxxxx
# yyyyy

.EXAMPLE
c:\> xxxxxx
# yyyyy

.PARAMETER txt
original string. return is substring(or substring set) of this.

.PARAMETER str1
searched string, using by all type(after, between).
if you use between, it is top of substring word.

.PARAMETER str2
using by only Between. it is tail of substring word.

.PARAMETER index
please set the which substring.
0 is 1st string. -1 is last, and default is 0.
if All flag is presented, this parameter is disabled.

.PARAMETER Type
this function has 2 type(After, Between).
After is get the after of str1.
Between is get the string between from str1 to str2.

.PARAMETER All
return all existing substring.

.PARAMETER Trim
Trim str1 and str2 and Blank(include tab or CRLF) top(or tail).
#>
    param(
        [Parameter(Mandatory=$true)]
        [String]
        $txt,
        [Parameter()]
        [String]
        $str1="",
        [Parameter()]
        [String]
        $str2="",
        [Parameter()]
        [int]
        $index=0,
        [ValidateSet("Between" , "After")] $Type="After",
        [switch] $Trim,
        [switch] $All
    )
    $wordlist = @()
    if($All.IsPresent){
        $index = -1
    }
    $target = $txt
    $prev = 0
    for($i=0; $i -ne $index; $i++){
        $s1 = $target.IndexOf($str1)
        $total = $target.Length
        if($s1 -eq -1){
            break
        } else {
            if($Type -eq "Between"){
                $s2 = $target.IndexOf($str2)
                if($s2 -eq -1){
                    break
                } else {
                    $eachlen = $s2+$str2.Length-$s1
                    $eachstr = $target.Substring($s1, $eachlen)
                    $wordlist += $eachstr
                    $next_top = $eachlen+$s1
                    $target = $target.Substring($next_top, $total-$next_top)
                }
            } elseif($Type -eq "After"  ){
                $eachlen = $total-$s1
                $s1len = $str1.Length
                $eachstr = $target.Substring($s1, $eachlen)
                $wordlist += $eachstr
                $target = $target.Substring($s1+$s1len, $eachlen-$s1len)
            }
        }
        if($i -gt $txt.Length){
            break
        }
    }
    if($Trim.IsPresent){
        $result = @()
        foreach($each in $wordlist){
            $eachstr = $each.Trim($str1).Trim($str2).Trim()
            $result += $eachstr
        }
        return $result
    } else {
        return $wordlist
    }
}



# by basic function

# by custom function
Set-Alias enc-ps64 encode-To-PsEnc64
Set-Alias dec-ps64 decode-From-PsEnc64
Set-Alias grep grep-string
Set-Alias split-ex split-string
Set-Alias cut cut-string
