$listuri = "https://dlsadventureworksdev.blob.core.windows.net/sample?comp=list&prefix=sectionrate%2Fjson%2F&maxresults=1000&restype=container&include=metadata&delimiter=%2F&showonly=files&" + "sv=2020-02-10&st=2023-01-30T15%3A32%3A18Z&se=2023-01-31T15%3A32%3A18Z&sr=c&sp=racwdlme&sig=Bsakh3X%2BKLMFjmh8%2BR7VScuOGjQ5%2FsGoXzIe2w5W5mY%3D"
$xmlresults = Invoke-RestMethod -Method 'Get' -Uri $listuri
$xmlresults.Replace('ï»¿','') > .\xmlresults.xml

$xmldoc = [xml](Get-Content .\xmlresults.xml)

$blobs = $xmldoc.SelectNodes("/EnumerationResults/Blobs/Blob")

$blobs | ForEach-Object -Parallel {
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

    $copyuri = "https://dlsadventureworksdev.blob.core.windows.net/sample/" + $newpath + "?sv=2020-02-10&st=2023-01-30T15%3A32%3A18Z&se=2023-01-31T15%3A32%3A18Z&sr=c&sp=racwdlme&sig=Bsakh3X%2BKLMFjmh8%2BR7VScuOGjQ5%2FsGoXzIe2w5W5mY%3D"
    $deleteuri = "https://dlsadventureworksdev.blob.core.windows.net/sample/" + $oldPath + "?sv=2020-02-10&st=2023-01-30T15%3A32%3A18Z&se=2023-01-31T15%3A32%3A18Z&sr=c&sp=racwdlme&sig=Bsakh3X%2BKLMFjmh8%2BR7VScuOGjQ5%2FsGoXzIe2w5W5mY%3D"

    Write-Host "The current location is " $deleteuri
    Write-Host "The new location will be " $copyuri
} -ThrottleLimit 1000
       
