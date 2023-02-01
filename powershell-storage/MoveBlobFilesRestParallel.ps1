# Call the blob storage API which returns file list results in XML format
$sas = "<saswithoutquestionmark>"
$listuri = "https://<storageaccountname>.blob.core.windows.net/sample?comp=list&prefix=sectionrate%2Fjson%2F&maxresults=1000&restype=container&include=metadata&delimiter=%2F&showonly=files&where=Last-Modified+%3e+%272023-02-01" + "&" + $sas
$xmlresults = Invoke-RestMethod -Method 'Get' -Uri $listuri
$xmlresults.Replace('ï»¿','') > .\xmlresults.xml

$xmldoc = [xml](Get-Content .\xmlresults.xml)

# Iterate over each blob and perform operations in parallel
$blobs = $xmldoc.SelectNodes("/EnumerationResults/Blobs/Blob")

$blobs | ForEach-Object -Parallel {
    # Move files from the "baseDirectory" below to a timestamp folder based on last modified date
    $baseUrl = "https://<storageaccountname>.blob.core.windows.net/sample/"
    $baseDirectory = "sectionrate/json/"
    $timezone = 'Central Standard Time'
    $sas = "<saswithquestionmark>"
    $lastModified = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date $_.Properties.'Last-Modified' -AsUTC), $timezone)
    $year = $lastModified.Year.ToString().PadLeft(2,'0')
	$month = $lastModified.Month.ToString().PadLeft(2,'0')
	$day = $lastModified.Day.ToString().PadLeft(2,'0')
	$hour = $lastModified.Hour.ToString().PadLeft(2,'0')
    $lastModifiedDirectory = "year="+$year+"/month="+$month+"/day="+$day+"/hour="+$hour+"/"
	$fullPath = $baseDirectory+$lastModifiedDirectory
	$oldPath = $_.name
	$newPath = $oldPath.Replace($baseDirectory,$fullPath)

    $copyuri = $baseUrl + $newpath + $sas
    $deleteuri = $baseUrl + $oldPath + $sas
    $copyheaders = @{
        'x-ms-date' = $lastModified
        'x-ms-version' = '2019-12-12'
        'x-ms-copy-source' = $deleteuri
        'Content-Length' = '0'
    }
    $deleteheaders = @{
        'x-ms-version' = '2019-12-12'
    }

    # Try the copy first and only delete the file if the copy is successful
    try {
        $copy = Invoke-RestMethod -Uri $copyuri -Method Put -Headers $copyheaders # Adding a variable to absorb blank spaces from the call
        Write-Host "Copy succeeded for blob " $oldPath

        try {
            $delete = Invoke-RestMethod -Uri $deleteuri -Method Delete -Headers $deleteheaders # Adding a variable to absorb blank spaces from the call
            Write-Host "Delete succeeded for blob " $oldPath
        }
        catch {
            Write-Host "Delete failed for blob: " $oldPath
        }
    }
    catch {
        Write-Host "Copy failed for blob: " $oldPath
    }
} -ThrottleLimit 1000


       
