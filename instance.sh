#!/bin/sh

# Create Resource Group
RgName="test1"
Location="westus2"
az group create --name $RgName --location $Location

# Create Public IP
PipName="myPublicIP"
az network public-ip create --name $PipName --resource-group $RgName --location $Location

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
NSGname="grantnsg"
az network nsg rule create \
        --name "Allow SSH" \
        --resource-group $RgName \
        --nsg-name $NSGname \
        --priority 100 \
        --source-address-prefixes $(curl -s ifconfig.me)/32 \
        --destination-port-ranges 22 \
        --access Allow \
        --protocol Tcp \
        --description "Accept SSH connections from my public IP"

# Create NIC
NicName="MyNic1"
az network nic create \
        --name $NicName \
        --resource-group $RgName \
        --location $Location \
        --subnet $VnetSubnetName \
        --network-security-group $NSGname \
        --private-ip-address 10.0.0.4 \
        --vnet-name $VnetName \
        --public-ip-address $PipName
       
# Create a VM and attach the NIC.
VmName="myVm"
VmSize="Standard_A4_v2"
OsImage="SUSE:sles-15-sp2:gen2:latest"
Username="azadmin"
SshKeyValue="</path/to/local/file>"
az vm create \
        --name $VmName \
        --resource-group $RgName \
        --image $OsImage \
        --location $Location \
        --size $VmSize \
        --nics $NicName \
        --admin-username $Username \
        --ssh-key-value $SshKeyValue \
