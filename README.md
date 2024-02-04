# Brief

Compare a list of existing resources with what is planned in our IaC.

# Reason

The reason for this example is to simulate working with resources that we have no state for, or never will.  Yup, crazy, but this is dice we've been rolled in this scenario.  What we want to do is check that what's been deployed, is indeed what the config had deployed.  So, all we're doing is comparing our plan with the names of the resource that have been deployed.

# Steps

**Step 1**:

_execute the plan and out the plan so we can generate the JSoN from this_:

```powershell
tf plan -var-file="tfvars/dev.tfvars" -out plan.tfplan
tf show -json plan.tfplan > plan.json
```

**Step 2**:

_now deploy the resource so we have resources to compare with later_:

```powershell
tf apply -var-file="tfvars/dev.tfvars" -auto-approve
```

**Step 3**

_next, we must delete our local state file so when we get to the starting state we're after_:

```powershell
Remove-Item -path terraform.tfstate -ErrorAction Ignore
Remove-Item -path sheet.xlsx -ErrorAction Ignore
```

**Step 4**

_ascertain list of resources from plan and generate a csv with headers_:

```powershell
$collection = (tf show -json plan.tfplan | ConvertFrom-Json | % { $_.resource_changes } | ? { $_.change.actions -contains "create" } | % { $_.change.after.name + "," + $_.type + "," + $_.change.after.resource_group_name + "," + $_.change.after.location + "," + (Get-AzResource -Name $_.change.after.name).ResourceId + "," + (Get-AzResource -Name $_.change.after.name).ResourceType})

$csvData = $collection | ConvertFrom-Csv -Header ("resource","tf_type","rg","location", "resource_id", "resource_type")
```

**Step 5**

_create a excel spreadsheet with RG sheets containing all their resources_:

```powershell
# ascertain unique list of RGs
$rgList = $csvData | Select-Object rg -Unique

# iterate over RGs and reduce to those resources that belong to current RG 
# then add list of resources to a sheet with the name of the RG
foreach ($rg in $rgList) {

    $worksheetName = $rg.rg -eq  "" ? "blank" : $rg.rg
    $rgData = $csvData | Where-Object { $_.rg -eq $rg.rg} 

    foreach ($row in $rgData) {
      
        $row | Export-Excel -Path "./sheet.xlsx" -WorksheetName $worksheetName -Append
    }
}
```