function set-MyEnv {
    $env:PSFactory = Read-Host "Please set Full path of your powershell module"
    if(!(test-path $env:PSFactory)){
        echo "this path is not exist! please set correct path at set-myenv function"
    }
}
if($env:factory -eq $null){
    set-MyEnv
}

function get-PSScriptsName($dir){
  if($dir -is [String]){
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

function get-GeneralLib(){
  return get-PSScriptsName("${env:psfactory}\general")
}

function get-TopLib(){
  return get-PSScriptsName("${env:psfactory}")
}

function get-DefaultLib(){
  return get-PSScriptsName("${env:psfactory}\default")
}
foreach($each in get-DefaultLib){
  . $each
}

function mod-Booter {
  vi "c:\drive\tool\myBat\ps.bat"
}


