Import-Module ActiveDirectory
Import-Module 'Microsoft.PowerShell.Security'

$users = Import-Csv -Delimiter "," -Path "C:\Users\Administrateur\Desktop\ADV_Project_2018 _Users.csv" # RECUPERATION DU FICHIER CSV POUR LE TRAITEMENT DES DONNEES
$Sites = "ou=Sites,dc=opt227974,dc=lan" # CREATION D'UNE VARIABLE POUR INDIQUER LE PATH (OPTIMISATION DU SCRIPT)
$SitesParis = "ou=Users,ou=Paris,ou=Sites,dc=opt227974,dc=lan"
$SitesMarseille = "ou=Users,ou=Marseille,ou=Sites,dc=opt227974,dc=lan"
$grpsSite = @("RD","Marketing","Finance","Direction","IT") #MEME PRINCIPE, OPTIMISATION
$grpsParis = @("RD_PAR","Marketing_PAR","Finance_PAR","Direction_PAR","IT_PAR")
$grpsMarseille = @("RD_MAR","Marketing_MAR","Finance_MAR","Direction_MAR","IT_MAR")

########## CREATION DES UNITEES D'ORGANISATIONS #######

New-ADOrganizationalUnit -Name "Sites" -Path "dc=opt227974,dc=lan" # ON AJOUTE UNE NOUVELLE OU AVEC NEW-AD... ON LUI DONNE LE NOM ET LE CHEMIN QU'ON SOUHAITE
New-ADOrganizationalUnit -Name "Paris" -Path "ou=Sites,dc=opt227974,dc=lan"
New-ADOrganizationalUnit -Name "Marseille" -Path "ou=Sites,dc=opt227974,dc=lan"
New-ADOrganizationalUnit -Name "Users" -Path "ou=Paris,ou=Sites,dc=opt227974,dc=lan"
New-ADOrganizationalUnit -Name "Servers" -Path "ou=Paris,ou=Sites,dc=opt227974,dc=lan"
New-ADOrganizationalUnit -Name "Computers" -Path "ou=Paris,ou=Sites,dc=opt227974,dc=lan"
New-ADOrganizationalUnit -Name "Users" -Path "ou=Marseille,ou=Sites,dc=opt227974,dc=lan"
New-ADOrganizationalUnit -Name "Servers" -Path "ou=Marseille,ou=Sites,dc=opt227974,dc=lan"
New-ADOrganizationalUnit -Name "Computers" -Path "ou=Marseille,ou=Sites,dc=opt227974,dc=lan"

########## CREATION DES GROUPES #######

foreach ($grpSite in $grpsSite) {New-ADGroup -Name $grpSite -GroupScope Global -GroupCategory Security -Path $Sites}

foreach ($grpParis in $grpsParis) {New-ADGroup -Name $grpParis -GroupScope Global -GroupCategory Security -Path $SitesParis}

foreach ($grpMarseille in $grpsMarseille) {New-ADGroup -Name $grpMarseille  -GroupScope Global -GroupCategory Security -Path $SitesMarseille


########## CREATION DES GROUPES ET LIEN AVEC LES GROUPES PERES #######

Add-ADGroupMember -Identity 'RD' -Members RD_PAR,RD_MAR
Add-ADGroupMember -Identity 'Marketing' -Members Marketing_PAR,Marketing_MAR
Add-ADGroupMember -Identity 'Finance' -Members Finance_PAR,Finance_MAR
Add-ADGroupMember -Identity 'Direction' -Members Direction_PAR,Direction_MAR
Add-ADGroupMember -Identity 'IT' -Members IT_PAR,IT_MAR

########## CREATION DES UTILISATEURS #######

foreach ($user in $users)
 {    
    $name = $user.firstName + " " + $user.lastName #PERMET D'ATTRIBUER DES VARIABLES POUR LES ELEMENTS QUI SONT RECUPERES DANS LE CSV
    $fname = $user.firstName #RECUPERATION DU FIRSTNAME QUI SE TROUVE DANS LE CSV (TITRE)
    $lname = $user.lastName
    $login = $user.firstName + "." + $user.lastName
    $Uou = $user.ou
    $Upassword = $user.password
    $grp = $user.group
    
    switch($user.ou){ #LE SWITCH PERMET DE REGARDER A QUEL SITE APPARTIENT L'UTILISATEUR
        "Paris" {$ou = $SitesParis}
        "Marseille" {$ou = $SitesMarseille}
        default {$ou = $null}    
    }
    
    try { #SI L'UTILISATEUR N'EST PAS CREE, ALORS IL VA ETRE AJOUTE DANS LE BON SITE AVEC LES INFORMATIONS RECUPERES DU CSV
        New-ADUser -Name $name -SamAccountName $login -UserPrincipalName $login -DisplayName $name -GivenName $fname -Surname $lname -AccountPassword (ConvertTo-SecureString $Upassword -AsPlainText -Force) -City $Uou -Path $ou -Department $grp -Enabled $true
        
  echo "Compte ajouté : $name" #AFFICHAGE DANS LE TERMINAL POWERSHELL POUR NOUS INDIQUER L'ETAT DU SCRIPT      
        }
 catch
  {
        echo "Compte non-ajouté : $name"
  }   

 if ($Uou -eq "Paris") #AJOUT DES UTILISATEURS DANS LEURS GROUPES RESPECTIFS EN FONCTION DU CSV
  {
  if ($grp -eq "RD") { Add-ADGroupMember -Identity 'RD_PAR' -Members $login }
  elseif ($grp -eq "Marketing"){ Add-ADGroupMember -Identity 'Marketing_PAR' -Members $login } #AJOUT DE L'UTILISATEUR DANS LE GROUPE MARKETING PUIS DANS LE MARKETING PARIS
  elseif ($grp -eq "Finance"){ Add-ADGroupMember -Identity 'Finance_PAR' -Members $login }
  elseif ($grp -eq "Direction"){ Add-ADGroupMember -Identity 'Direction_PAR' -Members $login }
  elseif ($grp -eq "IT"){ Add-ADGroupMember -Identity 'IT_PAR' -Members $login }
  }
 elseif ($Uou -eq "Marseille")
  {
  if ($grp -eq "RD") { Add-ADGroupMember -Identity 'RD_MAR' -Members $login}
  elseif ($grp -eq "Marketing") { Add-ADGroupMember -Identity 'Marketing_MAR' -Members $login}
  elseif ($grp -eq "Finance") { Add-ADGroupMember -Identity 'Finance_MAR' -Members $login}
  elseif ($grp -eq "Direction") { Add-ADGroupMember -Identity 'Direction_MAR' -Members $login}
  elseif ($grp -eq "IT") { Add-ADGroupMember -Identity 'IT_MAR' -Members $login}
  }

 }
} 
