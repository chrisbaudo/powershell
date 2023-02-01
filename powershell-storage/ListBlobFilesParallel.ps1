$sas = "<saswithoutquestionmark>"
$listuri = "https://<storageaccountname>.blob.core.windows.net/sample?comp=list&prefix=sectionrate%2Fjson%2F&maxresults=1000&restype=container&include=metadata&delimiter=%2F&showonly=files&where=Last-Modified+%3e+%272023-02-01" + "&" + $sas
$xmlresults = Invoke-RestMethod -Method 'Get' -Uri $listuri
$xmlresults.Replace('ï»¿','') > .\xmlresults.xml

$xmldoc = [xml](Get-Content .\xmlresults.xml)

$blobs = $xmldoc.SelectNodes("/EnumerationResults/Blobs/Blob")

$blobs | ForEach-Object -Parallel {
    $baseDirectory = "sectionrate/json/"
    $timezone = 'Central Standard Time'
    $lastModified = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date $_.Properties.'Last-Modified' -AsUTC), $timezone)
    $year = $lastModified.Year.ToString().PadLeft(2,'0')
	$month = $lastModified.Month.ToString().PadLeft(2,'0')
	$day = $lastModified.Day.ToString().PadLeft(2,'0')
	$hour = $lastModified.Hour.ToString().PadLeft(2,'0')
    $lastModifiedDirectory = "year="+$year+"/month="+$month+"/day="+$day+"/hour="+$hour+"/"
	$fullPath = $baseDirectory+$lastModifiedDirectory
	$oldPath = $_.name
	$newPath = $oldPath.Replace($baseDirectory,$fullPath)

    # This is the destination
    $copyuri = "https://<storageaccountname>.blob.core.windows.net/sample/" + $newpath + "<saswithquestionmark>"
    # This is the source
    $deleteuri = "https://<storageaccountname>.blob.core.windows.net/sample/" + $oldPath + "<saswithquestionmark"

    Write-Host "The current location is " $deleteuri
    Write-Host "The new location will be " $copyuri
} -ThrottleLimit 1000
       
