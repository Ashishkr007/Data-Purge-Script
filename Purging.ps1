# Set the default reference directory 
$rootdir = "E:\"
 
#path for the Purge files
[string]$sourcepath = $args[0]
 
##path for the Purge folders
[string]$processingpath = $args[1]
 
# Day count to delete the files
$daycount = $args[2]
 
# Return value for success and failure
$returnvalue
 
##Tendays old file Date setup
[string]$olderfiledaycount = (Get-Date).AddDays($daycount)
 
# Set the Log File Path
$logpath = "$($rootdir)\Purging\Logging\Purge\"
 
# Set the current Date
$CurrentDate = (Get-Date)
 
# Converting the date to string
$CurrentDate = $CurrentDate.ToString('MM-dd-yyyy_hh-mm-ss')
 
# Set the log file path
$logfilepath = "$($logpath)Log_$($CurrentDate).log"
 
Write-Output "********Files/Folders Deletion Log***********" >> $logfilepath
 
#To get the measure of the file
$filecount = Get-ChildItem $sourcepath -Recurse | Where-Object {!$_.PSIsContainer -and $_.LastWriteTime -lt $olderfiledaycount}
$measurefiles = $filecount | Measure-Object
 
#Purge the older files if the files are greater than zero
if(($measurefiles).count -gt 0 -and $sourcepath -ne '')
 
{
try {
Write-Output "------------------------------" >> $logfilepath
Write-Output "$(get-date) - File Deletion started" >> $logfilepath
Write-Output "------------------------------" >> $logfilepath
$Files = Get-ChildItem $sourcepath -Recurse | Where-Object {!$_.PSIsContainer -and $_.LastWriteTime -lt $olderfiledaycount} | 
ForEach-Object {
		$file = $_
		Remove-Item -Recurse $file.fullname -ErrorAction Stop 
		$returnvalue = +1
		$lasttimefile = $file.LastWriteTime
		$filelog = $file | select -Expand FullName
		Write-Output "Deleted Files: $($filelog) $($lasttimefile)" >> $logfilepath      
		}
	} catch {
		$returnvalue = -1
		Add-Content $logfilepath "`nError deleting file: $file, $_"
		Write-Output "------------------------------" >> $logfilepath
		Write-Output "Exception:File Deletion:" >> $logfilepath
		Write-Output "------------------------------" >> $logfilepath
		Add-Content $logfilepath "`nError deleting file path: $file, $_"
		$ErrorMessage = $_.Exception.Message >> $logfilepath
		$FailedItem = $_.Exception.ItemName >> $logfilepath
		Write-Output $($CurrentDate)  >> $logfilepath
	Write-Output "************************`r`n`r`n" >> $logfilepath         
    }
}else{
	if(($measurefiles).count -eq 0 -and $sourcepath -ne ''){
		Write-Output "$(get-date) - File Deletion started " >> $logfilepath
		Write-Output "No files found" >> $logfilepath
		$returnvalue = 0
		}
		else{}
	}
$foldercount = Get-ChildItem $processingpath -Recurse | Where-Object {$_.PSIsContainer -and $_.Name -like "20*" -and $_.LastWriteTime -lt $olderfiledaycount}
$measurefolders = $foldercount | Measure-Object
 
#Purge the older folders if the folders are greater than zero
 
if(($measurefolders).count -gt 0  -and $processingpath -ne '')
{
	try {
	Write-Output "------------------------------" >> $logfilepath
	Write-Output "$(get-date) - Folder Deletion started" >> $logfilepath
	Write-Output "------------------------------" >> $logfilepath
	 
	$Folders = Get-ChildItem $processingpath -Recurse | Where-Object {$_.PSIsContainer -and $_.Name -like "20*" -and $_.LastWriteTime -lt $olderfiledaycount} |
	ForEach-Object {
    $folder = $_
	Remove-Item -Recurse $folder.fullname -ErrorAction Stop  
	$returnvalue = +1
	$lasttimefolder = $folder.LastWriteTime
	$folderlog = $folder | select -Expand FullName
	Write-Output "Deleted Folders: $($folderlog) $($lasttimefolder)" >> $logfilepath
         
    } }catch {
		$returnvalue = -1
		Write-Output "------------------------------" >> $logfilepath
		Write-Output "Exception:Folder Deletion:" >> $logfilepath
		Write-Output "------------------------------" >> $logfilepath
		Add-Content $logfilepath "`nError deleting folder path: $folder, $_"
		$ErrorMessage = $_.Exception.Message >> $logfilepath
		$FailedItem = $_.Exception.ItemName >> $logfilepath
		Write-Output $($CurrentDate)  >> $logfilepath
		Write-Output "************************`r`n`r`n" >> $logfilepath
    }
}
else
{
	if(($measurefolders).count -eq 0 -and $processingpath -ne ''){
		Write-Output "$(get-date) - File Deletion started" >> $logfilepath
		Write-Output "No folders found" >> $logfilepath
		$returnvalue = 0
	}
	else
	{}
}
#sucess/Failure log
Write-Output "*******************" >> $logfilepath
if($returnvalue -eq 1){
Write-Output "$(get-date) - Files/Folders are deleted successfully" >> $logfilepath

}
elseif($returnvalue -eq -1){
Write-Output "$(get-date) - Failed to delete the $daycount older Files/Folders" >> $logfilepath
}
 
#job suceess/failure return message
if ($returnvalue -eq -1) {
		exit $returnvalue
	} else {
		exit 0
	}
