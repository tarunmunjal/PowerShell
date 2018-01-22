Function Invoke-LinuxCommands
{
[cmdletbinding()]
    Param(
    [Parameter(Mandatory=$true)]
    $Servers = @(),
    [Parameter(Mandatory=$true)]
    $Commands = @(),
    [Parameter(Mandatory=$false)]
    [int16]$WaitTimeForEachCommand,
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
    Param($server,$commands,$Credentials,$WaitTimeForEachCommand)
    try
    {
        $SSHSession = New-SSHSession -ComputerName $server -Credential $Credentials -AcceptKey -ConnectionTimeout 60
    }
    catch
    {
        Write-Error $_.exception.message
        Throw "Could not establish ssh connection to $server"
    }
    if($SSHSession.connected)
    {
        #[regex]$ExpectedString = "\]\$ $"
        [regex]$ExpectedString = "\][\$\#] $" 
        $ShellStream = New-SSHShellStream -SSHSession $SSHSession 
        foreach($command in $commands)
        {
            $ShellStream.WriteLine($command)
            Write-host "Waiting for expected string"
            if($WaitTimeForEachCommand)
            {
                $timeSpan = New-TimeSpan -Seconds $WaitTimeForEachCommand
                $ShellStream.Expect($ExpectedString,$timeSpan)
            }
            else
            {
                $ShellStream.Expect($ExpectedString)
            }           
            $ShellStream.Read()
        }
        $ShellStream.Dispose()
        Get-SSHSession | Remove-SSHSession
    }
'@
    $Scriptblock = [scriptblock]::Create($CommandBlock)
    $Jobs = @()
    foreach($server in $servers)
    {
        $jobs += Start-Job -Name $server -ScriptBlock $Scriptblock -ArgumentList $server,$commands,$Credentials,$WaitTimeForEachCommand 
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