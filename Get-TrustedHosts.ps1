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
        [string[]]$ComputerName
    )

    # Pre-Processing
    Begin{}

    # Main processing block.
    # Get the Trusted Hosts from WSMan and 'return' them as output
    Process{
    
        # Get the Trusted Hosts list from WSMan
        $TrustedHosts = Get-Item WSMan:\$ComputerName\Client\TrustedHosts | Select -ExpandProperty Value
    
        # Format the output
        $Output = "$ComputerName : $TrustedHosts"

        $Output

    }

    # Post-Processing
    End{}

}

# Testing
"localhost", "localhost" | Get-TrustedHosts