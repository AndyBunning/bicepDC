<#
    .SYNOPSIS
        Promote the VM to a Domain Controller using the dcpromo_unattend.txt settings file.
#>

param (
    [String]$domain,
    [String]$netbiosName,
    [String]$safeModePass
)

# Update unattend settings file
Add-Content -Path "dcpromo_unattend.txt" -Value "NewDomainDNSName=$($domain)"
Add-Content -Path "dcpromo_unattend.txt" -Value "DomainNetbiosName=$($netbiosName)"
Add-Content -Path "dcpromo_unattend.txt" -Value "SafeModeAdminPassword=$($safeModePass)"


# Run dcpromo with unattend settings file
Start-Process dcpromo /unattend:dcpromo_unattend.txt
