Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false | Out-Null
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
Connect-VIServer -Server vcsa.cloudisMPELIGRY.lan -User mpy@cloudisMPELIGRY.lan -Password *********** | Out-Null

function menu($nomClient) {
Clear-Host
Write-Host "================================================================="
Write-Host "                                MENU                             "
Write-Host "                           SOCIÉTÉ : $nomClient                    "
Write-Host "================================================================="
Write-Host ""
Write-Host "0) Afficher les machines virtuelles"
Write-Host "1) Créer une machine virtuelle"
Write-Host "2) Redémarrer une machine virtuelle"
Write-Host "3) Supprimer une machine virtuelle"
Write-Host "4) Sauvegarde une machinne virtuelle"
Write-Host ""
$choix = Read-Host "Entrez un nombre pour sélectionner une option"
    switch ($choix) {
        0 { Clear-Host
            getVms($nomClient)
            Start-Sleep 5 
            menu($nomClient)}
        1 { createVm($nomClient) }
        2 { restartVm($nomClient) }
        3 { deleteVm($nomClient) }
        4 { createBackupVm($nomClient) }
    }
}


function client() {
Clear-Host
Write-Host "================================================================="
Write-Host "                           NOM CLIENT                            "
Write-Host "================================================================="
Write-Host ""
$nomClient = Read-Host "Saisissez votre nom "
$checkFolder = get-folder -Type VM | Where-Object {$_.Name -eq $nomClient}
Write-Host ""
if ($checkFolder -eq $null) {
        $choixCreationDossier = Read-Host "$nomClient n'existe pas. Voulez-vous le créer ? [o/n]"
        if (($choixCreationDossier -eq "o") -or ($choixCreationDossier -eq "oui") -or ($choixCreationDossier -eq "O") -or ($choixCreationDossier -eq "Oui")) {
            (Get-View (Get-View -viewtype datacenter –filter @{"name"="DC-CLOUDIS-FR-TOURS"}).vmfolder).CreateFolder($nomClient)
            Get-Folder -Name $nomClient | New-VIPermission -Principal CLOUDISMPELIGRY\$nomClient -Role Admin -Propagate:$true -Confirm:$false
            Get-VDSwitch -Name “DSwitch-VM-Netwok” | New-VDPortgroup -Name ("PG-"+$nomClient) -NumPorts 4
            Get-VDSwitch -Name “DSwitch-VM-Netwok” | Get-VDPortgroup -Name ("PG-"+$nomClient) | Get-VDUplinkTeamingPolicy |
            Set-VDUplinkTeamingPolicy -LoadBalancingPolicy LoadBalanceLoadBased -FailBackInherited $false -EnableFailback $true -ActiveUplinkPort {Uplink 1},{Uplink 2} -NotifySwitches $true -NotifySwitchesInherited $false -LoadBalancingPolicyInherited $false -FailoverDetectionPolicy LinkStatus -FailoverDetectionPolicyInherited $false
            menu($nomClient)

        }
        else {client}
}
else {
    Write-Host "$nomClient existe bien." -BackgroundColor DarkGreen
    menu($nomClient)
    }

}


function getVms($nomClient) {
Write-Host ""
Write-Host "================================================================="
Write-Host "               Affichage des Machines Virtuelles                 "
Write-Host "================================================================="
Write-Host ""
$vms = Get-Folder "$nomClient" | Get-VM
if((get-folder $nomClient|get-vm).count -eq 0) {
    Write-Host "Aucune machine virtuelle n'est présente." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    menu($nomClient)
}
else {
$nbvm = 0
foreach ($i in $vms) {
    $folderName = $i.Name
    $latestFolder = (Get-Item "E:\backup_vm\$nomClient\$folderName*").LastWriteTime | Sort-Object CreationTime | Select-Object -Last 1
     Write-Host "$nbvm)" $i.Name "|" $i.Guest.IPAddress "|" $i.PowerState "|" $latestFolder -ForegroundColor Yellow 
     
     $nbvm++
      }
    }
}

function getTemplate() {
Write-Host ""
Write-Host "================================================================="
Write-Host "                       Affichage des templates                   "
Write-Host "================================================================="
Write-Host ""
$templates = Get-Template
$nbtemplate = 0
foreach ($i in $templates) {
     Write-Host "$nbtemplate)" $i.Name  
     $nbtemplate++
      }
    
}

