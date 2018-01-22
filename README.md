#![tarun](tarun.jpg)
# PowerShell Scripts
Scripts in this repository are my "work in progress". 
Scripts written in powershell to help community.

About Create-GuiForm Module :
=============================
  This module is used to create a Graphical User Interface in Powershell for your scripts. It is very very easy to create GUI form in powershell but in my experience most scripters don't like to type all that needs to be done to create the GUI frontend.
  
  I write scripts that are used by users with no powershell experience so I create gui front end for them to use.


About Create-WindowsForm Script :
=================================
  This script basically shows you how you can create a GUI interface in Powershell using the Create-GuiForm module.


About InvokeSimpleRestAPIGUI Script:
====================================
  There are times when you need to execute RestApi calls on servers for Internal APIs. I have worked on a number of apis in different jobs. Since ACLs didn't allow for installation of a restapi plugin. I used powershell to make these calls. Typing all that code to make these calls usually gets very tiring so I created this Interface when I need to make these api calls.
  
  I use this script to make these rest calls. I was working on Git module and this is the api that I used to test the call before creating a module to automatically create pull request and merge them using Git API https://github.com/tarunmunjal/Git. 

About Invoke-LinuxCommands Script:
====================================
This module requires you to have Posh-ssh installed. You can run multiple commands that you need to execute on a linux system from windows powershell. All you need to do is batch up those commands (plural) and then pass the servers (plural). All the commands you pass will be run sequentially one by one on all servers (Simultaeously). <br />
This Function also require that you are able to run sudo commands without having to enter your password. 

If you have different commands that need to be run on different servers then I suggest you do what I did. I used this script with a csv file that has the server information and commands to be run on each server. 
Here is an example of the command

$Credentials = Get-Credentials

$Servers = "Server1","Server2","Server3","Server4","Server5"

$commands = @' <br />
sudo yum install epel-release <br />
sudo yum install nginx <br />
sudo systemctl start nginx <br />
sudo firewall-cmd --permanent --zone=public --add-service=http <br />
sudo firewall-cmd --permanent --zone=public --add-service=https <br />
sudo firewall-cmd --reload <br />
'@ -split '\r\n' <br />

$Report = Invoke-LinuxCommands -servers $servers -commands $commands -credentials $credentials -UseStream


If you use a user that doesn't require having to type sudo "e.g. root" then the following can be used without specifying -UseStream switch.

$commands = @' <br />
yum install epel-release <br />
yum install nginx <br />
systemctl start nginx <br />
firewall-cmd --permanent --zone=public --add-service=http <br />
firewall-cmd --permanent --zone=public --add-service=https <br />
firewall-cmd --reload <br />
'@ -split '\r\n' <br />

$Report = Invoke-LinuxCommands -servers $servers -commands $commands -credentials $credentials 


This will give you a hash table that can be converted to Json object. Report would have server name as key and the outout of all the commands as value.
