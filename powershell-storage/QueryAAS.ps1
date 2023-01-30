$connectionString = "Provider=MSOLAP;Data Source=asazure://centralus.asazure.windows.net/psinsightsasprod01;Initial Catalog=CES_GCPMSelfServe;";
$query = "EVALUATE(FILTER('Project Request', RELATED('Sales Geography'[Sales EOU])=""USA - SLG""))"

$filename = "projectrequest.csv"
 
$connection = New-Object -TypeName System.Data.OleDb.OleDbConnection

$connection.ConnectionString = $connectionString
$command = $connection.CreateCommand()
$command.CommandText = $query
$adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $command
$dataset = New-Object -TypeName System.Data.DataSet
$adapter.Fill($dataset)

$dataset.Tables[0] | export-csv $filename -notypeinformation
  
$connection.Close()