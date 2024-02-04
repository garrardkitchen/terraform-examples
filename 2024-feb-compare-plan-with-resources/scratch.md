
---

Next, to extract name, resource type, rg + location:

```powershell
tf show -json plan.tfplan | ConvertFrom-Json | % { $_.resource_changes } | ? { $_.change.actions -contains "create" } | % { $_.change.after.name + "," + $_.type + "," + $_.change.after.resource_group_name + "," + $_.change.after.location }
```

OR

_ name, resource type, rg + location + resourceId + resourceType_:

```powershell
tf show -json plan.tfplan | ConvertFrom-Json | % { $_.resource_changes } | ? { $_.change.actions -contains "create" } | % { $_.change.after.name + "," + $_.type + "," + $_.change.after.resource_group_name + "," + $_.change.after.location + "," + (Get-AzResource -Name $_.change.after.name).ResourceId + "," + (Get-AzResource -Name $_.change.after.name).ResourceType}
```

OR

```powershell
tf show -json plan.tfplan | ConvertFrom-Json | % { $_.resource_changes } | ? { $_.change.actions -contains "create" } | % { $_.change.after.name} |  ForEach-Object {Write-Host $_ + ((Get-AzResource -Name $_)).ResourceId}
```

Pipe name from above:

```powershell
Get-AzResource -Name mainVNet
```

This gets resourceId for planned
```powershell
tf show -json plan.tfplan | ConvertFrom-Json | % { $_.planned_values.root_module.resources } | % { $_.name + "," + $_.type + "," + $_.values.id }
```

```powershell
tf show -json plan.tfplan | ConvertFrom-Json | % { $_.resource_changes } | ? { $_.change.actions -contains "create" } | % { $_.change.after.name + "," + $_.type + "," + $_.change.after.resource_group_name + "," + $_.change.after.location + "," + ((Get-AzResource -Name $_).ResourceId }
```

```powershell
Get-AzResource -ResourceId "/subscriptions/0c4cd68e-b72d-45f0-b02f-7193fcf61e64/resourceGroups/compare-sample-rg/providers/Microsoft.Network/virtualNetworks/mainVNet"
```

```powershell
Install-Module -Name ImportExcel -Force -AllowClobber
```

Add to excel sheet:

```powershell
??? | ConvertFrom-Csv | Export-Excel -Path "./sheet.xlsx" -WorksheetName 'YourSheetName'
```

```powershell
# Import the CSV file
$csvData = Import-Csv -Path "./yourfile.csv"

# Iterate over each row
foreach ($row in $csvData) {
    # Get the worksheet name from the 2nd column
    $worksheetName = $row.'ColumnName'  # Replace 'ColumnName' with the name of your 2nd column

    # Export the row to an Excel file
    $row | Export-Excel -Path "./sheet.xlsx" -WorksheetName $worksheetName -Append
}
```

Scratch:

```powershell
gc .\plan.json | ConvertFrom-Json | % { $_.resource_changes } | ? { $_.change.actions -contains "create" } | % { $_.address + " " + $_.type + " " + $_.change.after.id }
```

OR

```powershell
tf show -json plan.tfplan | ConvertFrom-Json | % { $_.resource_changes } | ? { $_.change.actions -contains "create" } | % { $_.address + " " + $_.type + " " + $_.change.after.id }
```