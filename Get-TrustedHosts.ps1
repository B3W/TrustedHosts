#####
### CMDLET for retrieving the trusted hosts from a machine
### Testing still needs done for remote computers
###
### Author: Weston Berg
### Date: Aug. 5, 2018
#####

Function Get-TrustedHosts {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string[]]$ComputerName,
        [parameter(Mandatory=$true)]
        [PSCredential]$Credential
    )

    # Pre-Processing
    Begin{}

    # Main processing block.
    # Get the Trusted Hosts from WSMan and 'return' them as output
    Process{
    
        # Test network connection to the computer 
        Write-Verbose "Checking connection to $ComputerName..."

        if(Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {

             Write-Verbose "Connection to $ComputerName verified`n"

            try {
 
                # Open PowerShell Session
                Write-Verbose "Creating PowerShell session..."

                try {

                    $PsSession = New-PSSession -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop 

                } catch {

                    Write-Host "Error occurred during creation of PowerShell session" -ForegroundColor Red

                    # Throw error to outer catch
                    throw

                }

                Write-Verbose "PowerShell session created successfully!`n"

 
                # Retrieve Trusted Hosts
                Write-Verbose "Retrieving Trusted Hosts from $ComputerName..."

                try {

                    $RemoteHosts = Invoke-Command -Session $PsSession -ErrorAction Stop -ScriptBlock 
                        { 
                            # Get the Trusted Hosts list from WSMan
                            $TrustedHosts = Get-Item WSMan:\localhost\Client\TrustedHosts | Select -ExpandProperty Value
    
                            # Format the output
                            $Output = "$ComputerName : $TrustedHosts"

                            $Output 
                        }

                    $RemoteHosts

                } catch { 

                    Write-Host "Error while retrieving Trusted Hosts from $ComputerName" -ForegroundColor Red

                    # Remove PowerShell session before exiting
                    Remove-PSSession $PsSession

                    # Throw error to outer catch
                    throw

                }

                Write-Verbose "Trusted Hosts retrieved successfully`n"


                # Remove the PowerShell session
                Write-Verbose "Removing PowerShell session...`n" 

                try {

                    Remove-PSSession $PsSession -ErrorAction Stop

                } catch {

                    Write-Host "Error while removing PowerShell session" -ForegroundColor Red

                    # Throw error to outer catch
                    throw

                }

                Write-Verbose "PowerShell session removed`n" 

            } catch {

                # Display error
                Write-Host $Error[0] -ForegroundColor Red

            }
 

        } else {

            Write-Verbose "Unable to connect to machine $ComputerName"

            "$ComputerName : Unable To Connect"

        }

    }

    # Post-Processing
    End{}

}

# Testing
"localhost", "localhost" | Get-TrustedHosts -Credential (Get-Credential) -Verbose