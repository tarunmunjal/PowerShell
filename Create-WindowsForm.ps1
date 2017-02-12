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
        $FormObject.Visible = $Visible
        if($ImageInBase64)
        {
            $FormObject.BackgroundImage = $BitmapFromStream
            $FormObject.BackgroundImageLayout = $BackGroundImageStyle
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
$Base64PNG = [convert]::ToBase64String((get-content 'C:\pictures\tarun.jpg' -encoding byte))
$Label = New-ControlObject -ObjectType 'Label' -BackColor 'Purple' -ForeColor 'Black' -Font 'Times New Roman' -FontSize 8 -Text 'Label Text' -HorizontalLocation 10 -VerticalLocation 20 -HorizontalSize 200 -VerticalSize 20
$Button = New-ControlObject -ObjectType 'Button' -BackColor 'lightgray' -ForeColor 'Yellow' -Font 'Comic Sans MS' -FontSize 8 -Text 'Button Text' -HorizontalLocation 220 -VerticalLocation 20 -HorizontalSize 200 -VerticalSize 20 -ImageInBase64 $Base64PNG
$TextBox = New-ControlObject -ObjectType 'TextBox' -BackColor 'lightgray' -ForeColor 'Green' -Font 'Times New Roman' -FontSize 8 -Text 'Text Box' -HorizontalLocation 10 -VerticalLocation 50 -HorizontalSize 200 -VerticalSize 20 
$ComboBox = New-ControlObject -ObjectType 'ComboBox' -BackColor '#95a5a6' -ForeColor 'Black' -Font 'Times New Roman' -FontSize 8 -Text 'Combo Box' -HorizontalLocation 220 -VerticalLocation 50 -HorizontalSize 200 -VerticalSize 20
$RichTextBox = New-ControlObject -ObjectType 'RichTextBox' -BackColor '#50B9B7' -ForeColor 'Black' -Font 'Times New Roman' -FontSize 8 -Text 'Rich Text Box' -HorizontalLocation 10 -VerticalLocation 85 -HorizontalSize 200 -VerticalSize 20
$CheckBox = New-ControlObject -ObjectType 'CheckBox' -BackColor '#3B8622' -ForeColor 'Black' -Font 'Times New Roman' -FontSize 8 -Text 'Check Box' -HorizontalLocation 220 -VerticalLocation 85 -HorizontalSize 200 -VerticalSize 20
$CheckedListBox = New-ControlObject -ObjectType 'CheckedListBox' -BackColor '#DBE641' -ForeColor 'Black' -Font 'Times New Roman' -FontSize 8 -Text 'CheckedListBox' -HorizontalLocation 10 -VerticalLocation 120 -HorizontalSize 200 -VerticalSize 40
$ListBox = New-ControlObject -ObjectType 'ListBox' -BackColor '#D7B1A9' -ForeColor 'White' -Font 'Times New Roman' -FontSize 8 -Text 'ListBox' -HorizontalLocation 220 -VerticalLocation 120 -HorizontalSize 200 -VerticalSize 40
$ComboBox.Items.add("Combo Box Item 1") | Out-Null
$ComboBox.Items.add("Combo Box Item 1") | Out-Null
$CheckedListBox.Items.add("Checked List Box Item 1") | Out-Null
$CheckedListBox.Items.add("Checked List Box Item 2") | Out-Null
$ListBox.Items.add("List Box Item 1") | Out-Null
$ListBox.Items.add("List Box Item 1") | Out-Null

#$ListBox ,$CheckedListBox , $CheckBox ,$RichTextBox, $ComboBox ,$TextBox ,$Button , $Label | New-CustomForm -FormHeight 800 -FormWidth 600 -FormBackColor '#552a20' -FormForeColor 'red'

$ListBox ,$CheckedListBox , $CheckBox ,$RichTextBox, $ComboBox ,$TextBox ,$Button , $Label | New-CustomForm -FormHeight 800 -FormWidth 800 -FormBackColor '#552a20' -FormForeColor 'red' -ImageInBase64 $base64ico
#>
