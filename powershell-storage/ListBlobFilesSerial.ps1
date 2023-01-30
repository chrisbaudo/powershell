$xmlresults = Invoke-RestMethod -Method 'Get' -Uri https://dlsadventureworksdev.blob.core.windows.net/sample?comp=list"&"prefix=sectionrate%2Fjson%2F"&"maxresults=1000"&"restype=container"&"include=metadata"&"delimiter=%2F"&"showonly=files"&"sv=2021-10-04"&"st=2023-01-27T15%3A19%3A49Z"&"se=2023-01-28T15%3A19%3A49Z"&"sr=c"&"sp=rl"&"sig=EUFRHc4ioCabi4x2lrwnct4FiwOakrltIz0O7AJMin4%3D
$xmlresults.Replace('ï»¿','') > .\xmlresults.xml

$xmldoc = [xml](Get-Content .\xmlresults.xml)

$ctx = New-AzStorageContext -StorageAccountName 'dlsadventureworksdev' -StorageAccountKey 'yeOtd1jk56+mNU3UI6pgP/9FqXDVTG2wlmdz4rv8gnWKNIaI0sLxwhUgOUazq27H6tmQ2xBqXQG8+AStIrrKag=='
$blobs = $xmldoc.SelectNodes("/EnumerationResults/Blobs/Blob")
$baseDirectory = "sectionrate/json/"

foreach ($i in $blobs) {
    $lastModified = Get-Date $i.Properties.'Last-Modified'
    $year = $lastModified.Year.ToString().PadLeft(2,'0')
	$month = $lastModified.Month.ToString().PadLeft(2,'0')
	$day = $lastModified.Day.ToString().PadLeft(2,'0')
	$hour = $lastModified.Hour.ToString().PadLeft(2,'0')
    $lastModifiedDirectory = "year="+$year+"/month="+$month+"/day="+$day+"/hour="+$hour+"/"
	$fullPath = $baseDirectory+$lastModifiedDirectory
	$oldPath = $i.name
	$newPath = $oldPath.Replace($baseDirectory,$fullPath)

    $copyuri = "https://dlsadventureworksdev.blob.core.windows.net/sample/" + $newpath + "?sv=2020-02-10&st=2023-01-27T23%3A59%3A43Z&se=2023-01-28T23%3A59%3A43Z&sr=c&sp=racwdlme&sig=iWwxFWxHI5VJ%2ByrgAJVLFIVp%2BrWZmXDpAulsKjhGoM0%3D"
    $deleteuri = "https://dlsadventureworksdev.blob.core.windows.net/sample/" + $oldPath + "?sv=2020-02-10&st=2023-01-27T23%3A59%3A43Z&se=2023-01-28T23%3A59%3A43Z&sr=c&sp=racwdlme&sig=iWwxFWxHI5VJ%2ByrgAJVLFIVp%2BrWZmXDpAulsKjhGoM0%3D"
    $copyheaders = @{
        'x-ms-date' = $lastModified
        'x-ms-version' = '2019-12-12'
        'x-ms-copy-source' = $deleteuri
        'Content-Length' = '0'
    }
    $deleteheaders = @{
        'x-ms-version' = '2019-12-12'
    }

    try {
        Invoke-RestMethod -Uri $copyuri -Method Put -Headers $copyheaders
        Invoke-RestMethod -Uri $deleteuri -Method Delete -Headers $deleteheaders
        Write-Host "Move succeeded for blob " + $deleteuri
    }
    catch {
        Write-Host "Move failed for blob: " + $deleteuri
    }

    #$folder = Get-AzDataLakeGen2Item -Context $ctx -FileSystem sample -Path $fullPath -ErrorAction SilentlyContinue

	#if ($null -eq $folder)
	#{
		#New-AzDataLakeGen2Item -Context $ctx -FileSystem sample -Path $fullPath -Directory -Force
	#}
	
	#Move-AzDataLakeGen2Item -Context $ctx -FileSystem sample -Path $oldPath -DestFileSystem sample -DestPath $newPath -Force
}




