$listuri = "https://<storageaccountname>.blob.core.windows.net/sample?comp=list&prefix=sectionrate%2Fjson%2F&maxresults=1000&restype=container&include=metadata&delimiter=%2F&showonly=files&" + "<saswithoutquestionmark>"
$xmlresults = Invoke-RestMethod -Method 'Get' -Uri $listuri
$xmlresults.Replace('ï»¿','') > .\xmlresults.xml

$xmldoc = [xml](Get-Content .\xmlresults.xml)

$blobs = $xmldoc.SelectNodes("/EnumerationResults/Blobs/Blob")

$blobs | ForEach-Object -Parallel {
    $ctx = New-AzStorageContext -StorageAccountName '<storageaccountname>' -StorageAccountKey '<storageaccountkey>'
    $baseDirectory = "sectionrate/json/"
    $lastModified = Get-Date $_.Properties.'Last-Modified'
    $year = $lastModified.Year.ToString().PadLeft(2,'0')
	$month = $lastModified.Month.ToString().PadLeft(2,'0')
	$day = $lastModified.Day.ToString().PadLeft(2,'0')
	$hour = $lastModified.Hour.ToString().PadLeft(2,'0')
    $lastModifiedDirectory = "year="+$year+"/month="+$month+"/day="+$day+"/hour="+$hour+"/"
	$fullPath = $baseDirectory+$lastModifiedDirectory
	$oldPath = $_.name
	$newPath = $oldPath.Replace($baseDirectory,$fullPath)

    $copyuri = "https://<storageaccountname>.blob.core.windows.net/sample/" + $newpath + "<saswithquestionmark>"
    $deleteuri = "https://<storageaccountname>.blob.core.windows.net/sample/" + $oldPath + "<saswithquestionmark>"
    $copyheaders = @{
        'x-ms-date' = $lastModified
        'x-ms-version' = '2019-12-12'
        'x-ms-copy-source' = $deleteuri
        'Content-Length' = '0'
    }
    $deleteheaders = @{
        'x-ms-version' = '2019-12-12'
    }

    $folder = Get-AzDataLakeGen2Item -Context $ctx -FileSystem sample -Path $fullPath -ErrorAction SilentlyContinue

	if ($null -eq $folder)
	{
		New-AzDataLakeGen2Item -Context $ctx -FileSystem sample -Path $fullPath -Directory -Force
	}
	
	Move-AzDataLakeGen2Item -Context $ctx -FileSystem sample -Path $oldPath -DestFileSystem sample -DestPath $newPath -Force
} -ThrottleLimit 1000
       
