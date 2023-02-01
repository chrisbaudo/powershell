# Call the blob storage API which returns file list results in XML format
$sas = "sv=2021-10-04&st=2023-02-01T20%3A39%3A02Z&se=2023-02-02T20%3A39%3A02Z&sr=c&sp=rl&sig=XSuiF0z6g%2FfWgov2GVwEgMGBEWJDMqEWGz9uVO7kR%2B4%3D"
$listuri = "https://dlsadventureworksdev.blob.core.windows.net/sample?comp=list&prefix=sectionrate%2Fjson%2F&maxresults=1000&restype=container&include=metadata&delimiter=%2F&showonly=files&where=Last-Modified+%3e+%272023-02-01" + "&" + $sas
$xmlresults = Invoke-RestMethod -Method 'Get' -Uri $listuri
$xmlresults.Replace('ï»¿','') > .\xmlresults.xml

$xmldoc = [xml](Get-Content .\xmlresults.xml)

# Iterate over each blob and perform operations in parallel
$blobs = $xmldoc.SelectNodes("/EnumerationResults/Blobs/Blob")

$blobs | ForEach-Object -Parallel {
    # Move files from the "baseDirectory" below to a timestamp folder based on last modified date
    $baseUrl = "https://dlsadventureworksdev.blob.core.windows.net/sample/"
    $baseDirectory = "sectionrate/json/"
    $timezone = 'Central Standard Time'
    $sas = "?sv=2020-02-10&st=2023-02-01T20%3A46%3A32Z&se=2023-02-02T20%3A46%3A32Z&sr=c&sp=racwdlme&sig=p8tQuj49fGvOVHgNY%2F9KxsUrxi12j75B6ykE7Ixp3eY%3D"
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


       