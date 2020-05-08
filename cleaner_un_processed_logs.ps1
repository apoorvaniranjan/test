#######################################
# Directory path for the source
# Value: "C:\Program Files\LogRhythm\LogRhythm Mediator Server\state\SpooledEvents_HOLD"  or  "C:\Program Files\LogRhythm\LogRhythm Mediator Server\state\SpooledLogs_HOLD"
$Source = "C:\Program Files\LogRhythm\LogRhythm Mediator Server\state\UnprocessedLogs-old"

# Directory path for the destination
# Values: "C:\Program Files\LogRhythm\LogRhythm Mediator Server\state\SpooledEvents" or "C:\Program Files\LogRhythm\LogRhythm Mediator Server\state\SpooledLogs"
$Destination = "C:\Program Files\LogRhythm\LogRhythm Mediator Server\state\UnprocessedLogs"

# Number of files to move from source to dest at a time.
# Values: Int, default is 5 
$FileLimit = 3

# Number of seconds to sleep before looking to see if the dest directory is empty.
# Values: Int, default is 60
$SleepTime = 30

# Path to Anubis.log
$Anubis = "C:\Program Files\LogRhythm\Data Indexer\logs\anubis.log"

$Path = "C:\LogRhythm\GW.txt"

#######################################

$Now = Get-Date
$originationInfo = Get-ChildItem $Source | Measure-Object
Write-Host $Now, "Files in HOLD:", $originationInfo.count -foregroundcolor "red" #Returns the count of all of the files in the directory

while ('$originationInfo.count -noteq 0')
{

$Now = Get-Date
$destinationInfo = Get-ChildItem $Destination | Measure-Object


Get-Content $Anubis -Tail 10 > $Path
$gw = select-string -Path $Path -Pattern '\d{9}' | % { $_.Matches } | % { $_.Value }


Write-Host $Now, "Files in process:" $destinationInfo.count "Gigawatt Size:" $gw -foregroundcolor "yellow" #Returns the count of all of the files in the directory

If ($destinationInfo.count -gt 10)
{
$text = "$(Get-Date): Moved files back"
$text >> 'C:\LogRhythm\GWlog.log'
}


If (($gw -lt 300000000) -or ($gw -eq 500000000))
	{
	If ($destinationInfo.count -eq 0)
		{    
		$DestCount = Get-ChildItem $Source | Measure-Object
        Get-Content $Anubis -Tail 10 > $Path
        $gw = select-string -Path $Path -Pattern '\d{9}' | % { $_.Matches } | % { $_.Value }
		if ($DestCount.count -eq 1)
		{
			Write-Host "***File Move Complete***" -foregroundcolor "white"
			exit
		}
	 
		Write-Host $Now, "Moving" $FileLimit "for processing." -foregroundcolor "green"
        
		#Destination for files 
		$PickupDirectory = Get-ChildItem -Path $Source         
	             
			$Counter = 0 
			foreach ($file in $PickupDirectory) {     
			if ($Counter -ne $FileLimit)     
			{        	    
				Write-Host $file.FullName -foregroundcolor "green" #Output file fullname to screen      	          
				Move-Item $file.FullName -destination $Destination         
				$Counter++	    
				}   
			} 
		$originationInfo = Get-ChildItem $Source | Measure-Object
		Write-Host $Now, "Files in HOLD:", $originationInfo.count -foregroundcolor "red"
        Get-Content $Anubis -Tail 10 > $Path
        $gw = select-string -Path $Path -Pattern '\d{9}' | % { $_.Matches } | % { $_.Value }
	}
		Start-Sleep -s $SleepTime 
	}
}
Exit