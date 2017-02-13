Import-Module $psscriptroot\Create-GuiForm.psm1 -Force
## Create Form Objects
## UserName

$UserNameLabel = New-ControlObject -ObjectType 'Label' -Font 'Segoe UI' -FontSize 12 -Text 'Username :' -HorizontalLocation 10 -VerticalLocation 20 -HorizontalSize 100 -VerticalSize 25
$UserNameTextBox = New-ControlObject -ObjectType 'TextBox' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 150 -VerticalLocation 20 -HorizontalSize 200 -VerticalSize 25 
## Password
$PasswordLabel = New-ControlObject -ObjectType 'Label' -Font 'Segoe UI' -FontSize 12 -Text 'Password :' -HorizontalLocation 10 -VerticalLocation 60 -HorizontalSize 100 -VerticalSize 25
$PasswordTextBox = New-ControlObject -ObjectType 'MaskedTextBox' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 150 -VerticalLocation 60 -HorizontalSize 200 -VerticalSize 25
## RestMethod
$MethodLabel = New-ControlObject -ObjectType 'Label' -Font 'Segoe UI' -FontSize 12 -Text 'Rest Method :' -HorizontalLocation 10 -VerticalLocation 100 -HorizontalSize 120 -VerticalSize 25
$MethodComboBox = New-ControlObject -ObjectType 'ComboBox' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 150 -VerticalLocation 100 -HorizontalSize 100 -VerticalSize 150
$MethodComboBox.Items.add('Get') | Out-Null
$MethodComboBox.Items.add('Post') | Out-Null
$MethodComboBox.Items.add('Put') | Out-Null
$MethodComboBox.Items.add('Delete') | Out-Null
$MethodComboBox.Items.add('Patch') | Out-Null
$MethodComboBox.SelectedIndex = 0
##
$ResetValuesButton = New-ControlObject -ObjectType 'Button' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 260 -VerticalLocation 100 -HorizontalSize 100 -VerticalSize 30 -Text "Reset Values"
## Body Parameter 
$BodyKeyLabel = New-ControlObject -ObjectType 'Label' -Font 'Segoe UI' -FontSize 12 -Text 'Body Key :' -HorizontalLocation 10 -VerticalLocation 140 -HorizontalSize 120 -VerticalSize 25
$BodyKeyTextBox = New-ControlObject -ObjectType 'TextBox' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 150 -VerticalLocation 140 -HorizontalSize 200 -VerticalSize 25
$BodyValueLabel = New-ControlObject -ObjectType 'Label' -Font 'Segoe UI' -FontSize 12 -Text 'Body Value :' -HorizontalLocation 10 -VerticalLocation 180 -HorizontalSize 120 -VerticalSize 25
$BodyValueTextBox = New-ControlObject -ObjectType 'TextBox' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 150 -VerticalLocation 180 -HorizontalSize 200 -VerticalSize 25 
## Button
$AddKeyValuePairButton = New-ControlObject -ObjectType 'Button' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 400 -VerticalLocation 180 -HorizontalSize 180 -VerticalSize 50 -Text "Add Parmeters to Body"
## Read only rich Text box to show list parameters added
$ParametersRichTextBox = New-ControlObject -ObjectType 'RichTextBox' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 400 -VerticalLocation 20 -HorizontalSize 350 -VerticalSize 150
$ParametersRichTextBox.ReadOnly = $true
$ParametersRichTextBox.BackColor = '#2ECCFA'
## Headers 
$HeaderKeyLabel = New-ControlObject -ObjectType 'Label' -Font 'Segoe UI' -FontSize 12 -Text 'Header Key :' -HorizontalLocation 10 -VerticalLocation 220 -HorizontalSize 120 -VerticalSize 25
$HeaderKeyTextBox = New-ControlObject -ObjectType 'TextBox' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 150 -VerticalLocation 220 -HorizontalSize 200 -VerticalSize 25 -Text 'Content-Type'
$HeaderValueLabel = New-ControlObject -ObjectType 'Label' -Font 'Segoe UI' -FontSize 12 -Text 'Header Value :' -HorizontalLocation 10 -VerticalLocation 260 -HorizontalSize 120 -VerticalSize 25
$HeaderValueTextBox = New-ControlObject -ObjectType 'TextBox' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 150 -VerticalLocation 260 -HorizontalSize 200 -VerticalSize 25 -Text 'Application/Json'
$AddHeadersButton = New-ControlObject -ObjectType 'Button' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 600 -VerticalLocation 180 -HorizontalSize 150 -VerticalSize 50 -Text "Add Headers"
## Url
$UrlLabel = New-ControlObject -ObjectType 'Label' -Font 'Segoe UI' -FontSize 12 -Text 'Url :' -HorizontalLocation 10 -VerticalLocation 300 -HorizontalSize 100 -VerticalSize 25
$UrlTextBox = New-ControlObject -ObjectType 'TextBox' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 150 -VerticalLocation 300 -HorizontalSize 600 -VerticalSize 25
## Data manipulation checkbox
$RawDataCheckBox = New-ControlObject -ObjectType 'CheckBox' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 600 -VerticalLocation 250 -HorizontalSize 200 -VerticalSize 25 -Text "Raw Data" -Visible $false
## Invoke Request Buttons
$InvokeRequestButton = New-ControlObject -ObjectType 'Button' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 400 -VerticalLocation 240 -HorizontalSize 180 -VerticalSize 50 -Text "InvokeRequest"
## Read only Response Rich Text box
$ResponseRichTextBox = New-ControlObject -ObjectType 'RichTextBox' -Font 'Segoe UI' -FontSize 12 -HorizontalLocation 40 -VerticalLocation 350 -HorizontalSize 700 -VerticalSize 400
$ResponseRichTextBox.ReadOnly = $true
## Setting script wide variables and defining control events
$Script:RequestHeaders = @{}
$Script:BodyParameters = @{}
$RTOriginalColor = $ResponseRichTextBox.ForeColor
$ResetValuesButton.Add_click({
    $Script:RequestHeaders = @{}
    $Script:BodyParameters = @{}
    $UserNameTextBox.Text = ""
    $PasswordTextBox.Text = ""
    $BodyKeyTextBox.Text = ""
    $BodyValueTextBox.Text = ""
    $HeaderKeyTextBox.Text = ""
    $MethodComboBox.SelectedIndex = 0
    $HeaderValueTextBox.Text = ""
    $ParametersRichTextBox.Text = ""
    $ResponseRichTextBox.Text = ""
    $ResponseRichTextBox.text = $BodyParameters | Out-String
})
$AddHeadersButton.Add_Click({
    if($HeaderKeyTextBox.Text)
    {
        try{
            $RequestHeaders.add(($HeaderKeyTextBox.Text).ToString(),($HeaderValueTextBox.text).ToString())
            $ResponseRichTextBox.Text += (Get-Date).ToString() + ' - ' + "Successfully Added Header : $($HeaderKeyTextBox.text) , $($HeaderValueTextBox.text)`n"
        }
        catch
        { 
            $ResponseRichTextBox.ForeColor = '#FF0000'
            $ResponseRichTextBox.text += (Get-Date).ToString() + ' - ' + $_.exception.message + "`n"
            return
        }
    }
})

