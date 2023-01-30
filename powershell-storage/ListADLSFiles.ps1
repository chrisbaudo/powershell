$webData = Invoke-RestMethod -Method 'Get' -Uri https://dlsadventureworksdev.dfs.core.windows.net/sample?recursive=false"&"directory=sectionrate/json"&"resource=filesystem"&"maxresults=5000"&"continuation=VBbHyL7z1daCkn4YgQEYfC9kbHNhZHZlbnR1cmV3b3Jrc2RldgEwMUQ4Q0Y1RjY0REZFNjEyL3NhbXBsZQEwMUQ4RDRFNjg4MUFCQ0RDL3NlY3Rpb25yYXRlL2pzb24vMDA1NWJjNjItMDFmNC0xMWVkLWIwM2QtYWFjZDM5ZjU3ZTEyNDQyLmpzb24WAAAA"&"sv=2020-02-10"&"st=2023-01-18T16%3A02%3A00Z"&"se=2023-01-19T16%3A02%3A00Z"&"sr=c"&"sp=racwdlme"&"sig=ZJAA%2BUA7%2Ftd8HOC7LhCqfMcFG7%2FH%2BEmHLB6jb1EzMO0%3D

$baseDirectory = "sectionrate/json/"
$ctx = New-AzStorageContext -StorageAccountName 'dlsadventureworksdev' -StorageAccountKey 'yeOtd1jk56+mNU3UI6pgP/9FqXDVTG2wlmdz4rv8gnWKNIaI0sLxwhUgOUazq27H6tmQ2xBqXQG8+AStIrrKag=='

foreach ($i in $webData.blobs | Where-Object {-not $_.isDirectory})
{
	$lastModified = Get-Date $i.lastModified
	$year = $lastModified.Year.ToString().PadLeft(2,'0')
	$month = $lastModified.Month.ToString().PadLeft(2,'0')
	$day = $lastModified.Day.ToString().PadLeft(2,'0')
	$hour = $lastModified.Hour.ToString().PadLeft(2,'0')
	$lastModifiedDirectory = "year="+$year+"/month="+$month+"/day="+$day+"/hour="+$hour+"/"
	$fullPath = $baseDirectory+$lastModifiedDirectory
	$oldPath = $i.name
	$newPath = $oldPath.Replace($baseDirectory,$fullPath)

	$folder = Get-AzDataLakeGen2Item -Context $ctx -FileSystem sample -Path $fullPath -ErrorAction SilentlyContinue

	if ($null -eq $folder)
	{
		New-AzDataLakeGen2Item -Context $ctx -FileSystem sample -Path $fullPath -Directory -Force
	}
	
	Move-AzDataLakeGen2Item -Context $ctx -FileSystem sample -Path $oldPath -DestFileSystem sample -DestPath $newPath -Force
}