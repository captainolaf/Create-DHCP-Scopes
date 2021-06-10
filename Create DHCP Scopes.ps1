##########
# Setting up Parameters
##########
param
(
	[string]$server,
	[string]$file
)

##########
# Global Variables
##########
$global:FILE = $file
$global:SERVER = $server

##########
# Check that file exists
##########
function FileCheck
{

    if (($global:FILE.Length -eq 0) -or (-not (test-path $file)))
    {
		do
		{
		
			 $global:FILE = read-host "Enter name of file or path to file containing new DHCP scopes to be built"
		}
		
		until (test-path $global:FILE)
        
    }
	

    ServerCheck($server)
}

##########
# Check that server is reachable
##########
Function ServerCheck
{
    if (($global:SERVER.Length -eq 0) -or (-not (test-connection -computername  $global:SERVER -count 1 -erroraction silentlycontinue)))
    {

        do 
		    {
			     $global:SERVER = read-host "Enter name of DHCP server"
		    }
		
		until (test-connection -computername $global:SERVER -count 1 -erroraction silentlycontinue)

    }
	
    ScopeCreate

}

##########
# Import scope(s) data from file and create scopes on server
##########
Function ScopeCreate
{

    $csv = import-csv $global:FILE

    $configuredScopes = Get-DhcpServerv4Scope -ComputerName $global:SERVER
	
	LogAndDisplay( "Creating DHCP Scopes on $global:SERVER")

    $csv | ForEach-Object{

        if ($configuredScopes.ScopeId -contains $_.ScopeID)

            {

            LogAndDisplay("$_.Scope already configured on $global:SERVER")

            }
        
        else{

            $DnsArray = $_.DNS1,$_.DNS2,$_.DNS3

            $ScopeCreate = @{

                'ComputerName' = $global:SERVER;
	            'Name' = $_.Name;
	            'StartRange' = [ipaddress]$_.StartRange;
	            'EndRange' = [ipaddress]$_.EndRange;
	            'SubnetMask' = [ipaddress]$_.Subnet;
	            'Description' = $_.Description;
                'LeaseDuration' = '0.08:00:00';
                'State' = 'Active';
                }

		    Add-DhcpServerv4Scope @ScopeCreate

            LogAndDisplay("$_.name added")

            LogAndDisplay("Setting DHCP Options:")

            $ScopeOptions = @{

                'ComputerName' = $global:SERVER;
                'ScopeId' = [ipaddress]$_.ScopeID;
                'Router' = [ipaddress]$_.Gateway;
                'DnsDomain' = $_.Domain;
                'DnsServer' = $DnsArray;

                }

            Set-DhcpServerv4OptionValue @ScopeOptions 

            LogAndDisplay("$_.Name options added")

            if (($_.ExcludeStart.length -ne 0) -and ($_.ExcludeEnd.length -ne 0))
            {

                $Exclusions = @{

                    'ComputerName' = $global:SERVER;
                    'ScopeID' = [ipaddress]$_.ScopeID;
                    'StartRange' = [ipaddress]$_.ExcludeStart;
                    'EndRange' = [ipaddress]$_.ExcludeEnd;

                }

                LogAndDisplay("Setting Exlusions")

                Add-DhcpServerv4ExclusionRange @Exclusions

                LogAndDisplay("$_.Name exlusions added")

            }

        }

	    
    }


}

##########
# Log
##########
Function LogAndDisplay
{
	Param ($msg)
	
	Write-Output $msg

	$msg | Add-Content $outputFile
}

$runDate = $((Get-Date).ToString("yyyyMMdd_HHmmss"))
$outputFile = "C:\tmp\Create_DCHP_Scopes_$runDate.log"
FileCheck ($file, $server)