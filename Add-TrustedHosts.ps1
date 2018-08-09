#####
### CMDLET for adding trusted host(s) to your machine. If
### the host already exists it will not be added.
### Credential with adequate permissions must be supplied.
###
### Author: Weston Berg
### Date: Aug. 5, 2018
#####

Function Add-TrustedHosts {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)][string[]]$Hosts,
        [Parameter(Mandatory=$false, Position=1)][PSCredential]$Credential
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


        # Boolean for keeping track of if the Trusted Host is already present on the computer
        $Match = $false

        # Boolean for keeping track of if the Trusted Host list is changed
        $ListChanged = $false

        Write-Verbose "Beginning Trusted Host appending...`n"

        ForEach($AddHost in $Hosts) {

            # Check if the supplied host(s) is empty. If host is empty string do nothing; otherwise, check against current Trusted Hosts.
            if(!([string]::IsNullOrEmpty($AddHost))) {
                
                # Check current Trusted Hosts to make sure no duplicates are added
                Write-Verbose "Checking for match to $AddHost"

                ForEach($TrustedHost in $TrustedHostsArr) {

                    if([string]::Equals($AddHost.ToLower().Trim(), $TrustedHost.ToLower().Trim())) {

                        $Match = $true
                        break

                    }

                }

                # Only add if host is not already present
                if(!($Match)) {

                    Write-Verbose "No match, appending $AddHost`n"

                    # If this is the first Trusted Host don't add the comma
                    if($TrustedHosts.Length -eq 0) {

                        $TrustedHosts = $AddHost

                    } else {

                        $TrustedHosts = "$TrustedHosts, $AddHost"

                    }

                    $ListChanged = $true

                } else {

                    Write-Verbose "$AddHost matched and will not be appended`n"
                    $Match = $false

                }

            }

        }

    }


    # Post-Processing
    # Only want to set the Trusted Hosts once if necessary
    End{
    
        # Check if trusted hosts was modified, if not do nothing
        if($ListChanged) {
            
            # Add updated list to the computer
            Write-Verbose "Setting Trusted Hosts to $TrustedHosts"

            # PLEASE NOTE: Checking the length of the $TrustedHosts string was causing some very odd behavior. After looking here:
            # https://stackoverflow.com/questions/21860066/why-does-powershell-silently-convert-a-string-to-an-object-on-testing-length
            # I found a reason. This is why you see '$TrustedHosts.PSObject.BaseObject' instead of just '$TrustedHosts'. If Set-Item works
            # for you without using the PSObject feel free to modify this. I am running PowerShell V5.1 so not sure why this is affecting
            # me, but the fix worked so I'm keeping it for now.
            Set-Item "WSMan:\localhost\Client\TrustedHosts" -Value $TrustedHosts.PSObject.BaseObject -ErrorAction Stop -Credential $Credential
        
        } else {

            # Nothing changed
            Write-Verbose "Trusted Hosts unchanged"

        }
    
    }

}


#Testing
#Add-TrustedHosts -Hosts "zzz", "abc", "xxx" -Credential (Get-Credential) -Verbose

#"abc", "xyz", "def" | Add-TrustedHosts -Credential (Get-Credential) -Verbose 