$AddKeyValuePairButton.Add_click({
    try
    {
        if($Script:BodyParameters.count -eq 0)
        {
            $ResponseRichTextBox.text += "Rest Parameters tend to be case sensitive please make sure to follow the documentation."
        }
        if($Script:BodyKeyTextBox.text)
        {
            $Script:BodyParameters.add(($BodyKeyTextBox.Text).ToString(),$BodyValueTextBox.Text.ToString())
        }
        else
        {
            $ResponseRichTextBox.ForeColor = '#FF0000'
            $ResponseRichTextBox.text += (Get-Date).ToString() + ' - ' + "Key value cannot be empty." + "`n"
            $ResponseRichTextBox.SelectionStart = $ResponseRichTextBox.Text.Length
            $ResponseRichTextBox.ScrollToCaret()
            return
        }
    }
    Catch
    {
        $ResponseRichTextBox.ForeColor = '#FF0000'
        $ResponseRichTextBox.text += (Get-Date).ToString() + ' - ' + $_.exception.message + "`n"
        $ResponseRichTextBox.SelectionStart = $ResponseRichTextBox.Text.Length
        $ResponseRichTextBox.ScrollToCaret()
        return
    }
    $ParametersRichTextBox.Text = $Script:BodyParameters | convertto-json
})
$InvokeRequestButton.Add_click({    
    if(-not $UrlTextBox.text)
    {
        $ResponseRichTextBox.ForeColor = '#FF0000'
        $ResponseRichTextBox.text += (Get-Date).ToString() + ' - ' + "Please make sure url is specified." + "`n"
        $ResponseRichTextBox.SelectionStart = $ResponseRichTextBox.Text.Length
        $ResponseRichTextBox.ScrollToCaret()
        return
    }
    if($UserNameTextBox.text -and $PasswordTextBox.text)
    {
        if(!($Script:RequestHeaders.Keys -eq 'Authorization'))
        {
            $EncodedCredntials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($UserNameTextBox.Text):$($PasswordTextBox.Text)")) 
            $Script:RequestHeaders.add('Authorization',"Basic $EncodedCredntials")
        }
    }
    else
    {
        $ResponseRichTextBox.ForeColor = '#FF0000'
        $ResponseRichTextBox.text += (Get-Date).ToString() + ' - ' + "No Username or password specified will be added to the headers." + "`n"
        $ResponseRichTextBox.SelectionStart = $ResponseRichTextBox.Text.Length
        $ResponseRichTextBox.ScrollToCaret()
    }
    try
    {
        if($Script:BodyParameters.Count -ne 0)
        {
            $ResponseRichTextBox.text = (Invoke-RestMethod -Method ($MethodComboBox.SelectedItem).ToString() -Uri ($UrlTextBox.Text).ToString() -Headers $Script:RequestHeaders -Body ($Script:BodyParameters | ConvertTo-Json) | ConvertTo-Json)
        }
        else
        {
            $ResponseRichTextBox.text = (Invoke-RestMethod -Method ($MethodComboBox.SelectedItem).ToString() -Uri ($UrlTextBox.Text).ToString() -Headers $Script:RequestHeaders | ConvertTo-Json)
        }
    }
    catch
    {
        $ResponseRichTextBox.ForeColor = '#FF0000'
        $ResponseRichTextBox.text += (Get-Date).ToString() + ' - ' + $_.exception.message + "`n"
        $ResponseRichTextBox.SelectionStart = $ResponseRichTextBox.Text.Length
        $ResponseRichTextBox.ScrollToCaret()
        return
    }
    <#if($RawDataCheckBox.Checked)
    {
        $ResponseRichTextBox.ForeColor = $RTOriginalColor
        $ResponseRichTextBox.text = $Response
        $ResponseRichTextBox.SelectionStart = $ResponseRichTextBox.Text.Length
        $ResponseRichTextBox.ScrollToCaret()
    }
    else
    {
        $ResponseRichTextBox.ForeColor = $RTOriginalColor
        $ResponseRichTextBox.text = ($Response | ConvertTo-Json)
        $ResponseRichTextBox.SelectionStart = $ResponseRichTextBox.Text.Length
        $ResponseRichTextBox.ScrollToCaret()
    }#>
})

