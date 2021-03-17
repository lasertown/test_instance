#!/bin/sh

# Create Resource Group
RgName="test_instance"
Location="westus2"
az group create \
        --name $RgName \
        --location $Location

# Create Public IP
PipName="myPublicIP"
az network public-ip create \
        --name $PipName \
        --resource-group $RgName \
        --location $Location

# Create VNET
VnetName="myVnet"
VnetPrefix="10.0.0.0/16"
VnetSubnetName="mySubnet"
VnetSubnetPrefix="10.0.0.0/24"
az network vnet create \
        --name $VnetName \
        --resource-group $RgName \
        --location $Location \
        --address-prefix $VnetPrefix \
        --subnet-name $VnetSubnetName \
        --subnet-prefix $VnetSubnetPrefix

# Create NSG
NsgName="grantAllow"
az network nsg create \
        --resource-group $RgName --name $NsgName

# Create NSG Rule
az network nsg rule create \
        --name "Allow SSH" \
        --resource-group $RgName \
        --nsg-name $NsgName \
        --priority 100 \
        --source-address-prefixes $(curl -s ifconfig.me)/32 \
        --destination-port-ranges 22 \
        --access Allow \
        --protocol Tcp \
        --description "Accept SSH connections from my public IP"

# Apply NSG to Subnet
az network vnet subnet update \
        --resource-group $RgName \
        --name $VnetSubnetName \
        --vnet-name $VnetName \
        --network-security-group $NsgName

# Create a VM
VmName="myVm"
VmSize="Standard_B2ms"
OsImage="SUSE:sles-15-sp2:gen2:latest"
Username="azadmin"
SshKeyValue="</path/to/local/file>" #<-----------CHANGE THIS VALUE TO YOUR LOCAL SSH PUBLIC KEY PATH
az vm create \
        --name $VmName \
        --resource-group $RgName \
        --image $OsImage \
        --location $Location \
        --size $VmSize \
        --admin-username $Username \
        --ssh-key-value $SshKeyValue \
        --nsg $NsgName
