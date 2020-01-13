
#Adds key value pairs to an existing variable group in Azure DevOps

$FilePath = "CompiledAppSettings.csv" #Path to csv file with app setting values and variable name
$groupID = ""
$organisationLink = ""
$projectName = ""

$CsvContent = Get-Content -Path $FilePath | ConvertFrom-Csv
    
    foreach($settings in $CsvContent)
    {
        $settings.value = "`"" +  $settings.value + "`""
        
        write-host $settings.variablename
        az pipelines variable-group variable create --group-id $groupID --name $settings.variablename --secret false --value $settings.value --org $organisationLink --project $projectName                                             
    }

