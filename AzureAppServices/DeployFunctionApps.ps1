param(
 [Parameter(Mandatory=$False)]
 [string] $FunctionsConsumption = "",
 [string] $FunctionsServicePlan = "",

 [string] $ResourceGroupName = "",
 [string] $storageName = "",
 [string] $appInsightName = "",
 [string] $servicePlanName = ""
)

$FunctionsConsumptionList = $FunctionsConsumption.split(",")
$FunctionsServicePlanList = $FunctionsServicePlan.split(",")

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$templatefilePathConsumption = "$scriptPath\FunctionappConsumption.deploy.json"
$templatefilePathServicePlan = "$scriptPath\FunctionappServicePlan.deploy.json"

function CreateFunctionApps($ResourceGroupName, $FunctionsList, $templatePath, $storageName, $appInsightName, $servicePlanName)
{
#Creating consumption based functions
   foreach($functionName in $FunctionsList)
    {   
        $function = $functionName.trim() #Remove spaces at the start or end of name
        Write-host "Creating " $function " Function app."
        
        if($servicePlanName -eq $null)
        {
        New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $templatePath -name $function -functionAppName $function -storageName $storageName -appInsightName $appInsightName
        }
        else
        {
        New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $templatePath -name $function -functionAppName $function -storageName $storageName -appInsightName $appInsightName -servicePlanName $servicePlanName
        }

        Write-host "Created " $function " Function app."

    }

}
if($FunctionsConsumption -ne "")
{
    CreateFunctionApps $ResourceGroupName $FunctionsConsumptionList $templatefilePathConsumption $storageName $appInsightName $null
}
if($FunctionsServicePlan -ne "")
{
    CreateFunctionApps $ResourceGroupName $FunctionsServicePlanList $templatefilePathServicePlan $storageName $appInsightName $servicePlanName
}
