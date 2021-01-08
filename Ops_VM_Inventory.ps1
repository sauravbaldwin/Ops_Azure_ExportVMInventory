#Connect-AzAccount
$vmobjs = @()


Set-AzContext -Subscription Axis-Azure-Sandbox-01

       

        $vms = Get-AzVM -Status

 

        foreach ($vm in $vms)

            {

               

                $nicnames = $vm.NetworkProfile.NetworkInterfaces.Id

                $osdisk = $vm.StorageProfile.OsDisk

                $datadisks = $vm.StorageProfile.DataDisks

                $tagkeys = $vm.Tags.Keys

                $tagvalues = $vm.Tags.Values

               

                $nic_name_list = ''

                $nic_private_ip_list = ''

                $nic_public_ip_list = ''

                $data_disk_name_list = ''

                $data_disk_caching_list = ''

                $disktype = $null

                $tag_list = ''

                $i = 0

                $j = 0

         

 

                #=========================== Fetch Network Details of VM ===========================#

               

                foreach ($nicname in $nicnames)

                {

 

                  $nicname = $nicname.tostring().substring($nicname.tostring().lastindexof('/')+1)

                  $nic_name_list_temp = $nic_name_list + $nicname + "; "

                  $nic_name_list = $nic_name_list_temp

 

                  $nicdetails = Get-AzNetworkInterface -Name $nicname

                  $nic_private_ip = $nicdetails.IpConfigurations.PrivateIpAddress

                  $nic_private_ip_list_temp = $nic_private_ip_list + $nic_private_ip + "; "

                  $nic_private_ip_list = $nic_private_ip_list_temp

 

                    if ($nicdetails.Primary -eq "True")

                    {

                     

                      $primarynic = $nicdetails.Name

                      $primaryip = $nicdetails.IpConfigurations.PrivateIpAddress

 

                    }

 

                  if ($nicdetails.IpConfigurations.PublicIpAddress -ne $null)

                  {

 

                    $nic_public_ip_id = $nicdetails.IpConfigurations.PublicIpAddress.Id.tostring().substring($nicdetails.IpConfigurations.PublicIpAddress.Id.tostring().lastindexof('/')+1)

                    $nic_public_ip = Get-AzPublicIpAddress -Name $nic_public_ip_id

                    $nic_public_ip_list_temp = $nic_public_ip_list + $nic_public_ip.IpAddress + "; "

                    $nic_public_ip_list = $nic_public_ip_list_temp

 

                    if ($nicdetails.Primary -eq "True")

                    {

                     

                      $primarypip = $nic_public_ip.IpAddress

 

                    }

 

                  }

 

                }

                   

                #=========================== Fetch Storage Details of VM ===========================#

               

                if ($osdisk.ManagedDisk -eq $null)

                {

                   

                    $disktype = "Unmanaged"

 

                }

 

                else

 

                {

                   

                    $disktype = "Managed"

 

                }

 

                 

                  if ($disktype -eq "Managed")

                  {

                   

                    $osdiskproperties = Get-AzDisk -DiskName $osdisk.Name

                    $osdiskname = $osdiskproperties.Name

                    $osdisksize = $osdiskproperties.DiskSizeGB

                    $osdiskcaching = $osdisk.Caching

                   

                    foreach ($datadisk in $datadisks)

                    {

                   

                      $datadiskproperties = Get-AzDisk -DiskName $datadisk.Name

                      $data_disk_name_list_temp = $data_disk_name_list + $datadiskproperties.Name + " = " + $datadiskproperties.DiskSizeGB + " GB" + "; "

                      $data_disk_name_list = $data_disk_name_list_temp

 

                      $data_disk_caching_list_temp = $data_disk_caching_list + $datadisk.Name + " = " + $datadisk.Caching + "; "

                      $data_disk_caching_list = $data_disk_caching_list_temp

                   

                    }

 

                  }

 

                  else

                  {

 

                    $osdiskname = $osdisk.Name

                    $osdisksize = $osdisk.DiskSizeGB

                    $osdiskcaching = $osdisk.Caching

 

                    foreach ($datadisk in $datadisks)

                    {

 

                      $data_disk_name_list_temp = $data_disk_name_list + $datadisk.Name + " = " + $datadisk.DiskSizeGB + " GB" + "; "

                      $data_disk_name_list = $data_disk_name_list_temp

 

                      $data_disk_caching_list_temp = $data_disk_caching_list + $datadisk.Name + " = " + $datadisk.Caching + "; "

                      $data_disk_caching_list = $data_disk_caching_list_temp

 

                    }

 

                  }

               

                #=========================== Fetch Tag Details of VM ===========================#

               

                while ($i -lt $tagkeys.Count)

                {

               

                  $tagkey = $tagkeys | Select-Object -Index $i

            

                  while ($j -eq $i)

                  {

            

                    $tagvalue = $tagvalues | Select-Object -Index $j

                    $tag_list_temp = $tag_list + "(" + $tagkey + " = " + $tagvalue + ")" + "; "

                    $tag_list = $tag_list_temp

                    $j += 1

             

                  }

 

                  $i += 1

 

                }

 

                

 

                $vmInfo = [pscustomobject]@{

                         

                          'VM ID' = $vm.VmId

                          'Name'= $vm.Name

                          'Subscription Name'= $sub.Name

                          'Resource Group Name' = $vm.ResourceGroupName

                          'Location' = $vm.Location

                          'VM Status'= $vm.PowerState

                          'VM Size'= $vm.HardwareProfile.VmSize

                          'OS Type'= $vm.StorageProfile.OsDisk.OsType

                          'NICs attached' = $nic_name_list

                          'Primary NIC' = $primarynic

                          'Private IPs attached' = $nic_private_ip_list

                          'Primary Private IP' = $primaryip

                          'Public IPs attached' = $nic_public_ip_list

                          'Primary Public IP' = $primarypip

                          'Disk Type' = $disktype

                          'OS Disk'= $osdiskname + ' = ' + $osdisksize + ' GB'

                          'OS Disk - Caching' = $osdiskname + ' = ' + $osdiskcaching

                          'Data Disks'= $data_disk_name_list

                          'Data Disks - Caching' = $data_disk_caching_list

                          'Host Name' = $vm.OSProfile.ComputerName

                          'Local Admin User ID' = $vm.OSProfile.AdminUsername

                          'Azure VM Agent' = $vm.OSProfile.WindowsConfiguration.ProvisionVMAgent

                          'Automatic Updates' = $vm.OSProfile.WindowsConfiguration.EnableAutomaticUpdates

                          'Windows License Type' = $vm.LicenseType

                          'Tags' = $tag_list

                          'Azure Resource ID'= $vm.Id

                         

                          }

                          

                       $vmobjs += $vmInfo

               

            }  

    

$vmobjs | Export-Csv -Path "C:\Users\saurav.c.shekhar\Documents\Inventory\Axis_Azure_VM Inventory_22122020_Sandbox.csv" -NoTypeInformation

Write-Host "Inventory extracted to .csv file."

Invoke-Item "C:\Users\saurav.c.shekhar\Documents\Inventory\Axis_Azure_VM Inventory_22122020_Sandbox.csv"