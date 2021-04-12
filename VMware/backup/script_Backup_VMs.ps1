Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false | Out-Null
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
Connect-VIServer -Server vcsa.cloudisMPELIGRY.lan -User mpy@cloudisMPELIGRY.lan -Password ********* | Out-Null

$vms = Get-VM | Where-Object { $_.Name -notlike '*TEMPLATE*'}
foreach ($i in $vms) {
    $date = (Get-Date).tostring(“hh-HH_dd-MM-yyyy”)
    #New-Snapshot -VM $i.Name -Name "Backup_$date" -Quiesce -Memory -RunAsync
    $nameClone = $i.Name + "_"+ $date
    $pathTest = "E:\backup_vm\"+$i.Folder.Name
    if (!(Test-Path $pathTest))
    {
        New-Item -itemType Directory -Path E:\backup_vm -Name $i.Folder.Name
        New-vm -vm (get-vm $i.Name) -name $nameClone -ResourcePool "Resources" -Datastore "DS-BACKUP" | export-vapp -Destination "$pathTest\" -Format OVA
        Remove-VM -VM $nameClone -DeletePermanently -Confir:$false
    }
    else
    {
        New-vm -vm (get-vm $i.Name) -name $nameClone -ResourcePool "Resources" -Datastore "DS-BACKUP" | export-vapp -Destination "$pathTest\" -Format OVA
        Remove-VM -VM $nameClone -DeletePermanently -Confir:$false
    }
    $fromSrc = "supinfotourstest@gmail.com"
    $smtpServer = ‘smtp.gmail.com’
    $smtpServerPort = "587"
    $emailSmtpUser = "fromtestemail@gmail.com"
    $emailSmtpPass = "************"

    $emailMessage = New-Object System.Net.Mail.MailMessage
    $emailMessage.From = "supinfotourstest@gmail.com"
    $emailMessage.To.Add( " receiver@gmail.com " )
    $emailMessage.Subject = " EMAIL - Sauvegarde "
    $emailMessage.Body = " Votre sauvegarde $nameClone a bien été réalisée. "

    $SMTPClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpServerPort )
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass );
    $SMTPClient.Send( $emailMessage )
} 
