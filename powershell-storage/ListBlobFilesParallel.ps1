$sas = "sv=2021-10-04&st=2023-02-01T20%3A39%3A02Z&se=2023-02-02T20%3A39%3A02Z&sr=c&sp=rl&sig=XSuiF0z6g%2FfWgov2GVwEgMGBEWJDMqEWGz9uVO7kR%2B4%3D"
$listuri = "https://dlsadventureworksdev.blob.core.windows.net/sample?comp=list&prefix=sectionrate%2Fjson%2F&maxresults=1000&restype=container&include=metadata&delimiter=%2F&showonly=files&where=Last-Modified+%3e+%272023-02-01" + "&" + $sas
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
    $copyuri = "https://dlsadventureworksdev.blob.core.windows.net/sample/" + $newpath + "?sv=2021-10-04&st=2023-01-31T16%3A36%3A17Z&se=2023-02-01T16%3A36%3A17Z&sr=c&sp=rl&sig=syRPlDdaZWVAivOvbRN7vfMeqoKoIZmspX%2FlYlUgeik%3D"
    # This is the source
    $deleteuri = "https://dlsadventureworksdev.blob.core.windows.net/sample/" + $oldPath + "?sv=2021-10-04&st=2023-01-31T16%3A36%3A17Z&se=2023-02-01T16%3A36%3A17Z&sr=c&sp=rl&sig=syRPlDdaZWVAivOvbRN7vfMeqoKoIZmspX%2FlYlUgeik%3D"

    Write-Host "The current location is " $deleteuri
    Write-Host "The new location will be " $copyuri
} -ThrottleLimit 1000
       