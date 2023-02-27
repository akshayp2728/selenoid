#resource "random_pet" "rg_name" {
#  prefix = var.resource_group_name_prefix
#}

resource "azurerm_resource_group" "rg2" {
  name     = "rggroups2"
  location = var.resource_group_location
  #  name     = random_pet.rg_name.id
}

# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  allocation_method   = "Dynamic"
}

#create a data to recicve ip
data "azurerm_public_ip" "my_terraform_public_ip" {
  name                = azurerm_public_ip.my_terraform_public_ip.name
  resource_group_name = azurerm_resource_group.rg2.name

}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name

  security_rule {
   name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Selenoid"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "4444"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "Selenoidui"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5555"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name

  ip_configuration {
    name                          = "myPublicIP"
    subnet_id                     = azurerm_subnet.my_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

# Generate random text for a unique storage account name
#resource "random_id" "random_id" {
#  keepers = {
#    # Generate a new ID only when a new resource group is defined
#    resource_group = azurerm_resource_group.rg2.name
#  }

#  byte_length = 8
#}
# Create storage account for boot diagnostics
#resource "azurerm_storage_account" "my_storage_account" {
#  name                     = "diag${random_id.random_id.hex}"
#  location                 = azurerm_resource_group.rg2.location
#  resource_group_name      = azurerm_resource_group.rg2.name
#  account_tier             = "Standard"
#  account_replication_type = "LRS"
#}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "myVM"
  location              = azurerm_resource_group.rg2.location
  resource_group_name   = azurerm_resource_group.rg2.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_DS3_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "YouKnowNothing@123"
  disable_password_authentication = false

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  
   connection {
    type     = "ssh"
    user     = "azureuser"
    password = "YouKnowNothing@123"
    host     = self.public_ip_address
    #      private_key = "${file("/home/azureuser/.ssh/authorized_keys.pem")}"
    private_key = file("~/.ssh/id_rsa")
    timeout = "10m"
  }

  provisioner "file" {
    source      = "/home/TerraformHost/selenoidfinal/installdocker.sh"
    destination = "/home/azureuser/installdocker.sh"
  }

  provisioner "file" {
    source      = "/home/TerraformHost/selenoidfinal/dockerimagepull.sh"
    destination = "/home/azureuser/dockerimagepull.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/azureuser/",
      "ls -a",
      "sudo chmod +x installdocker.sh",
      "sudo ./installdocker.sh",
    ]
    connection {
      type     = "ssh"
      user     = "azureuser"
      password = "YouKnowNothing@123"
      host     = self.public_ip_address
      #      private_key = "${file("/home/azureuser/.ssh/authorized_keys.pem")}"
      private_key = file("~/.ssh/id_rsa")
      timeout = "10m"
    }
  }
   provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "azureuser"
      password = "YouKnowNothing@123"
      host     = self.public_ip_address
      #      private_key = "${file("/home/azureuser/.ssh/authorized_keys.pem")}"
      private_key = file("~/.ssh/id_rsa")
      timeout = "10m"
    }
    inline = [
      "cd /home/azureuser/",
      "ls -a",
      "sudo chmod +x dockerimagepull.sh",
      "sudo ./dockerimagepull.sh",
    ]
  }


}
