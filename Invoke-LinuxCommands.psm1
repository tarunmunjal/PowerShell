Function Invoke-LinuxCommands
{
[cmdletbinding()]
    Param(
    [Parameter(Mandatory=$true)]
    $Servers = @(),
    [Parameter(Mandatory=$true)]
    $Commands = @(),
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.CredentialAttribute()]$Credentials
    )   
    try
    {
        Import-module Posh-ssh -ErrorAction Stop
    }
    catch
    {
        Throw "Unable to import POSH-SSH module. Please make sure the module is installed. Here is a link to the module https://github.com/darkoperator/Posh-SSH"
    }
    $Report = @()
    $CommandBlock = @'
    Param($server,$commands,$Credentials)
    $SSHSession = New-SSHSession -ComputerName $server -Credential $Credentials -AcceptKey -ConnectionTimeout 60
    if($SSHSession.connected)
    {
        [regex]$ExpectedString = "\][$#] $"        
        foreach($command in $commands)
        {
            $ShellStream = New-SSHShellStream -SSHSession $SSHSession 
            $ShellStream.WriteLine($command)
            $ShellStream.Expect($ExpectedString)
            $ShellStream.Read()
            $ShellStream.Dispose()
        }
        $SSHSession.Disconnect()
    }
    
'@
    $Scriptblock = [scriptblock]::Create($CommandBlock)
    $Jobs = @()
    foreach($server in $servers)
    {
        $jobs += Start-Job -Name $server -ScriptBlock $Scriptblock -ArgumentList $server,$commands,$Credentials 
    }
    Get-Job | Wait-Job | Out-Null
    foreach($job in $Jobs)
    {
        $NewReportObject = New-Object psobject -Property @{
            Server = $Job | select -ExpandProperty Name
            Report = $job | Receive-Job
        }
        $Report += $NewReportObject
    }
    Get-Job | Remove-Job
    $Report
}