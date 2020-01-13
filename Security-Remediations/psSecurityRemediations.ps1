
param(
	[Parameter(Mandatory=$false)]
    [string]$ExcelFileName = "Azure Security Recommendations -.xlsx", #Name of Excel file.
	[Parameter(Mandatory=$true)]
    [string[]]$subscriptionName, 
	[Parameter(Mandatory=$true)]
    [string]$ResourceGroupName, 
    [Parameter(Mandatory=$false)]
    [switch]$EnableHTTPs,
    [Parameter(Mandatory=$false)]
    [switch]$SetDiagnostic    
)

Write-host "Creating Alias for AzureRM module"
Enable-AzureRmAlias -Scope CurrentUser
<#
$AzureRMModule = Get-InstalledModule -ErrorAction SilentlyContinue | Where-Object{ $_.Name -eq "AzureRM" -or $_.Name -eq "Az"} 

if(!$AzureRMModule)
{   
    Write-host "AzureRM Module not present. Installing the module"
    Install-Package -Name "AzureRM" -Source PSGallery -AllowClobber -Force 
}

if($AzureRMModule.Name -eq "Az")
{
    Write-host "Creating Alias for AzureRM module"
    Enable-AzureRmAlias -Scope CurrentUser
}

if($AzureRMModule.Name -eq "AzureRM" -and $AzureRMModule.version -lt 6.13.1)
{
    Write-host "Upgrading to latest version"
    Install-Package -Name "AzureRM" -Source PSGallery -AllowClobber -Force
}
elseif($AzureRMModule.Name -eq "AzureRM" -and $AzureRMModule.version -ge 6.13.1)
{
    Write-host "Required version is already installed"
}
#>


#Get user login details
$userLogin = Get-AzurermSubscription -ErrorAction SilentlyContinue

#Prompt login for user if not logged in
if(!$userLogin)
{
    Login-AzureRmAccount
}

Write-host $userLogin

$FolderPath = Get-Location
Write-host $FolderPath

$jsonData = Get-Content -Path "$FolderPath\parameters.json" | ConvertFrom-Json

$devResourceGroupName = $jsonData.devResourceGroupName.value
$qaResourceGroupName = $jsonData.qaResourceGroupName.value
$stgResourceGroupName = $jsonData.stgResourceGroupName.value
$prodResourceGroupName = $jsonData.prodResourceGroupName.value

$devStorageAccountName = $jsonData.devStorageAccountName.value
$qaStorageAccountName = $jsonData.qaStorageAccountName.value
$stgStorageAccountName = $jsonData.stgStorageAccountName.value
$prodStorageAccountName = $jsonData.prodStorageAccountName.value

$resourceGroupObj = New-Object -TypeName psobject
$resourceGroupObj | Add-Member -MemberType NoteProperty -Name Dev -Value $devResourceGroupName
$resourceGroupObj | Add-Member -MemberType NoteProperty -Name QA -Value $qaResourceGroupName
$resourceGroupObj | Add-Member -MemberType NoteProperty -Name Stg -Value $stgResourceGroupName
$resourceGroupObj | Add-Member -MemberType NoteProperty -Name Prod -Value $prodResourceGroupName

$storageAccountObj = New-Object -TypeName psobject
$storageAccountObj | Add-Member -MemberType NoteProperty -Name Dev -Value $devStorageAccountName
$storageAccountObj | Add-Member -MemberType NoteProperty -Name QA -Value $qaStorageAccountName
$storageAccountObj | Add-Member -MemberType NoteProperty -Name Stg -Value $stgStorageAccountName
$storageAccountObj | Add-Member -MemberType NoteProperty -Name Prod -Value $prodStorageAccountName

Write-host $resourceGroupObj
Write-host $storageAccountObj

