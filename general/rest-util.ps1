function Get-BasicCreds([String]$user, [String]$pass) {
    $secure_pwd = ConvertTo-SecureString $pass -AsPlainText -Force
    return New-Object Management.Automation.PSCredential ($user, $secure_pwd)
}

function Get-Url([String]$url, $params ){
    Add-Type -AssemblyName System.Web
    if(!$url.StartsWith("https://")){
        $url="https://"+$url
    }
    $tmp=@()
    foreach($key in $params.Keys){
        $v=$params[$key]
        if($v -And $v.Length -ne 0){
            $enc_v=[System.Web.HttpUtility]::UrlEncode(
                $v,[Text.Encoding]::GetEncoding("utf-8"))
            $tmp += $key+"="+$enc_v
        } else{
            $tmp += $key
        }
    }
    $param_str=$tmp -join "&"
    return $url+"?"+$param_str
}

function Post-JsonFile([String] $url, [PSCredential] $cred, [String] $filename){
    $data=[string] $(Get-Content $filename)
    return Post-Json $url $cred $data
}

function Post-Json([String] $url, [PSCredential] $cred, [String] $data){
    add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    ConvertFrom-Json $data # for testing json structure.
    return Invoke-RestMethod -Uri $url -Method Post -Credential $cred -Body $data -ContentType "application/json"
}
