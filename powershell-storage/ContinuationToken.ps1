$storageAccountName = "<storageaccountname>"
$resourceGroupName = "<resourcegroupname>"
#--------------------------------------------------

$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName
$ctx = $storageAccount.Context
$filesystem = "sample"
$dirname = "sectionrate"
$maxcount = 5000
	
$TotalSize = 0
$Token = $Null
$items = $Null
do
	{
		$items += Get-AzDataLakeGen2ChildItem -context $ctx -FileSystem $filesystem -Path $dirname -MaxCount $maxcount -ContinuationToken $Token
		if($items.Length -le 0) { Break;}
		$Token = $items[$items.Count -1].ContinuationToken;
	}
while ($Token -ne $Null)
	
# $items.Count
$items | ForEach-Object {
	$TotalSize += $_.Length
	Write-Host $_.Name
}
# $TotalSize
Write-Host "Directory: $dirname | TotalSize: $TotalSize | TotalObjects:" $items.Count
