Import-Module DhcpServer

# Ajoute une étendue DHCP nommée "Administration" pour des adresses de gestion
Add-DhcpServerv4Scope -Name "Administration" -StartRange "10.0.10.10" -EndRange "10.0.10.200" -SubnetMask "255.255.255.0" -State Active

# Ajoute une étendue DHCP nommée "DMZ" pour des adresses de la zone démilitarisée
Add-DhcpServerv4Scope -Name "DMZ" -StartRange "10.0.20.10" -EndRange "10.0.20.200" -SubnetMask "255.255.255.0" -State Active

# Ajoute une étendue DHCP nommée "Gestion" pour des adresses de gestion
Add-DhcpServerv4Scope -Name "Gestion" -StartRange "10.0.30.10" -EndRange "10.0.30.200" -SubnetMask "255.255.255.0" -State Active

# Ajoute une étendue DHCP nommée "Voix" pour des adresses vocales
Add-DhcpServerv4Scope -Name "Voix" -StartRange "10.0.40.10" -EndRange "10.0.40.200" -SubnetMask "255.255.255.0" -State Active

# Ajoute une étendue DHCP nommée "Données" pour des adresses de données
Add-DhcpServerv4Scope -Name "Données" -StartRange "10.0.50.10" -EndRange "10.0.50.200" -SubnetMask "255.255.255.0" -State Active

# Ajoute une étendue DHCP nommée "Medical" pour des adresses médicales
Add-DhcpServerv4Scope -Name "Medical" -StartRange "10.0.60.10" -EndRange "10.0.60.200" -SubnetMask "255.255.255.0" -State Active

# Assignation de la route par défaut à chaque étendue
Set-DhcpServerv4OptionValue -OptionID 003 -ScopeId 10.0.10.0 -Value "10.0.10.254"
Set-DhcpServerv4OptionValue -OptionID 003 -ScopeId 10.0.20.0 -Value "10.0.20.254"
Set-DhcpServerv4OptionValue -OptionID 003 -ScopeId 10.0.30.0 -Value "10.0.30.254"
Set-DhcpServerv4OptionValue -OptionID 003 -ScopeId 10.0.40.0 -Value "10.0.40.254"
Set-DhcpServerv4OptionValue -OptionID 003 -ScopeId 10.0.50.0 -Value "10.0.50.254"
Set-DhcpServerv4OptionValue -OptionID 003 -ScopeId 10.0.60.0 -Value "10.0.60.254"

# Ajoute la relation de basculement en mode de basculement de charge (50%)
Add-DhcpServerv4Failover -Name "LoadBalancing" -ScopeID 10.0.10.0, 10.0.20.0, 10.0.30.0, 10.0.40.0, 10.0.50.0, 10.0.60.0 -LoadBalancePercent 50 -PartnerServer "ServBKupAkat.akat.fr" -SharedSecret "SAE502akat"