$ExcelFilePath = ($FolderPath,"\",$ExcelFileName) -join("")
$csvFilePath = ($FolderPath,"\","Azure Security Recommendations.csv") -join("")

function EnableHTTPSresources($ExcelData)
{
    $EnableHTTPSresources = $ExcelData | Where-Object {$_.recommendationDisplayName -like "* should only be accessible over HTTPS"}

    Write-host "Number of resources: " $EnableHTTPSresources.Count

    foreach($value in $EnableHTTPSresources)
    {
        $resource = Get-AzureRmResource -ResourceId $value.resourceId -ErrorAction SilentlyContinue

        if($resource)
        {
            Write-host "Enabling HTTPS for resource:" $value.resourceName -ForegroundColor Cyan
            
            Set-AzureRmWebApp -Name $value.resourceName -ResourceGroupName $value.resourceGroup -HttpsOnly $true  
        }
    }
}

function getStorageAccountID($value, $resourceGroupObj, $storageAccountObj)
{
    $Location = (Get-AzureRmResource -ResourceId $value.resourceId).Location
    Write-host "resource location" $Location

    if($value.resourceGroup -eq $resourceGroupObj.Dev)
    {
        if($Location -eq "eastus" -or $Location -eq "East US")
        {
            $storageAccountName = $storageAccountObj.Dev.ToLower() + "eastus"
        }
        elseif($Location -eq "eastus2" -or $Location -eq "East US 2")
        {
            $storageAccountName = $storageAccountObj.Dev.ToLower() + "eastus2"
        }
        else
        {
            Write-host "Resource not in east us or east us 2"
            Continue 
        }
    }
    elseif($value.resourceGroup -eq $resourceGroupObj.qa)
    {
        if($Location -eq "eastus" -or $Location -eq "East US")
        {
            $storageAccountName = $storageAccountObj.qa.ToLower() + "eastus"
        }
        elseif($Location -eq "eastus2" -or $Location -eq "East US 2")
        {
            $storageAccountName = $storageAccountObj.qa.ToLower() + "eastus2"
        }
        else
        {
            Write-host "Resource not in east us or east us 2"
            Continue 
        }
    }
    elseif($value.resourceGroup -eq $resourceGroupObj.Stg)
    {
        if($Location -eq "eastus" -or $Location -eq "East US")
        {
            $storageAccountName = $storageAccountObj.Stg.ToLower() + "eastus"
        }
        elseif($Location -eq "eastus2" -or $Location -eq "East US 2")
        {
            $storageAccountName = $storageAccountObj.Stg.ToLower() + "eastus2"
        }
        else
        {
            Write-host "Resource not in east us or east us 2"
            Continue 
        }
    }
    elseif($value.resourceGroup -eq $resourceGroupObj.Prod)
    {
        if($Location -eq "eastus" -or $Location -eq "East US")
        {
            $storageAccountName = $storageAccountObj.Prod.ToLower() + "eastus"
        }
        elseif($Location -eq "eastus2" -or $Location -eq "East US 2")
        {
            $storageAccountName = $storageAccountObj.Prod.ToLower() + "eastus2"
        }
        else
        {
            Write-host "Resource not in east us or east us 2"
            Continue 
        }
    }

    Write-host "Storage Account Name:" $storageAccountName

    $storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $value.resourceGroup -Name $storageAccountName -ErrorAction SilentlyContinue

    if(!$storageAccount)
    {
        Write-host "Creating new storage account" $storageAccountName "in resource group" $value.resourceGroup

        $storageAccount = New-AzureRmStorageAccount -ResourceGroupName $value.resourceGroup -Name $storageAccountName -SkuName Standard_LRS -Location $Location -Kind BlobStorage -AccessTier Hot -EnableHttpsTrafficOnly $true                       
    }

    $storageAccountID = $storageAccount.Id

    return $storageAccountID
}

function SetDiagnosticSetting($ExcelData, $resourceGroupObj, $storageAccountObj)
{
    $diagnosticResources = $ExcelData | Where-Object {$_.recommendationDisplayName -like "Diagnostic logs in *"}

    Write-host "Number of resources: " $diagnosticResources.Count

    foreach($value in $diagnosticResources)
    {   
        Write-host "resource:" $value.resourceName
        Write-host "Getting Storage ID"     

        $storageAccountID = getStorageAccountID $value $resourceGroupObj $storageAccountObj
        
        Write-host $storageAccountID

        if(!$storageAccountID)
        {
            Write-host "Storage ID not found"
            Continue
        }

        $resource = Get-AzureRmResource -ResourceId $value.resourceId -ErrorAction SilentlyContinue

        if($resource)
        {
            $diagnosticSetting = Get-AzureRmDiagnosticSetting -ResourceId $value.resourceId -ErrorAction SilentlyContinue
            
            if(!$diagnosticSetting)
            {
                Write-host "Setting Diagnostic Setting for:" $value.resourceName -ForegroundColor Cyan

                $settingName = $value.resourceName + "-diagnostic-setting"

                #Setting Metrics 
                Set-AzureRmDiagnosticSetting -ResourceId $value.resourceId -Name $settingName -StorageAccountId $storageAccountID -MetricCategory AllMetrics -Enabled $true -RetentionEnabled $true -RetentionInDays 14

                $setting = Get-AzureRmDiagnosticSetting -ResourceId $value.resourceId -ErrorAction SilentlyContinue

                $categories = $setting.Logs.Category

                #Setting Logs for all categories
                Set-AzureRmDiagnosticSetting -ResourceId $value.resourceId -Name $settingName -Category $categories -Enabled $true -RetentionEnabled $true -RetentionInDays 14
            }
            else
            {
                Write-host "Diagnostic setting for" $value.resourceName "already exists."
            }
        }
    }
}

foreach($subscription in $subscriptionName)
{
    Select-AzureRmSubscription $subscription

    $ExcelData = Get-Content -Path $csvFilePath | ConvertFrom-Csv | Where-Object {$_.resourceGroup -eq $ResourceGroupName -and $_.subscriptionName -eq $subscription}
    
    if($SetDiagnostic.IsPresent)
    {
        SetDiagnosticSetting $ExcelData $resourceGroupObj $storageAccountObj
    }

    if($EnableHTTPs.IsPresent)
    {
        EnableHTTPSresources $ExcelData
    }

}


