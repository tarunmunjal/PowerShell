Function Invoke-LinuxCommands
{
[cmdletbinding()]
    Param(
    [Parameter(Mandatory=$true)]
    $Servers = @(),
    [Parameter(Mandatory=$true)]
    $Commands = @(),
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.CredentialAttribute()]$Credentials,
    [Parameter(Mandatory=$false)]
    [switch]$UseStream,
    [Parameter(Mandatory=$false)]
    $CommandTimeOut = 120
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
    $StreamBlock = @'
    Param($server,$commands,$Credentials,$CommandTimeOut)
    $SSHSession = New-SSHSession -ComputerName $server -Credential $Credentials -AcceptKey -ConnectionTimeout 60
    if($SSHSession.connected)
    {
        #[regex]$ExpectedString = "\]\$ $"
        [regex]$ExpectedString = "\][\$\#] $" 
        $ShellStream = New-SSHShellStream -SSHSession $SSHSession 
        foreach($command in $commands)
        {
            $timeSpan = New-TimeSpan -Seconds $CommandTimeOut
            $ShellStream.WriteLine($command)
            $ShellStream.Expect($ExpectedString,$timeSpan)
            $ShellStream.Read()
        }
        $ShellStream.Dispose()
        Get-SSHSession | Remove-SSHSession
    }
    else
    {
        Write-Output "Unable to connect to $server"
        Throw "Unable to connect to $server"
    }  
'@
    $InvokeBlock = @'
    Param($server,$commands,$Credentials,$CommandTimeOut)
    $SSHSession = New-SSHSession -ComputerName $server -Credential $Credentials -AcceptKey -ConnectionTimeout 60
    if($SSHSession.connected)
    {
        $CommandOutput = @()
        foreach($command in $commands)
        {
            $CommandOutput += Invoke-SSHCommand -Command $command -SSHSession $SSHSession -TimeOut $CommandTimeOut
        }
        Get-SSHSession | Remove-SSHSession
    }
    else
    {
        $CommandOutput = New-Object -TypeName psobject -Property @{output = "Unable to connect to $server"}
        $CommandOutput
        Throw "Unable to connect to $server"
    }
    $CommandOutput
'@
    
    if($UseStream.IsPresent)
    {
        $CommandBlock = $StreamBlock
    }
    else
    {
        $CommandBlock = $InvokeBlock
    }
    $SudoCheck = $Commands | ?{$_ -match "sudo"}
    if($SudoCheck)
    {
        if(!($UseStream.IsPresent))
        {
            Write-Warning "one or more of your command(s) contains a sudo. This will not work without stream."
        }
    }
    $Scriptblock = [scriptblock]::Create($CommandBlock)
    $Jobs = @()
    
    foreach($server in $servers)
    {
        $Jobs += Start-Job -Name $server -ScriptBlock $Scriptblock -ArgumentList $server,$commands,$Credentials,$CommandTimeOut
    }
    Get-Job | Wait-Job | Out-Null
    foreach($Job in $Jobs)
    {
        if($UseStream.IsPresent)
        {
            $Report += $Job | select @{N='Server';E={$_.Name}},@{N='Report';E={$Job | Receive-job}}
        }
        else
        {
            $Report += $Job | select @{N='Server';E={$_.Name}},@{N='Report';E={($Job | Receive-job).output}}
        }
    }
    Get-Job | Remove-Job
    $Report
}