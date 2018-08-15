#####
### CMDLET for removing trusted hosts from a machine.
### If the '$Remote' switch is not set then only the trusted
### hosts from the local machine will be removed if necessary.
###
### Author: Weston Berg
### Date: Aug. 14, 2018
#####

Function Remove-TrustedHosts {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)][string[]]$Hosts,
        [Parameter(Mandatory=$true)][PSCredential]$Credential,
        [Parameter(Mandatory=$false)][switch]$RemoveDuplicates = $false
    )

    # Pre-Processing
    # Only want the initial snapshot of the Trusted Hosts
    Begin{
    
        # Retrieve current Trusted Hosts string
        Write-Verbose "Retrieving current list of Trusted Hosts"

        $TrustedHosts = Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction Stop | Select -ExpandProperty Value

        Write-Verbose "Initial Trusted Hosts: $TrustedHosts`n"
    
    }


    # Main processing block.
    # Add Trusted Host(s) via Set-Item and WSMan. Appends new hosts to the end of the Trusted Hosts string.
    Process{
    
        # Split list for checking supplied hosts against
        $TrustedHostsArr = $TrustedHosts.Split(',')


        # Boolean for keeping track of if the Trusted Host list is changed
        $ListChanged = $false


        # Boolean for keeping track of if duplicate has been/should be removed
        $Removable = $true


        # Remove the Hosts if they are present in the Trusted Hosts list
        Write-Verbose "Beginning Trusted Host removal...`n"

        ForEach($RemoveHost in $Hosts) {

            # Reset for each new host getting checked
            $Removable = $true


            Write-Verbose "Checking for $RemoveHost and removing if present"

            # For reference go to: https://stackoverflow.com/a/39921952
            $TrustedHostsArr = $TrustedHostsArr | ForEach-Object { 
                    if(($_ -eq $RemoveHost) -and $Removable) { 

                        # If not supposed to remove duplicates set removable flag to false
                        if($Removable -and (!$RemoveDuplicates)) {

                            $Removable = $false
                        
                        }


                        # Set flag indicating Trusted Host has been removed
                        $ListChanged = $true

                        Write-Verbose "$_ removed successfully" 

                    } else { $_ } 
                
                }            

        }

    }


    # Post-Processing
    # Only want to set the Trusted Hosts once if necessary
    End{
    
        Write-Verbose "`n"


        # Check if trusted hosts was modified, if not do nothing
        if($ListChanged) {
            
            # Rejoin Trusted Hosts
            $UpdatedHosts = [string]::Join(",", $TrustedHostsArr)


            # Add updated list to the computer
            Write-Verbose "Setting Trusted Hosts to $UpdatedHosts"


            # Set Trusted Hosts
            Set-Item "WSMan:\localhost\Client\TrustedHosts" -Value $UpdatedHosts -ErrorAction Stop -Credential $Credential
        
        } else {

            # Nothing changed
            Write-Verbose "Trusted Hosts unchanged"

        }
    
    }

}


# Testing
#Remove-TrustedHosts -Hosts "Host1", "HOST2", "HoSt4" -Credential(Get-Credential) -RemoveDuplicates -Verbose

#Remove-TrustedHosts "HOST1","hOsT3" -Credential (Get-Credential) -Verbose
