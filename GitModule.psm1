﻿Function Invoke-CloneRepository
{
[cmdletbinding()]
Param(
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
    $RepositoryUrl,
    [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$False)]
    $Folder
    )
    Begin
    {
        $foldernotempty = $False
        if(Test-path -Path $Folder)
        {
            if(Get-ChildItem -Path $Folder -Recurse)
            {
                Write-Host "Please specify a folder that is empty."
            }
        }
    }
    Process
    {
        if( -not $foldernotempty)
        {
            $GitCloneOutput = Git clone "$RepositoryUrl" "$Folder" -v 2>&1
        }
        $GitCloneOutput -split '\n' | Out-Host
    }
    End
    {
    }
}
Function Add-RemoteUrls
{
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [String]$url,
        [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$false,
        HelpMessage="This value will be used to identify the url. Commonly used values are E.g. {'Origin' for your personal repo and 'Upstream' for the repo you forked.}"
        )]
        [String]$AliasForRemote
    )
    Begin
    {
        if($url -notmatch ".git$")
        {
            Write-Host "A git repository url ends with '.git'. Please check url and try again."
            return
        }
        if(-not $AliasForRemote)
        {
            Write-Host "Sorry remotes cannot be added without the associated identifying name."
        }
    }
    Process
    {
        $GitRemoteCommand = Git remote add $AliasForRemote $url 2>&1
    }
    End
    {
        if($GitRemoteCommand)
        {
            ($GitRemoteCommand -split '[\r\n]') | Out-Host   
        }
    }
}

Function Invoke-CloneSingleBranch
{
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
    $RepositoryUrl,
    [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true)]
    $BranchToClone,
    [Parameter(Mandatory=$true,Position=2,ValueFromPipeline=$False)]
    $Folder
    Begin{
        if(-not $Folder)
        {
            Write-Host "Folder name was not specified. The branch will be cloned in folder: $BranchToClone"
        }
    
    }
    Processs
    {
        $GitCloneSingleBranchOutput = Git clone $RepositoryUrl --branch $BranchToClone $Folder
    }
    end
    {
        if($GitCloneSingleBranchOutput)
        {
            ($GitCloneSingleBranchOutput -split ('\n')) | Out-Host
        }
    }
}

Function New-GitBranch
{   
    [cmdletbinding()]
    Param(
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
    [string]$NewBranchName,
    [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$false)]
    [string]$Folder,
    [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$false)]
    [array]$RepoAliases
    )
    Begin
    {
        $GitCreateBranchOutput = @()
        if($folder -and (Test-Path $Folder ))
        {
            Set-Location -Path $Folder -ErrorAction Stop
        }
        else
        {
            Write-Host "Path doesn't exist. To create a new branch a git repository path must be specified."
            Write-Host "If running a git remote returns existing repo aliases the script will try to create a branch and push it to thoses Aliases"
        }
        if(-not $RepoAliases)
        {
            $RepoAliasesFromGit = git remote -v 2>&1
            $RepoAliasesFromGit | %{
                $RepoAliases += ($_ -split '\t' | select -First 1)
            }
        }
        $RepoAliases = $RepoAliases | select -Unique
        if(-not $NewBranchName)
        {
            Write-Error "A branch name must be specified."
            Return
        }

    }
    Process
    {
        if($NewBranchName)
        {
            $GitCreateBranchOutput += Git checkout -b $NewBranchName 2>&1
            if($RepoAliases)
            {
                foreach($RepoAlias in $RepoAliases)
                {
                    $RepoAlias
                    $GitCreateBranchOutput += CMD /C "Git push $RepoAlias $NewBranchName 2>&1"
                }
            }
            else
            {
                Write-host "Unable to find remotes in the current direcotry".
                return;
            }

        }
    }
    end
    {
        if($GitCreateBranchOutput)
        {
            ($GitCreateBranchOutput -split ('\n')) | Out-Host
        }
    }
}

