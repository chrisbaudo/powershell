$connectionString = "Provider=MSOLAP;Data Source=asazure://centralus.asazure.windows.net/psinsightsasprod01;Initial Catalog=CES_GCPMSelfServe;";
$query = "EVALUATE(FILTER('Request Details', RELATED('Sales Geography'[Sales EOU])=""USA - SLG""))"

$filename = "requestdetails.csv"
 
$connection = New-Object -TypeName System.Data.OleDb.OleDbConnection

$connection.ConnectionString = $connectionString
$command = $connection.CreateCommand()
$command.CommandText = $query
$adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $command
$dataset = New-Object -TypeName System.Data.DataSet
$adapter.Fill($dataset)

$dataset.Tables[0] | export-csv $filename -notypeinformation
  
$connection.Close()

./azcopy.exe copy "C:\Users\chbaudo\GCPMScripts\$filename" "https://dlsgcpmselfserve.blob.core.usgovcloudapi.net/gcpmselfserve?sv=2020-02-10&st=2023-01-26T17%3A10%3A46Z&se=2023-01-27T17%3A10%3A46Z&sr=c&sp=racwdlme&sig=aqjyreOJTxo3SMq9Mi29lEa%2BTSLMpwXWn%2F%2BnQForWcw%3D" --overwrite=true --from-to=LocalBlob --blob-type BlockBlob --follow-symlinks --put-md5 --follow-symlinks --disable-auto-decoding=false --recursive --log-level=INFO;