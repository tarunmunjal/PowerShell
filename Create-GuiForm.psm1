[System.Reflection.Assembly]::LoadWithPartialName("System") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.IO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Environment") | Out-Null
Function New-ControlObject
{
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true,ValuefromPipeline=$true)]
        [String]$ObjectType, 
        [Parameter(Mandatory=$false)]
        [String]$BackColor, 
        [Parameter(Mandatory=$false)]
        [String]$ForeColor,  
        [Parameter(Mandatory=$false)]
        [String]$Font, 
        [Parameter(Mandatory=$false)]
        [int]$FontSize = 10, 
        [Parameter(Mandatory=$false)]
        [int]$TabIndex, 
        [Parameter(Mandatory=$false)]
        [string]$Text,
        [Parameter(Mandatory=$false)]
        [string]$HorizontalLocation,
        [Parameter(Mandatory=$false)]
        [string]$VerticalLocation,
        [Parameter(Mandatory=$false)]
        [string]$HorizontalSize,
        [Parameter(Mandatory=$false)]
        [string]$VerticalSize,
        [Parameter(Mandatory=$false)]
        [Boolean]$Visible = $true,
        [Parameter(Mandatory=$false)]
        [String]$ImageInBase64,
        [Parameter(Mandatory=$false)]
        [String]$BackGroundImageStyle = 'stretch'
    )
    begin
    {
        if($Font)
        {
            try
            {
                $FontObject = [System.Drawing.font]::new($Font,$FontSize)
            }
            catch
            {
                $_.exception.message | Out-Host
                return
            }
        }
        if($ImageInBase64)
        {
            $StringFromBase64 = [System.Convert]::FromBase64String("$ImageInBase64")
            $StreamFromBase64 = [System.IO.MemoryStream]::new($StringFromBase64)
            $BitmapFromStream = [System.Drawing.Bitmap]::new($StreamFromBase64)
        }
    }
    Process
    {
        #$FormObject = New-Object System.Windows.Forms.Button
        $FormObject = New-Object System.Windows.Forms.$ObjectType
        $FormObject.Location = New-Object System.Drawing.Size($HorizontalLocation,$VerticalLocation) 
        $FormObject.size = New-Object System.Drawing.Size($HorizontalSize,$VerticalSize)
        if($text)
        {
            $FormObject.text = $text
        }
        if($TabIndex)
        {
            $FormObject.TabIndex = $TabIndex
        }
        if($BackColor)
        {
            $FormObject.BackColor = $BackColor
        }
        if($ForeColor)
        {
            $FormObject.ForeColor = $ForeColor
        }
        if($Font)
        {
            $FormObject.font = $FontObject
        }
        try
        {
            $FormObject.Visible = $Visible
        }
        catch
        {
            Write-Warning "$ObjectType doesn't have a property Visible."
        }
        if($ImageInBase64)
        {
            $FormObject.BackgroundImage = $BitmapFromStream
            $FormObject.BackgroundImageLayout = $BackGroundImageStyle
        }
        if($ObjectType -eq 'MaskedTextBox')
        {
            $FormObject.PasswordChar = '*'
        }
    }
    End
    {
        return $FormObject
    }
}
Function New-CustomForm
{
    [cmdletbinding()]
    Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [Array]$ItemsOnForm,
    [Int]$FormHeight,
    [Int]$FormWidth,
    [string]$FormBackColor,
    [string]$FormForeColor,
	[string]$FormBorderStyle,
    [string]$ImageInBase64,
    [string]$FormTitle,
    [string]$BackGroundImageStyle = 'Stretch'
    )
    Begin{
        $Form = New-Object System.Windows.Forms.Form    
        $Form.Size = New-Object System.Drawing.Size($FormWidth, $FormHeight) 
        $Form.Font = New-Object System.Drawing.Font("Calibri", 12)
        if($FormBackColor)
        {
            $Form.BackColor = $FormBackColor
        }
        if($FormForeColor)
        {
            $Form.ForeColor = $FormForeColor
        }
		if($FormBorderStyle)
		{
			$Form.FormBorderStyle = $FormBorderStyle
		}
        if($ImageInBase64)
        {
            #$Form.BackgroundImageLayout.value__
            $StringFromBase64 = [System.Convert]::FromBase64String("$ImageInBase64")
            $StreamFromBase64 = [System.IO.MemoryStream]::new($StringFromBase64)
            $BitmapFromStream = [System.Drawing.Bitmap]::new($StreamFromBase64)
            $Form.BackgroundImage = $BitmapFromStream
            $Form.BackgroundImageLayout = $BackGroundImageStyle
        }
        $Form.Text = $FormTitle
    }
    Process
    {
        $ItemsOnForm | %{$Form.controls.add($_)}
        
    }
    End
    {
        $Form.Add_Shown({$Form.Activate()})
        [void] $Form.ShowDialog()
    }
}