function editIpVm($Global:newNameVm, $Global:chooseIpVm) {
    $networkScript =  "New-NetIPAddress -InterfaceAlias Ethernet0 -AddressFamily IPv4 -IPAddress $Global:chooseIpVm -PrefixLength 24 -DefaultGateway 192.168.12.1"
    Invoke-VMScript -VM $Global:newNameVm -ScriptText $networkScript  -GuestUser "Administrateur" -GuestPassword "******"

}

function remoteDesktop($Global:newNameVm, $Global:chooseIpVm) {
    For ($i=80; $i -gt 1; $i–-) {  
        Write-Progress -Activity "Lancement du Remote Desktop en cours" -SecondsRemaining $i
        Start-Sleep 1
        }
    if ($Global:chooseIpVm) {
        editIpVm $Global:newNameVm $Global:chooseIpVm
        cmdkey /generic:$Global:chooseIpVm /user:"Administrateur" /pass:"*********" | Out-Null
        mstsc /v:$Global:chooseIpVm
        }
    else {
        $ipNewVm = (Get-VM -Name $Global:newNameVm).Guest.IPAddress
        cmdkey /generic:$ipNewVm /user:"Administrateur" /pass:"*********" | Out-Null
        mstsc /v:$ipNewVm
        }
}


function createVm($nomClient) {
Clear-Host
Write-Host ""
Write-Host "================================================================="
Write-Host "                       Création d'une nouvelle VM                "
Write-Host "================================================================="
Write-Host ""
$Global:newNameVm = Read-Host "Choisissez le nom de votre nouvelle machine virtuelle "
$ipChoice = Read-Host "Mettre une ip statique ? [o/n]"
   if (($ipChoice -eq "o") -or ($ipChoice -eq "oui") -or ($ipChoice -eq "O") -or ($ipChoice -eq "Oui")) {
        $Global:chooseIpVm = Read-Host "Indiquer l'ip de votre machine virtuelle (ex: 192.168.12.xxx) " 
   }
getTemplate
$chooseTemplateValue = Read-Host "Choix du template "
$templateName = (Get-Template)[$chooseTemplateValue].Name
try {
New-VM -Template $templateName -Name $Global:newNameVm -Location $nomClient -ResourcePool "Resources" -Datastore "CLUSTER-DRS-ISCSI" -Confirm:$false
}
catch {
    Write-Host "L'entrée est incorrect. Ré-essayer." -ForegroundColor Red
    Start-Sleep 2
    createVm($nomClient)
}

Start-Sleep -s 5
Get-VM -Name $Global:newNameVm | Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -Portgroup "PG-$nomClient" -Confirm:$false | Out-Null
Start-VM $Global:newNameVm
$rdpChoice = Read-Host "Voulez-vous initier une connexion RDP ? [o/n]"
    if (($rdpChoice -eq "o") -or ($rdpChoice -eq "oui") -or ($rdpChoice -eq "O") -or ($rdpChoice -eq "Oui")) {
        remoteDesktop $Global:newNameVm $Global:chooseIpVm
        menu($nomClient)
}
    else {
        if (($ipChoice -eq "o") -or ($ipChoice -eq "oui") -or ($ipChoice -eq "O") -or ($ipChoice -eq "Oui")) {
             editIpVm $Global:newNameVm $Global:chooseIpVm
       }
   menu($nomClient)}
}

function deleteVm($nomClient) {
Clear-Host
Write-Host ""
Write-Host "================================================================="
Write-Host "               SUPPRESSION de Machine Virtuelle                  " -ForegroundColor Red
Write-Host "================================================================="
getVms($nomClient)
Write-Host ""
$chooseVmToDelete = Read-Host "Choix de la vm à supprimer [e pour revenir au menu] "
if ($chooseVmToDelete -match '^[0-9]+$') {
    $vmDeleteName = (get-folder $nomClient|get-vm)[$chooseVmToDelete].Name
    Stop-VM -kill $vmDeleteName -Confirm:$false
    Remove-VM -VM $vmDeleteName -DeleteFromDisk:$true
    }
menu($nomClient)
}

function restartVm($nomClient) {
Clear-Host
Write-Host ""
Write-Host "================================================================="
Write-Host "               Redémarrage de Machine Virtuelle                  "
Write-Host "================================================================="
getVms($nomClient)
Write-Host ""
$chooseVmToRestart = Read-Host "Choix de la vm à redémarrer [e pour revenir au menu] "
if ($chooseVmToRestart -match '^[0-9]+$') {
    $vmRestartName = (get-folder $nomClient|get-vm)[$chooseVmToRestart].Name
    Restart-VMGuest $vmRestartName
    Start-Sleep 5
    }
menu($nomClient)
}

client
