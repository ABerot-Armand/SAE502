# Spécifiez le chemin du fichier CSV contenant les données
$CSVFile = "C:\BDD-Script\add_personnel.csv"
$CSVData = Import-CSV -Path $CSVFile -Delimiter "," -Encoding UTF8

# Créez l'unité organisationnelle (OU) "CLINIQUE" sous "DC=AKAT,DC=FR"
New-ADOrganizationalUnit -Name "CLINIQUE" -Path "DC=AKAT,DC=FR" -ProtectedFromAccidentalDeletion $false

# Créez un groupe "EQUIPES" sous l'OU "CLINIQUE"
New-ADGroup -Name "EQUIPES" -Path "OU=CLINIQUE,DC=AKAT,DC=FR" -GroupScope Global

# Créez les répertoires "PERSO" et "EQUIPES" sur le lecteur C :
New-Item -Path "C:\" -Name "PERSO" -ItemType "Directory" -Force
New-Item -Path "C:\" -Name "EQUIPES" -ItemType "Directory" -Force

# Boucle de traitement des données du CSV
foreach ($add_personnel in $CSVData) {
    # Récupérez le nom d'équipe à partir du CSV
    $EquipesPersonnel = $add_personnel.occupation
    
    # Créez un groupe pour l'équipe
    New-ADGroup -Name "$EquipesPersonnel" -GroupScope Global -Path "OU=CLINIQUE,DC=AKAT,DC=FR"
    
    # Ajoutez le groupe à "EQUIPES"
    Add-ADGroupMember -Identity "CN=EQUIPES,OU=CLINIQUE,DC=AKAT,DC=FR" -Members "$EquipesPersonnel"
    
    # Créez un répertoire pour l'équipe sous C:\EQUIPES
    New-Item -Path "C:\EQUIPES\" -Name "$EquipesPersonnel" -ItemType "Directory" -Force

    # Configurez les autorisations du répertoire
    $acl = Get-ACL -Path "C:\EQUIPES\$EquipesPersonnel"
    $acl.SetAccessRuleProtection($true, $false)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrateur", "FullControl", "Allow")
    $acl.AddAccessRule($AccessRule)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("EQUIPES", "ReadAndExecute", "Allow")
    $acl.AddAccessRule($AccessRule)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$EquipesPersonnel", "Modify", "Allow")
    $acl.AddAccessRule($AccessRule)
    $acl | Set-Acl -Path "C:\EQUIPES\$EquipesPersonnel"
}

# Créez des partages SMB pour "EQUIPES" et "PERSO" avec un accès complet pour tout le monde
New-SmbShare -Name "EQUIPES" -Path "C:\EQUIPES\" -FullAccess "Everyone"
New-SmbShare -Name "PERSO" -Path "C:\PERSO\" -FullAccess "Everyone"

# Répétez le traitement pour chaque utilisateur dans le CSV
foreach ($add_personnel in $CSVData) {
    # Récupérez les informations de l'utilisateur depuis le CSV
    $Prenom = $add_personnel.Prenom
    $Nom = $add_personnel.Nom
    $Equipe = $add_personnel.Occupation

    # Créez un compte d'utilisateur sous "OU=CLINIQUE,DC=AKAT,DC=FR" avec les options suivantes :
    # - Name : Nom de l'utilisateur
    # - Path : Emplacement de l'unité organisationnelle
    # - Enabled : Compte activé
    # - AccountPassword : Mot de passe du compte (par défaut "Secret123")
    # - DisplayName : Nom complet de l'utilisateur
    # - GivenName : Prénom de l'utilisateur
    # - Surname : Nom de l'utilisateur
    # - HomeDrive : Lettre du lecteur réseau attribuée (M:)
    # - HomeDirectory : Répertoire réseau personnel du nom de l'utilisateur
    # - ScriptPath : Chemin du script de connexion (loginQualite.bat)
    # - AccountExpirationDate : Date d'expiration du compte (6 mois à partir de la date actuelle)

    New-ADUser -Name "$Nom" -Path "OU=CLINIQUE,DC=AKAT,DC=FR" -Enabled $true -AccountPassword (ConvertTo-SecureString -AsPlainText "Secret123" -Force) -DisplayName "$Prenom $Nom" -GivenName "$Prenom" -Surname "$Nom" -HomeDrive "M:" -HomeDirectory "\\ServMainAKAT\PERSO\$Nom" -ScriptPath "loginQualite.bat" -AccountExpirationDate ((Get-Date).AddMonths(6))

    # Ajoutez l'utilisateur au groupe correspondant
    Add-ADGroupMember -Identity "CN=$Equipe,OU=CLINIQUE,DC=AKAT,DC=FR" -Members "$Nom"

    # Créez un répertoire personnel pour l'utilisateur sous C:\PERSO
    New-Item -Path "C:\PERSO\" -Name "$Nom" -ItemType "Directory" -Force

    # Configurez les autorisations du répertoire personnel
    $acl = Get-ACL -Path "C:\PERSO\$Nom"
    $acl.SetAccessRuleProtection($true, $false)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrateur", "FullControl", "Allow")
    $acl.AddAccessRule($AccessRule)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$Nom", "Modify", "Allow")
    $acl.AddAccessRule($AccessRule)
    $acl | Set-Acl -Path "C:\PERSO\$Nom"
}
