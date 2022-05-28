
# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.env_location}${var.env_shortname}rg"
  location = "${var.azure_location}"
  tags = {
    Environment = "Terraform"
    Purpose     = "DevOps"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.env_shortname}vnet"
  address_space       = "${var.env_vnet_addr}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "appsubnet" {
  name                 = "${var.env_shortname}appsubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = "${var.env_appsubnet_addr}"
}

# Create network interface
resource "azurerm_network_interface" "apps01nic" {
  name                = "${var.env_shortname}apps01nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.env_shortname}apps01nic_configuration"
    subnet_id                     = azurerm_subnet.appsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "appsubnetnsg" {
  name                = "${var.env_shortname}appsubnetnsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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
    name                       = "appTraffic"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443,8888"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "appsubnetnsg" {
  network_interface_id      = azurerm_network_interface.apps01nic.id
  network_security_group_id = azurerm_network_security_group.appsubnetnsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "apps01" {
  name                  = "${var.env_shortname}apps01"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.apps01nic.id]
  size                  = "Standard_B2ms"
  admin_username        = "azureuser"
  admin_password        = "1gnio@1gnio"
  computer_name         = "${var.env_shortname}apps01"
  disable_password_authentication = false
  os_disk {
    name                 = "${var.env_shortname}apps01osdisk"
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "30"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Create public IPs
resource "azurerm_public_ip" "publicip" {
  name                = "${var.env_shortname}publicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}