Function Get-PullRequests
{
    Param(
    $Credentials,
    $Username,
    $repo,
    $Url
    )
    $CreateHeaders = @{}
    if(-not $token)
    {
        if(-not $Credentials -or -not $Global:Credentials)
        {
            $Credentials = Get-Credential
        }
        $EncodedCredntials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($Credentials.UserName):$($Credentials.GetNetworkCredential().Password)")) 
        $CreateHeaders.add('Authorization',"Basic $EncodedCredntials")
    }
    $CreateHeaders.Add('Content-Type','Application/Json')
    if(!$url)
    {
        $PullRequestQueryUrl = "https://api.github.com/repos/$username/$repo/pulls"
    }
    $PullRequestResult = Invoke-RestMethod -Method Get -Uri $PullRequestQueryUrl -Headers $CreateHeaders
    return $PullRequestResult
}

Function Create-NewPullRequest
{
    Param(
    $Credentials,
    $Username,
    $repo,
    $Url,
    $TitleMessage,
    $BodyMessage,
    $SourceBranch,
    $DestinationBranch
    )
    $CreateHeaders = @{}
    if(-not $token)
    {
        if(-not $Credentials -or -not $Global:Credentials)
        {
            $Credentials = Get-Credential
        }
        $EncodedCredntials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($Credentials.UserName):$($Credentials.GetNetworkCredential().Password)")) 
        $CreateHeaders.add('Authorization',"Basic $EncodedCredntials")
    }
    $CreateHeaders.Add('Content-Type','Application/Json')
    if(!$url)
    {
        $PullRequestQueryUrl = "https://api.github.com/repos/$username/$repo/pulls"
    }
    $PullRequestBodyHashTable = @{}
    $PullRequestBodyHashTable.add('head',$SourceBranch)
    $PullRequestBodyHashTable.add('base',$DestinationBranch)
    $PullRequestBodyHashTable.add('title',$TitleMessage)
    if($BodyMessage)
    {
        $PullRequestBodyHashTable.add('body',$BodyMessage)
    }
    $PullRequestBodyJson = $PullRequestBodyHashTable | ConvertTo-Json
    $PullRequestResponse = Invoke-RestMethod -Method Put -Uri $PullRequestQueryUrl -Headers $CreateHeaders -Body $PullRequestBodyJson
    return $PullRequestResponse
}

Function Invoke-MergePullRequest
{
    Param(
    $Credentials,
    $Username,
    $repo,
    $Url,
    $PullNumber,
    $PullSha,
    $CommitTitle,
    $CommitMessage,
    $MergeMethod
    )
    $CreateHeaders = @{}
    if(-not $token)
    {
        if(-not $Credentials -or -not $Global:Credentials)
        {
            $Credentials = Get-Credential
        }
        $EncodedCredntials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($Credentials.UserName):$($Credentials.GetNetworkCredential().Password)")) 
        $CreateHeaders.add('Authorization',"Basic $EncodedCredntials")
    }
    $CreateHeaders.Add('Content-Type','Application/Json')
    if(!$url)
    {
        $PullRequestQueryUrl = "https://api.github.com/repos/$username/$repo/pulls/$PullNumber/merge"
    }
    $MergeParameters = @{}
    if($CommitTitle)
    {
        $MergeParameters.Add('commit_Title',$CommitTitle)
    }
    if($CommitMessage)
    {
        $MergeParameters.Add('commit_message',$CommitMessage)
    }
    #Sha of pull request of head.     
    $MergeParameters.Add('sha',$PullSha)
    if($MergeMethod)
    {
        $MergeParameters.Add('merge_method',$MergeMethod)
    }
    $PullRequestBodyJson = $PullRequestBodyHashTable | ConvertTo-Json
    $PullRequestResponse = Invoke-RestMethod -Method Post -Uri $PullRequestQueryUrl -Headers $CreateHeaders -Body $PullRequestBodyJson
    return $PullRequestResponse
}


Function Create-GitCommandAlias
{
    ##Place holder for future updates.
    Write-Host "This is a work in progress."
}


Function Push-ChangesToRemote
{
    #PlaceHolder for future updates.
    Write-Host "This is a work in progress."
}
