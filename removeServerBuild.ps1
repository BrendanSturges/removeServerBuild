###
# Script Written By: Brendan Sturges
# Script will be installed in the Server build Task Sequence to remove the computer object from the AD group and notify when it is complete.
###

$server = $env:computername
$recipient = @("")
$msgBody = ""
$smtpserver = ""
$ErrorMessage = ''
$status = ''
$DC = ""
$buildGroup = ""

#Remove server from AD Group
Try{
Invoke-Command -computername $DC -scriptblock {import-module activedirectory; $sam = (Get-ADComputer $Using:server | Select SamAccountName).SamAccountName; remove-adgroupmember -identity $buildGroup -member $sam -confirm:$false}

$msgBody = "$server removed from $buildGroup`n"
$status = "successfully"
}

Catch{
$ErrorMessage = $_.Exception.Message
$msgBody = "Error removing $server from $buildGroup: `n$ErrorMessage"
$status = "with errors"
}

$subject = "$server sccm task sequence completed: $status"
#Send-MailMessage
Send-MailMessage -to $recipient -from donotreply -subject $subject -body $msgBody -smtpserver $smtpserver