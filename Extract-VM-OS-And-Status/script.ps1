Connect-AzAccount

Get-AzVM  -Name * -Status | select name, powerstate, @{n="OS";E={$_.StorageProfile.OsDisk.OsType}}, @{n="Offer";E={$_.StorageProfile.ImageReference.offer}} , @{n="SKU";E={$_.StorageProfile.ImageReference.sku}}, @{n="Publisher";E={$_.StorageProfile.ImageReference.Publisher}} | Export-CSV export.csv -NoTypeInformation
