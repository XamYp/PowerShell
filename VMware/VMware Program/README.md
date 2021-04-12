![alt text](https://github.com/XamYp/PowerShell/blob/main/VMware/VMware%20Program/images/menu.png?raw=true)
## Que fait le script ?
Ce script powershell utilise le module powercli. Il a pour objectif d'être un menu interactif où l'utilisateur choisit un groupe d'utilisateur présent dans l'active directory. Une fois ce groupe saisi le script va automatiquement créer un dossier de type "Machines virtuelles et modèles" sur le virtual center server appliance (vcsa) et y créer un port-groupe propre. Enfin il ajoutera la permission "Administrateur" au groupe d'utilisateur active-directory à ce dossier.

Le script permet ensuite **d'afficher les machines virtuelles** (nom des machines virtuelles, leurs ip, leurs états et leures dernières sauvegardes) présentes dans ce groupe active directory, de **supprimer une machine virtuelle**, de **redémarrer une machine virtuelle** ou de **créer une machine virtuelle**.

La **création d'une machine virtuelle** se décompose de la manière suivante :
- Nom de la vm à créer.
- Ajout d'une ip statique manuelle ? (si non le DHCP attribuera une adresse automatiquement).
- Choix du modèle (récupère l'ensemble des modèles présents et disponibles sur le vcsa).
- Démarrer une connexion de bureau à distance après la fin de la création de la machine virtuelle ? 

> Il est possible dans le script de revenir au menu principal peu importe où vous êtes.

## Captures d'écrans :
### Groupe Active Directory
![choix du groupe active directory](https://github.com/XamYp/PowerShell/blob/main/VMware/VMware%20Program/images/nomGroupeAD.png?raw=true)

### Menu
![menu](https://github.com/XamYp/PowerShell/blob/main/VMware/VMware%20Program/images/menu.png?raw=true)

### Affiche des machines virtuelles pour le groupe active directory
![affichage des vms](https://github.com/XamYp/PowerShell/blob/main/VMware/VMware%20Program/images/affichageDesVms.png?raw=true)

### Création d'une nouvelle machine virtuelle
![nouvelle machine virtuelle](https://github.com/XamYp/PowerShell/blob/main/VMware/VMware%20Program/images/nouvelleVM.png?raw=true)
