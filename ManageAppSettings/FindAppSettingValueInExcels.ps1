    $folderpath = "" #Path to folder with functions list file
    $FilePath = "$folderpath\OutputFunctionsList.txt"
    $ListofFunctions = (Get-Content -Path $FilePath).Split("`n")
    
	#Enter either name/variableName/value to find it in the files
    $name = ""
    $variableName = ""
    $value = ""

    foreach($FunctionName in $ListofFunctions)
    {
        #$FunctionName = ($func -split $projectNameSplit)[1]

        $csvFilePath = $folderpath + "\" + $FunctionName

        $CsvContent = Get-Content -Path $csvFilePath | ConvertFrom-Csv

        for($i=0; $i -lt $CsvContent.name.Length; $i++)
        {
            #Write-host $CsvContent.name.Length
            #Write-host $CsvContent.name


            ##FIND BY VALUE

            if($value -ne "" -and $value -eq $CsvContent.value[$i])
            {
                Write-host $CsvContent.name[$i] -ForegroundColor DarkYellow
                $CsvContent.variablename[$i]
                Write-host $FunctionName -ForegroundColor Cyan
            }

            ##FIND BY NAME
            if($name -ne "" -and  $name -eq $CsvContent.name[$i])
            {
                Write-host $CsvContent.variablename[$i] -ForegroundColor DarkYellow
                $CsvContent.value[$i]
                Write-host $FunctionName -ForegroundColor Cyan
            }

            ##FIND BY VARIABLE NAME
            if($variablename -ne "" -and $variablename -eq $CsvContent.variablename[$i])
            {
                Write-host $CsvContent.name[$i] -ForegroundColor DarkYellow
                $CsvContent.value[$i]
                Write-host $FunctionName -ForegroundColor Cyan
            }

        }

    }