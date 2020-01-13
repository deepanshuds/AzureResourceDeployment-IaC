$ResourceGroup = "Test" 
$InputFilePath = "\ListOfFunctionsDev.txt" #Change as per your local file path
$OutputFolderPath = ""  #Change for output path.


function GenerateExcelFilesWithAppSettings($ResourceGroupName, $InputFilePath, $OutputFolderPath)
{
  
    $ListofFunctions = (Get-Content -Path $InputFilePath).Split("`n")

    $OutputFunctionList = $null

    foreach($func in $ListofFunctions)
    {
        $webApp = Get-AzureRmWebApp -Name $func -ResourceGroupName $ResourceGroupName
        Write-host $webApp.Name

        $FunctionName = $webApp.Name

        $OutputFile = $OutputFolderPath + "\" + $FunctionName + ".csv"

        $appSettings = $webApp.SiteConfig.AppSettings 

        #Create new object with additional variablename and export that to csv

        $appSettings | Select-Object -Property Name, Value | Export-Csv $OutputFile -NoTypeInformation          
    }
}

GenerateExcelFilesWithAppSettings $ResourceGroup $InputFilePath $OutputFolderPath 


