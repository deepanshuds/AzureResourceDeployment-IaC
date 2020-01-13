
$KeyVaultName = (Get-AzureRmKeyVault -ResourceGroupName ENE-RK-001-D -VaultName ENE-RK-Keyvault-be-001-Q).VaultName

$SecretNames = (Get-AzureKeyVaultSecret -VaultName $KeyVaultName).Name

$SecretNames
foreach($secrets in $SecretNames){
(Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $secrets).SecretValueText
}