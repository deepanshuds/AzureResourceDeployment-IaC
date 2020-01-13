param(
$resourceGroupName = "",
$serverName = "",
$storageAccountName = "",
$NotificationRecipientsEmails = ""
)

$auditSetting = Get-AzureRmSqlServerAuditing -ResourceGroupName $resourceGroupName -ServerName $serverName -ErrorAction SilentlyContinue

#Enable Auditing if not present
if(!$auditSetting.IsEnabled)
{
    Set-AzureRmSqlServerAuditing -ResourceGroupName $resourceGroupName -ServerName $serverName -State Enabled -RetentionInDays 14 -StorageAccountName $storageAccountName
}

$ThreatDetectionPolicy = Get-AzureRmSqlServerThreatDetectionPolicy -ResourceGroupName $resourceGroupName -ServerName $serverName -ErrorAction SilentlyContinue

#Enable Advanced Data Protection if not present
if(!$ThreatDetectionPolicy.IsEnabled)
{
    Set-AzureRmSqlServerThreatDetectionPolicy -ResourceGroupName $resourceGroupName -ServerName $serverName `
    -EmailAdmins $True -NotificationRecipientsEmails $NotificationRecipientsEmails
}




