## Que fait le script ?
> Ce script powershell à pour objectif de créer des sauvegardes complètes des machines virtuelles dans un état "démarré" présentes sur un vcenter server appliance (vcsa) avec des esxi. La version utilisé est la 6.7u. Les sauvegardes s'effectuent sur un datastore NFS (pour l'exemple à modifier en conséquence) et une fois terminé le script envoi un email pour avertir que la VM (nom + heure et date de sauvegarde) a bien été sauvegardée. Ici j'utilise powercli.

### Les différentes étapes du script :
- Connexion au vcenter server appliance
- Parcours l'ensemble des machines virtuelles de manière itérative et pour chacune d'elle il va faire les étapes ci-dessous:
	- Si une machine virtuelle est dans un dossier alors le programme va créer ce même dossier dans le NFS et y stocker la sauvegarde la vm.
	- Création d'un clone avec le nom de la vm suivi de l'heure et de la journée.
	- Export du clone au format OVA dans le datastore NFS.
	- Suppression du clone temporaire.
	- Envoie d'un email contenant les différentes informations liées à la sauvegarde.
