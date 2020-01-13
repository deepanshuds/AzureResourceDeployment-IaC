$csvFilePath = ".csv"
$resourceGroup = ""
$KeyVaultName = ""

#$KeyVaultName = (Get-AzureRmKeyVault -ResourceGroupName $resourceGroup -VaultName ).VaultName

$Excel = Import-Csv -Path $csvFilePath

foreach($val in $Excel)
{
    $Key = $val.Name
    $Value = $val.Value

    #Write-host $Key - $Value

    $secretKey = ConvertTo-SecureString -String $Value -AsPlainText -Force

    Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $val.Name -SecretValue $secretKey
}


