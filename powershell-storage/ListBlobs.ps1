#Set variables
$namedContainer  = "sample"
$demoContainer   = "sample"
$containerPrefix = "*.json"

$maxCount = 10
$total     = 0
$token     = $Null

#Approach 1: List all blobs in a named container
#Get-AzStorageBlob -Container $namedContainer -Context $ctx

#Approach 2: Use a wildcard to list blobs in all containers
#Get-AzStorageContainer -MaxCount 5 -Context $ctx | Get-AzStorageBlob -Blob "*louis*.jpg" 

#Approach 3: List batches of blobs using MaxCount and ContinuationToken parameters
Do
{
     #Retrieve blobs using the MaxCount parameter
     $blobs = Get-AzStorageBlob -Container $demoContainer `
         -MaxCount $maxCount `
         -ContinuationToken $token `
         -Context $ctx
     $blobCount = 1
     
     #Loop through the batch
     Foreach ($blob in $blobs)
     {
         #To-do: Perform some work on individual blobs here

         #Display progress bar
         $percent = $($blobCount/$maxCount*100)
         Write-Progress -Activity "Processing blobs" -Status "$percent% Complete" -PercentComplete $percent
         $blobCount++
     }

     #Update $total
     $total += $blobs.Count
      
     #Exit if all blobs processed
     If($blobs.Length -le 0) { Break; }
      
     #Set continuation token to retrieve the next batch
     $token = $blobs[$blobs.Count -1].ContinuationToken
 }
 While ($null -ne $token)
 Write-Host "`n`n   AccountName: $($ctx.StorageAccountName), ContainerName: $demoContainer `n"
 Write-Host "Processed $total blobs in $namedContainer."