## Adding all controls to the form and starting the form.
$UserNameLabel, $UserNameTextBox, $PasswordLabel, $PasswordTextBox, $MethodLabel, $MethodComboBox, $BodyKeyLabel,$BodyKeyTextBox,$BodyValueLabel,$BodyValueTextBox ,$HeaderKeyLabel ,`
$HeaderKeyTextBox ,$HeaderValueLabel,$HeaderValueTextBox, $UrlLabel ,$UrlTextBox ,$AddKeyValuePairButton ,$AddHeadersButton,$RawDataCheckBox ,$InvokeRequestButton  ,`
$ParametersRichTextBox ,$ResponseRichTextBox,$ResetValuesButton | New-CustomForm -FormHeight 800 -FormWidth 800 -FormForeColor '#0080FF'  -FormTitle "Simple RestAPI Graphical User Interface."
<#$RawDataCheckBox, $HeaderKeyLabel, $HeaderKeyTextBox, $HeaderValueLabel, $HeaderValueTextBox, $UserNameLabel, $UserNameTextBox, $PasswordLabel, `
$PasswordTextBox,$MethodLabel, $MethodComboBox, $ParametersRichTextBox , $UrlLabel, $UrlTextBox, $BodyKeyLabel, $BodyValueLabel, $BodyKeyTextBox, `
$BodyValueTextBox, $AddKeyValuePairButton, $ResponseRichTextBox, $InvokeRequestButton, $AddHeadersButton| New-CustomForm -FormHeight 800 -FormWidth 800 -FormForeColor '#0080FF'  -FormTitle "Rest API Calls"
#>