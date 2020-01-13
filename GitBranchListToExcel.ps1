#Outputs the branch list to a csv file

$fileName = "branchlist.json"

$filePath = "\BranchesJSON\"

$jsonData = Get-Content -Path $filePath\$fileName | ConvertFrom-Json

$branchTable = New-Object System.Data.DataTable

$col1 = New-Object system.Data.DataColumn branchName,([string])
$col2 = New-Object system.Data.DataColumn Creator,([string])

$branchTable.columns.add($col1)
$branchTable.columns.add($col2)


foreach ($branch in ($jsonData.value | Where-Object {$_.name -like "refs/heads/*"}))
{
    $branchName = ($branch.name -Split("refs/heads/"))[1]

    $branchCreatorName = $branch.creator.displayName

    $newRow = $branchTable.NewRow()
    $newRow.branchName = $branchName
    $newRow.Creator = "$branchCreatorName"

    $branchTable.Rows.Add($newRow)
    
}

$Date = Get-Date -Format "ddMMyyyy"
$outputFileName = "branchList-" + $Date + ".csv"

$branchTable | export-csv $filePath\$outputFileName -noType
