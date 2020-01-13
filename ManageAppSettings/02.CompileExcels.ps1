

$folderpath = "Folder path of csv files"
$FilePath = "ListOfFunctions.txt" #Path of file with function names list


function CompileAllExcels($folderpath, $FilePath)
{

    $ListofFunctions = (Get-Content -Path $FilePath).Split("`n")
    
    $settingName = $null
    $variableName = $null
    $variableValue = $null

    foreach($FunctionName in $ListofFunctions)
    {
        #$FunctionName = ($func -split $projectNameSplit)[1]

        $csvFilePath = $folderpath + "\" + $FunctionName

        $CsvContent = Get-Content -Path $csvFilePath | ConvertFrom-Csv

        $settingName = $settingName + $CsvContent.name

        $variableName = $variableName + $CsvContent.variableName

        $variableValue = $variableValue + $CsvContent.value

    }

    #List Duplicate variable names
    $uniqueVariableNames= $variableName | select –unique
    Compare-object –referenceobject $uniqueVariableNames –differenceobject $variableName

    #creating object to output in csv file
    if($settingName.count -eq $variableValue.count)
    {
    $csv = For ($i = 0; $i -lt $settingName.count; $i++) 
        {
            New-Object -TypeName psobject -Property @{
            'name' = $(If ($settingName[$i]) { $settingName[$i] })
            'variableName' = $(If ($variableName[$i]) { $variableName[$i] })
            'Value' = $(If ($variableValue[$i]) { $variableValue[$i] })
            }
        }
    }

    $csv | Select-Object -Property name, variableName, Value | Export-Csv $folderpath\CompiledAppSettings.csv -NoTypeInformation

}


CompileAllExcels $folderpath $FilePath 